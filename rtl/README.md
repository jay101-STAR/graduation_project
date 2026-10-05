# RTL 测试入口

在 `rtl/` 下使用 `./run.sh`。也可从项目根目录使用 `./rtl/run.sh`；
`prepare` 的输入路径相对于调用时的工作目录解析。

|任务|命令|
|---|---|
|帮助|`./run.sh --help`、`./run.sh uart --help`|
|仅编译 RTL|`./run.sh build` 或 `make simv_build`|
|单个 ISA 测试|`./run.sh single rv32ui-p-add`|
|ISA 批量测试|`./run.sh isa 'rv32u[im]-p-*'`|
|UART + ISA 回归|`./run.sh all`|
|UART 全部/单项测试|`./run.sh uart`、`./run.sh uart --test uart_rx_smoke`|
|列出 UART 测试|`./run.sh uart --list`|
|分支预测测试|`./run.sh bp`|
|minstret 汇编测试|`./run.sh minstret`|
|性能基线|`./run.sh perf`|
|指定性能用例|`./run.sh perf --tests 'rv32ui-p-add rv32ui-p-lw rv32um-p-div'`|
|CoreMark|`./run.sh coremark 1`|
|校验已有 CoreMark 日志|`./run.sh check-coremark test_results/coremark_<timestamp>.log`|
|普通基准测试|`./run.sh benchmark multiply`|
|准备 ELF 镜像|`./run.sh prepare ../verification/riscv-tests/isa/rv32ui-p-add`|
|准备汇编/HEX 镜像|`./run.sh prepare vsrc/instrom/instrom.s`|
|使用 GNU 汇编工具链准备镜像|`./run.sh prepare vsrc/instrom/instrom.s --toolchain gnu`|

测试子命令支持 `--build`（强制编译）或 `--no-build`（复用已有 `simv`），
两者互斥。默认在 `simv` 缺失或 RTL 源码更新后编译；`all` 默认强制编译。
`isa` 和 `all` 默认包含 fence.i；显式 `--skip-fencei` 可排除它，摘要会记录排除项。
`SKIP_TEST_REGEX` 可按 ISA 测试名称排除用例，同样记录在摘要中。

测试命令在正常结束、失败、超时、Ctrl+C 或 SIGTERM 时恢复原有
`instrom.hex`、`bank0/1.hex`、`bank0/1.coe`、`bank0/1.mem`。
原本不存在的文件在恢复时移除。不要并行运行多个会改写这些镜像的测试命令。
`prepare` 成功后保留新镜像；准备失败时恢复原镜像。
仿真生成的波形和 `sim.log` 保留，便于 `make verdi` 调试。

汇总与逐用例证据保存到 `test_results/`，使用带微秒的时间戳，避免覆盖历史记录：

- `<mode>_summary_<timestamp>.txt`：用例结果、mcycle/minstret、加权 CPI 和 BP 汇总。
- `<timestamp>_<suite>_<test>.log`：汇编、转换和镜像准备输出。
- `<timestamp>_<suite>_<test>.sim.log`：仿真输出。
- `failed_tests_<timestamp>.txt`：失败或异常的用例。
- `coremark_<timestamp>.log`：CoreMark 仿真输出及 CRC 校验证据。

测试成功需要仿真正常退出且打印 `TEST PASSED`；`TEST FAILED`、`TIMEOUT`、
许可证连接失败、准备失败或无结果均返回非零。BP 测试额外要求有效 BP 统计。
CoreMark 在 `tools/run.py` 内执行 CRC、性能窗口和停顿桶一致性校验，
短迭代结果仅用于性能比较，不视为满足 10 秒运行要求的正式得分。
`check-coremark` 可单独校验已有日志，支持 `--source <core_main.c>` 指定 CRC 参考表；
它不编译或运行仿真，也不修改内存镜像。

环境变量：

|变量|用途/默认值|
|---|---|
|`BP_TIMEOUT_NS`|BP 仿真时间上限，10000000 ns|
|`BP_WALL_TIMEOUT_S`|BP 每例墙钟时间上限，120 s|
|`ITERATIONS`|CoreMark 默认迭代数，1；位置参数优先|
|`SKIP_BUILD=1`|CoreMark 复用 simv；显式 `--build` 优先|
|`TB_TIMEOUT_NS`|CoreMark 仿真上限，100000000000 ns；0 不传上限参数|
|`SIM_TIMEOUT`|CoreMark 墙钟时间上限，0 表示不限|
|`UART_PRINT`|CoreMark 必须为 1，以获得 CRC 输出|
|`CORE_FREQ_HZ`|CoreMark 速率估计使用的频率，50000000 Hz|
|`SIM_ARGS`|CoreMark 附加仿真参数，按 shell 引号规则拆成参数，不执行 shell 表达式|

ISA/minstret 每例超时 10 s，UART 30 s，perf 120 s，普通 benchmark 60 s。

`run.sh` 只负责定位并调用 `tools/run.py`。原有独立运行脚本已合并到此实现；
`vsrc/instrom/llvm.sh` 与 `asm2hex.sh` 保留为两种汇编工具链辅助脚本。
要求 Python 3.9+，VCS 和 RISC-V/LLVM 工具链。

验证调度逻辑（不依赖 VCS 许可证）：

```bash
python3 -m unittest discover -s tools -p 'test_run.py' -v
```
