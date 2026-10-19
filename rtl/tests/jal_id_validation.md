# JAL 提前到 ID：实现与验证（2026-10-15）

JAL 的目标地址只依赖指令 PC 和立即数，现在在 ID 计算并发出重定向。
JAL 自身仍通过 EX、MEM、WB，返回地址仍由原有数据通路写入 `rd = PC + 4`。
这次减少的是跳转后目标指令的取指等待，不是 JAL 自身在 EX 中的周期数。

## 修改逻辑

| 位置 | 修改前 | 修改后 |
| --- | --- | --- |
| `vsrc/core/riscv_core.v` | 等到 EX 发出 JAL 重定向 | ID 有效且能推进、无更早 EX 重定向时，计算 `id_pc + id_imm` 并重定向 |
| 前端冲刷 | 只响应 EX 重定向 | 响应 EX 或 ID JAL，清空 IF1、IF2、IF/ID 和暂停返回缓冲 |
| `vsrc/core/id_ex_reg.v` | 无提前处理标志 | 新增 `ex_jal_resolved`，随指令锁存、暂停保持、复位/冲刷清零 |
| `vsrc/core/ex.v` | JAL 再次发出重定向 | 已在 ID 处理的 JAL 不再重定向，保持原有 PC+4 写回路径 |

EX 中更早的分支纠错、JALR、异常、MRET、FENCE.I 优先于 ID JAL。
ID JAL 发出重定向时不冲刷 ID/EX，否则会丢失 JAL 的返回地址写回和退休。
乘除法、访存等暂停期间，ID 不发出 JAL 重定向；解除暂停后再处理一次。

本次没有修改乘除法实现、条件分支预测器或 JALR 的解析阶段。

## 功能验证

使用 Verilator 5.027 编译完整 CPU 和现有系统测试台。临时测试台去掉不支持的
FSDB 调用，并包含 `tests/jal_early_checks.svh`，增加控制路径断言和可选 VCD。
准备和运行内存镜像时持有与先前乘除法验证相同的文件锁，结束后恢复原镜像。

| 检查 | 结果 |
| --- | --- |
| 单次被测 JAL，跳转目标与返回地址 | 修改前后均通过；目标到达 ID 的间隔 5 → 4 周期 |
| 定向 JAL 程序与控制断言 | PASS；12 次 ID 发出对应 12 次 EX 接受，无重复 EX 重定向 |
| 更早 EX 重定向优先 | PASS；覆盖条件分支、JALR、ECALL、MRET、FENCE.I 与年轻 JAL 冲突 |
| 返回地址与跳转形式 | PASS；函数调用/返回、连续 JAL、向后跳转、rd=x0 |
| 乘除法和 load-use 相邻 JAL | PASS；观察到 MUL 等待 4 周期、DIV 等待 8 周期，结果正确 |
| 强制访存暂停 | PASS；JAL 在 ID 暂停 4 周期、在 EX 暂停 3 周期，PC/标志保持且仅处理一次 |
| 先前 MUL/DIV 混合依赖汇编 | 两项均 PASS |
| 官方 JAL/JALR 单项 | 各 1/1 PASS |
| 分支预测测试 | 5/5 PASS |
| minstret 测试 | 3/3 PASS |
| 完整 ISA/UART 回归 | 50 ISA + 6 UART = 56/56 PASS，0 跳过，包含 fence_i |
| CoreMark | 修改前后 CRC 与测量计数一致性均 PASS |

相关证据均在 `test_results/`：

- 总记录：`jal_id_20261015_222224_before_run.log`、`jal_id_20261015_222224_after_run.log`
- 定向检查：`jal_early_20261015_222755.log`、`jal_early_stalled_20261015_222755.log`
- 回归：`all_summary_20261015_222802_519888.txt`
- 分支预测：`bp_summary_20261015_222757_955940.txt`
- 退休计数：`minstret_summary_20261015_222801_327099.txt`
- 编译：`jal_id_after_20261015_222443_build.log`

`make simv_build` 本次仍因无法取得 VCS 许可证失败，见
`jal_id_20261015_222224_vcs_build.log`。不能用旧 `simv` 代替本次重新编译的 RTL。

## CoreMark 对比

相同编译选项、同一模拟器、1 次迭代，比较函数测量区间
`0x80002970` 到 `0x8000297c`。这些是短时性能比较，不是正式 CoreMark 成绩。
基线保留了先前 MUL/DIV 的 N+2 优化，仅回退本次 JAL 的三个 RTL 文件。

| 指标 | 修改前 | 修改后 |
| --- | ---: | ---: |
| 测量区间 mcycle | 394962 | 389399 |
| 测量区间 minstret | 287265 | 287265 |
| CPI | 1.3749 | 1.3555 |
| MUL 暂停周期 | 37584 | 37584 |
| DIV 暂停周期 | 0 | 0 |
| load-use 暂停周期 | 21737 | 21737 |
| EX 重定向事件 | 12094 | 6531 |

总计减少 5563 周期（1.41%），与先前测出的区间内 5563 条 JAL 相符。
时钟频率相同时，区间执行速度提高约 1.43%。`redirects` 计数器只统计 EX
重定向；JAL 转移到 ID 后不再进入这个计数，它仍然需要进行前端重定向。

原始测量：`coremark_20261015_222729_474967.log`（前）、
`coremark_20261015_222827_113173.log`（后）。

尚未进行目标平台的综合/布局布线和静态时序分析。新增的
ID 译码/立即数到地址加法器、PC 选择及前端控制路径需要在确定平台与目标频率后检查。
测试台 20 ns 的时钟周期不代表实际硬件已经满足 50 MHz。

## 波形对照

直接解析 VCD 得到下表；日志在时钟沿后 1 ns 采样，因此日志对应为 451/551/531 ns。
这些数值来自仿真文件，没有通过 GUI 目测读取。

| 事件 | 修改前 | 修改后 |
| --- | ---: | ---: |
| PC=0x80000018 的 JAL 进入 ID | 450 ns | 450 ns |
| PC=0x80000024 的目标指令进入 ID | 550 ns | 530 ns |
| 两者间隔（时钟周期 20 ns） | 5 周期 | 4 周期 |

从 `rtl/` 查看：

```bash
gtkwave test_results/jal_once_before_20261015_222729.vcd \
        test_results/jal_once_before_20261015_222729.gtkw
gtkwave test_results/jal_once_after_20261015_222755.vcd \
        test_results/jal_once_after_20261015_222755.gtkw
```

观察 `if_id_valid` 和 `id_pc` 测量目标到达时间；修改后增加观察
`id_jal_redirect`、`id_jal_target`、`ex_jal_resolved`、`frontend_flush`。
`branch_flush` 仍是 EX 重定向，不能单独用它判断所有 JAL 跳转。

## 重跑

```bash
cd /home/jay/Desktop/graduation_project/rtl
python3 tests/verify_div_merge.py --change jal_id
```

该命令重新编译当前 RTL，生成单跳波形，执行定向断言、暂停注入、ISA、UART、
分支预测、退休计数和 CoreMark。JAL 汇编用 GNU GCC 正确链接为 ELF 后再生成镜像，
确保 `la` 的重定位已解析。

基线复现：

```bash
python3 tests/verify_div_merge.py --change jal_id \
  --baseline-ex test_results/jal_id_20261015_222224_baseline/ex.v \
  --baseline-core test_results/jal_id_20261015_222224_baseline/riscv_core.v \
  --baseline-id-ex test_results/jal_id_20261015_222224_baseline/id_ex_reg.v
```
