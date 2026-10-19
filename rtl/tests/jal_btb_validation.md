# JAL 的 IF/BTB 预测验证（2026-10-16）

在先前 ID 提前解析 JAL 的基础上，现有两路 BTB 增加 JAL 类型。
IF 命中 JAL 时直接预测跳转；ID 核对预测目标，正确时保留前端指令，
未预测或目标不匹配时使用原有 ID 重定向。EX 继续完成 PC+4 写回和正常退休。

## 实现

- `vsrc/core/branch_predictor.v`：每条 BTB 记录增加 `btb_is_jal`。
  命中 JAL 后直接预测 taken；条件分支仍使用原有 gshare/PHT。
  JAL 训练只修改 BTB，不改变 PHT 或 GHR。
- `vsrc/core/riscv_core.v`：ID 使用原始 IF 预测元数据核对目标。
  `id_jal_advance` 表示 JAL 被正常处理；`id_jal_redirect` 仅表示需要纠错。
  ID/EX 的已处理标志来自 advance，因此正确预测的 JAL 也不会在 EX 重复跳转。
- 训练仅发生在有效 EX 指令被接受时；暂停或气泡不训练，更早的 EX 重定向仍优先。
- FENCE.I 清除 BTB 有效位，避免代码修改后旧的 JAL 记录继续预测。
  复位同样清除有效位，重复复位不会因 epoch 翻转而恢复旧表项。

本次没有改变乘除法周期数、JALR 解析阶段或体系结构返回地址语义。

## 功能验证

本次成功运行使用 Verilator 5.027。重新编译完整 RTL，使用现有系统测试台，
移除不支持的 FSDB 调用并加入 `jal_btb_checks.svh`、`jal_early_checks.svh`。
准备/运行内存镜像持有 `.divider_simulation.lock`，七个原始内存镜像均逐字节恢复。

| 检查 | 结果 |
| --- | --- |
| 预测器单元测试 | 18 项检查 PASS；冷启动、JAL 绕过弱不跳方向计数器、全部 1024 个 PHT 项及 GHR 保持、条件方向预测、目标更新、类型替换、两路表项替换、FENCE.I 优先于训练、重复复位 |
| bp_jal 定向程序 | PASS；59 次有效 JAL 对应 59 次训练，47 次正确预测、12 次 ID 纠正 |
| 连续 JAL 与链接寄存器 | PASS；第一条 JAL 的目标也是 JAL，两条指令都正确写回 PC+4 |
| 冷/热目标到达时间 | PASS；冷启动 4 周期、正确命中 1 周期，共 12 次冷启动/未命中和 47 次命中观测 |
| 错误目标注入 | PASS；一次正确预测元数据被改成错误目标后，由 ID 纠正，程序仍通过 |
| 命中时访存暂停 | PASS；ID 暂停 4 周期、EX 暂停 3 周期，训练仍严格 59 次，退休指令数仍为 241 |
| 原有 JAL 控制冲突与暂停 | PASS；覆盖更早 EX 分支/JALR/异常/MRET/FENCE.I、乘除法等待、load-use 和冷启动访存暂停 |
| 自修改代码/FENCE.I | PASS；JAL 执行两次后改成 NOP，FENCE.I 后重新进入该地址，正确顺序执行，不使用旧 JAL 目标 |
| 先前 MUL/DIV 依赖汇编 | 两项 PASS |
| 官方 JAL/JALR 单项 | 各 1/1 PASS |
| 分支预测测试 | 6/6 PASS，包含新加入的 `bp_tests/bp_jal.s` |
| minstret 测试 | 3/3 PASS |
| 完整 ISA/UART 回归 | 56/56 PASS，0 跳过，包含 fence_i |
| CoreMark | 前后 CRC 与测量计数一致性均 PASS |

证据路径以 `rtl/` 为根：

- `test_results/jal_btb_20261016_095622/baseline_run.log`
- `test_results/jal_btb_20261016_095622/complete_run.log`
- `test_results/jal_btb_20261016_095622/fence_validation_run.log`
- `test_results/jal_btb_unit_verilator_20261016_100510.log`
- `test_results/jal_btb_after_wrong_target_20261016_100753.log`
- `test_results/jal_btb_after_warm_stalls_20261016_100753.log`
- `test_results/jal_btb_after_jal_btb_fence_20261016_100753.log`
- `test_results/bp_summary_20261016_100627_979014.txt`
- `test_results/minstret_summary_20261016_100632_229290.txt`
- `test_results/all_summary_20261016_100633_309954.txt`

## CoreMark 对比

同一编译配置、同一模拟器、1 次迭代，函数测量区间为
`0x80002970` 至 `0x8000297c`。这是短时比较，未满足正式 CoreMark 的时长要求。
基线已经包含 MUL/DIV N+2 与 JAL 的 ID 提前解析，仅回退本次两个 RTL 文件。

| 指标 | ID 提前解析基线 | 增加 JAL BTB 预测 |
| --- | ---: | ---: |
| 区间 mcycle | 389399 | 373022 |
| 区间 minstret | 287265 | 287265 |
| 区间 CPI | 1.3555 | 1.2985 |
| MUL 暂停 | 37584 | 37584 |
| DIV 暂停 | 0 | 0 |
| load-use 暂停 | 21737 | 21737 |
| EX 重定向事件 | 6531 | 6555 |
| 全程序条件分支预测错误 | 5035 | 5056 |
| 全程序条件分支预测准确率 | 91.20% | 91.16% |

区间减少 16377 周期，即 4.21%；相同时钟频率下执行速度提高约 4.39%。
条件分支与 JAL 共享 BTB 会产生表项竞争，实际数据中条件分支预测错误略有增加，
总周期仍明显下降。最后两行是全程序统计，不能与区间 EX 事件直接相减。
`redirects` 仅统计 EX 重定向，JAL 的 ID 纠正不包含在内。

原始 CoreMark 日志：

- 基线：`test_results/coremark_20261016_100324_712681.log`
- 修改后：`test_results/coremark_20261016_100658_322632.log`

尚未执行目标平台综合或静态时序分析，不能据仿真时钟承诺实际 Fmax。
需要后续检查 BTB 类型选择到 PC、ID 预测核对到冲刷控制，以及有效位清除路径。

## 波形

VCD 已直接解析，检查结果保存在
`test_results/jal_btb_20261016_095622/wave_summary.txt`；不是 GUI 目测或预估。
测试台日志在时钟沿后 1 ns 采样。

| 同一被测 JAL | 基线进入 ID → 目标进入 ID | 修改后进入 ID → 目标进入 ID |
| --- | --- | --- |
| 第一次执行，冷启动 | 410 → 490 ns，4 周期 | 410 → 490 ns，4 周期 |
| 第二次执行，BTB 已训练 | 670 → 750 ns，4 周期 | 670 → 690 ns，1 周期 |

从 `rtl/` 打开：

```bash
gtkwave test_results/jal_btb_before_bp_jal_20261016_100254.vcd \
        test_results/jal_btb_before_bp_jal_20261016_100254.gtkw
gtkwave test_results/jal_btb_after_bp_jal_20261016_100623.vcd \
        test_results/jal_btb_after_bp_jal_20261016_100623.gtkw
```

观察 `if_id_valid`、`id_pc`、`if_id_predicted_taken`、`if_id_predicted_pc`、
`id_jal_prediction_ok`、`id_jal_redirect`、`frontend_flush`、`ex_jal_resolved`。
命中正确时，prediction_ok 为 1，JAL 不引发 frontend_flush，目标指令紧跟进入 ID。

## 使用 VCS 重跑

标准入口仍然是 `run.sh`：

```bash
cd /home/jay/Desktop/graduation_project/rtl
./run.sh single rv32ui-p-jal --build
./run.sh single rv32ui-p-jalr --no-build
./run.sh bp --no-build
./run.sh minstret --no-build
./run.sh all --no-build
./run.sh coremark 1 --no-build
```

运行附加的单元检查、错误目标/暂停注入和自修改代码检查：

```bash
python3 tests/verify_jal_btb.py
```

此脚本默认使用 VCS，复用 Makefile 中的编译选项；不会自动切换模拟器。
本次 `./run.sh single rv32ui-p-jal --build` 仍报
`Cannot connect to the license server` / `Failed to obtain license`，
因此没有声称完成 VCS 功能验证。编译失败时不能继续使用旧 simv 代表新 RTL。
相关记录是 `test_results/simv_build_20261016_100511_289937.log`。

显式选择本次可用的模拟器：

```bash
python3 tests/verify_jal_btb.py --simulator verilator
```

同工具基线复现：

```bash
python3 tests/verify_jal_btb.py --simulator verilator \
  --baseline-dir test_results/jal_btb_20261016_095622
```
