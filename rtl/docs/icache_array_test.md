# icache.sv 独立测试

测试日期：2026-10-25。被测文件为 `rtl/tests/icache.sv`，测试前后 SHA256 均为 `e66f7ef4d7545a88605c10ecc6966dae326493b7a54d5dda29695a41e82bb938`。原文件未修改，未接入 CPU。

## 本次结论

按当前 **32 KiB、四路、128 组、64 B 行、32 位地址** 的实际实现测试，采用 Verilator 5.027：

- 12 项基础测试全部通过：包括三个随机种子，因此是 10 类基础用例、12 次运行。
- 两项额外边界测试失败：补行不更新 PLRU；对已驻留 Tag 再次整行写入可能返回旧副本。
- DUT 严格 lint（`-Wall`）无警告。
- 结果只验收当前存储/查找模块；没有握手、逐字补行、错误、地址属性或维护端口，因此没有测试这些功能，也没有标记整个 C1 完成。

完整证据：[结果表](../test_results/icache_unit_20261025_220758_985975.md)、[机器可读清单](../test_results/icache_unit_20261025_220758_985975.json)、[DUT 快照](../test_results/icache_unit_20261025_220758_985975.dut.sv)、[lint](../test_results/icache_unit_20261025_220758_985975.lint.log)。

## 如何复现

在 `rtl/` 下运行：

```bash
# 包括两项边界探测；当前实现是 12 PASS / 2 FAIL，命令返回 1
python3 tests/run_icache.py

# 仅验收当前已支持的基本存储/查找行为
python3 tests/run_icache.py --basic

# 单独复现边界并生成波形
python3 tests/run_icache.py --case refill_recency --case duplicate_fill --wave

# 选择随机种子
python3 tests/run_icache.py --case random_fits --seed 493
```

测试平台是 [icache_unit_tb.sv](../tests/icache_unit_tb.sv)，运行入口是 [run_icache.py](../tests/run_icache.py)。脚本固定一次测试使用的 DUT/TB 快照，保存散列、日志、波形和汇总；任意失败都会返回非零，不将边界失败包装为通过。

## 测试输入约定

`rst_n` 低有效、异步清零输出和有效位。`ren`、`wen` 在时钟沿采样；读命中结果在该沿之后更新。`ren=0` 的周期输出 `hit=0, inst=0`。读地址按四字节对齐；整行输入的低 32 位是行内第一个字，高 32 位是第 16 个字。

基础用例只对不存在的 Tag 发整行写入，保证无重复 Tag；读取、空闲和写入允许连续发生。命中后按树形 PLRU 更新替换状态。随机用例使用独立的地址/数据参考表，至多每组四个不同 Tag，不依赖 DUT 内部 way 编码；每个种子执行 10000 次混合操作，之后逐字检查全部 512 条候选行。

| 基础用例 | 覆盖内容 |
| --- | --- |
| reset | 填满全部 512 条行，再异步复位并逐行确认 miss，复位后重新写入 |
| line_words | 行内全部 16 个字、首尾地址、行/Tag 边界、填入地址偏移 |
| all_sets_ways | 128 组 × 4 路 × 16 字的数据校验 |
| address_bits | 独立翻转每个 index/Tag 地址位，检查地址区分 |
| enables_timing | ren/wen 控制、时钟前后输出变化、空闲不写入 |
| four_way_capacity | 四条同组行共存，第五条恰好替换一条 |
| plru_read_history | 三次命中的全部 64 种路序列，用抽象二叉树模型判断 victim |
| set_isolation | 不同组的数据与替换状态互不影响 |
| read_fill_miss | 同周期读/填入缺失行先观察旧状态，下次读取新数据 |
| random_fits | seed=1、493、65535，随机混合操作和最终全数据检查 |

## 边界一：补行不更新 PLRU

复现日志：[refill_recency](../test_results/icache_unit_20261025_220758_985975_refill_recency_1.log)，[波形](../test_results/icache_unit_20261025_220758_985975_refill_recency_1.vcd)。

同组地址依次为：

```text
A0 = 0x800004c0
A1 = 0x800024c0
A2 = 0x800044c0
A3 = 0x800064c0
A4 = 0x800084c0
A5 = 0x8000a4c0
```

复位后依次写 A0～A3，然后写 A4、A5，期间不发出读命中。当前替换位保持 `000`，A4、A5 连续写到 way 0；因此读 A4 miss。若成功填入也被计为一次使用，A4 应在紧接着的另一次补行后保留。

源码中 PLRU 只在读命中时更新，整行写入分支没有更新。这个现象属于替换策略/性能问题，不表示正常命中一定读错数据。需要决定并落实约定：让补行成功更新 PLRU，或保证上层在每次补行后先完成一次该行的命中读取，再允许下一次补行。

## 边界二：对已有 Tag 再写可能返回旧数据

复现日志：[duplicate_fill](../test_results/icache_unit_20261025_220758_985975_duplicate_fill_1.log)，[波形](../test_results/icache_unit_20261025_220758_985975_duplicate_fill_1.vcd)。

先以版本 1 写入 A0～A3，再将 A1 的版本 2 整行写入。当前逻辑不判断写入是否命中，按 victim 把新 A1 写到 way 0，而旧 A1 仍在 way 1。读取 A1 时两路同时命中，for 循环最后一次赋值选择旧 way 1，返回 `0x15e0c9af`，期望为新数据 `0x8ff40238`。

这项输入目前没有文档约束。如果 `wen` 只允许表示对缺失行的补行，调用者必须明确检查并保证这个条件；如果要允许更新驻留行，则需要更新已有命中路并保持每个 Tag 唯一，不能靠循环最后一次命中选择数据。

## 仿真器兼容性排查

安装的版本是 `Verilator 5.027 devel rev v5.026-105-ga32b8d80f`。默认编译条件下，额外出现 PLRU 历史和组隔离两个失败，见 [首次原文件结果](../test_results/icache_unit_20261025_220132_248888.json)。这些没有计为用户算法缺陷。

已检查生成的 C++：对 `plur_state[address_index][2:1] <= 2'b01`，该构建的数组 NBA 队列提交了整个元素值 `1`，没有保留位 0，也没有将 RHS 对齐到 `[2:1]`。对 `[2:1] <= 2'b00` 则提交整个元素 `0`。因此模拟结果与该部分位赋值的含义不符。

用两种方法交叉验证：

1. 仅在 `/tmp` 副本中把这两处改成等价整向量赋值 `{2'b01, old[0]}` / `{2'b00, old[0]}`。在不改变期望值的情况下，两项基础失败消失，得到 [12/14 结果](../test_results/icache_unit_20261025_220605_049339.json)，副本已作为 [独立快照](../test_results/icache_unit_20261025_220605_049339.dut.sv) 保存。
2. 保持用户原文件逐字节不变，增加 `--unroll-count 256`，让 128 项复位循环展开，避开有问题的队列生成路径。得到本报告的 12/14 结果：12 项基础通过，两项边界失败仍存在。

运行脚本默认带 `--unroll-count 256` 并在清单中记录；可用 `--unroll-count 64` 排查默认展开限制下的行为。这个选项只改变仿真器的代码生成，不修改 RTL 语义或测试期望。

尝试 VCS 交叉仿真时，编译器因无法连接许可证服务器而退出，见 [日志](../test_results/icache_vcs_crosscheck_20261025.build.log)，未取得 VCS 仿真结果。

## 与后续 C1/C2 的关系

当前已能独立验证 Cache 阵列、查找和命中后的 PLRU；配置与早期 4 KiB/两路/32 B 行的计划不同，本次尊重实际 32 KiB/四路/64 B 行实现进行测试，没有擅自改变参数。

接入 CPU 前，还需要补齐请求/响应握手、缺失检测后的后端请求、逐字补行与错误处理、不可缓存地址旁路和失效维护；另外要处理与 C0 的 34 位 PA、复位极性和行大小的衔接。本次不把这些未实现功能计入通过项。
