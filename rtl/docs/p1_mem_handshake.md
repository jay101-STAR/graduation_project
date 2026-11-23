# P1：请求与响应分离的实现说明

后续进度（2026-10-21）：RAM 后备路径已迁移到 AXI4-Lite，并拆出了 LSU，见 [AXI RAM 说明](axi_lite_ram.md)；当前主桥与取指路径又做了连续握手优化，最新接线、CPI 和验证见 [优化记录](axi_lite_optimization.md)。本文保留 P1 阶段的接线和基线记录。

本次在现有同步 RAM 和 UART 上接入了可变延迟握手。取指和数据访问各允许一笔在途请求，尚未加入 ICache、DCache 或 MMU。这里是 P1 的接口与流水线基础；完整内存访问异常仍需后续接通。

## 1. 接线与握手

```text
取指前端 ── 请求/响应 ── if_adapter   ── 现有同步 RAM 取指端口
MEM 阶段 ── 请求/响应 ── data_adapter ── RAM 数据端口 / UART 桥
```

连接位于 `vsrc/top.v`，适配器位于 `vsrc/bus/mem_req_adapter.v`。以后可以在相同请求/响应边界接入 Cache；当前后备 RAM/UART 接口仍沿用原来的启动、忙和读数据接口。

| 信号 | 意义 |
| --- | --- |
| `req_valid` | CPU 正在提交一笔请求 |
| `req_ready` | 接收端能够保存这笔请求 |
| `req_id` | 当前请求编号；响应原样返回 |
| `req_addr / req_write / req_wdata / req_alucex` | 保存地址、读写方向、写数据和原有访存操作类型 |
| `rsp_valid` | 当前请求已经完成，有一笔响应等待接收 |
| `rsp_ready` | CPU 能够消费响应 |
| `rsp_id / rsp_rdata / rsp_error` | 返回请求编号、结果和错误状态 |

只在时钟上升沿发生握手：

```verilog
wire req_fire = req_valid && req_ready;  // 请求被接收一次
wire rsp_fire = rsp_valid && rsp_ready;  // 完成结果被接收一次
```

例如，第 N 个上升沿 `req_fire=1`，适配器保存请求，并启动一次 RAM/UART 访问。随后 CPU 等待响应；若 UART 尚忙或返回被测试环境延迟，等待可以持续任意多个周期。到第 M 个上升沿 `rsp_fire=1`，这笔访问才完成交接。读和写都返回响应。

`valid=1 && ready=0` 期间，发送方保持 valid 和全部负载字段稳定。四位 ID 只是接口预留，并不表示已经支持 16 笔并发或乱序响应。

## 2. 为什么不会重复访问

适配器用 `pending` 保存“已经接收但还没交付完成”的状态。只有 `req_fire` 才拉高 `backend_start`，所以流水线连续停顿不会重复启动 store 或 UART 读写。

请求被接收后，后备端使用保存的地址、数据和操作类型。CPU 输入即使变化，也不会改变当前事务。当后备端完成但 `rsp_ready=0` 时，适配器保存返回数据和错误位，持续保持 `rsp_valid`，直到响应握手。

当前适配器要求后备访问至少经过一次时钟沿，适用于项目中的同步 RAM 和现有 UART 桥；它不是通用的 AXI 总线主机。

## 3. CPU 内部改动

| 文件 | 改动及目的 |
| --- | --- |
| `vsrc/core/riscv_core.v` | 保存取指元数据、请求状态和数据响应；等待访问完成时保持 MEM 项；用完成条件控制旁路与推进 |
| `vsrc/core/pc.v` | 在请求背压期间仍保存已经生效的跳转目标 |
| `vsrc/core/dataram_wb_reg.v` | 把 load 数据与目标寄存器、valid 一起锁存到 WB |
| `vsrc/core/ex.v` | 较老 load 尚未返回时，禁止用未就绪操作数启动 MUL/DIV |
| `vsrc/core/csr.v` | `minstret` 读取考虑较老、尚在 MEM/WB 的有效项，消除等待时间对读取结果的影响 |
| `vsrc/top.v` | 接入两路适配器，按保存的请求译码 RAM/UART，只在接收请求时启动访问 |
| `vsrc/testbench.v` | 性能停顿统计增加核心内部的访存等待 |

### 取指重定向

前端先保存 PC 和预测信息，再发出稳定的请求。没有指令响应时，前端送入无效项，后端已有指令继续执行；取指等待没有直接变成全流水线冻结。

发生分支修正、直接跳转或 `fence.i` 重定向时，当前旧请求标记为 `killed`。即使旧请求正在等待 `req_ready`，也继续完成握手，并吸收它最终的响应；旧响应不再进入有效指令流。处理完旧请求后，再取新目标。这避免了重定向破坏请求协议，也避免旧指令混入新路径。

### 数据访问与 WB

MEM 中一条访存指令只发出一次请求。响应到达前，MEM 和上游保持；到达后才允许该项前进。若响应到达时还存在乘除法等停顿，先单独保存响应，不要求整个流水线恢复才能接收它。

WB 保存 load 数据，不再直接使用实时外部读数据。WB 项在停顿期间可以提交一次，并继续保留数据供旁路；`wb_consumed` 阻止重复寄存器写入和重复增加 `minstret`。分支、CSR 写入和 trap 也以 EX 真正前进为条件，避免同一项在等待期间重复产生副作用。

CSR 指令在 EX 读取 `minstret` 时，会补入较老 MEM 项和尚未提交的 WB 项；实际计数器仍只在 WB 提交时增加。EX 被较老访存阻塞时，这个读取结果不会前进，因此未完成的访问不会让年轻 CSR 提前提交。这符合 [Zicsr 对计数器读取时点的规定](https://docs.riscv.org/reference/isa/unpriv/zicsr.html)。未来增加异步中断、内存异常或乱序执行时，需要重新结合精确提交边界设计这一部分。

## 4. 验证与复现

本机 VCS 编译遇到许可证服务器连接失败，因此实际功能验证使用 Verilator 5.027。原有 VCS 构建入口保留，许可证恢复后仍需运行该工具链检查。

从 `rtl/` 执行：

```bash
# 编译适配器单测和带握手断言的完整 CPU；运行零额外等待测试。
python3 tests/run_mem_handshake.py \
  --suite focused --suite pipeline --suite minstret --suite perf --suite coremark

# 复用刚编译的模拟器，注入 0..7 周期请求等待和响应等待。
python3 tests/run_mem_handshake.py \
  --binary /tmp/p1_handshake_verilator/Vtestbench \
  --suite minstret --suite pipeline --suite all --suite bp --suite coremark \
  --delay 7 --seed 493

# 更长等待、另一随机种子，保存第一个用例的波形。
python3 tests/run_mem_handshake.py \
  --binary /tmp/p1_handshake_verilator/Vtestbench \
  --suite focused --suite pipeline --suite minstret \
  --delay 15 --seed 7919 --wave test_results/p1_redirect_wait_20261020.vcd

# 原有乘除法完成保持与一次启动检查。
python3 tests/run_mul_once.py
python3 tests/run_div_once.py --stall-tests
```

测试驱动会恢复原来的内存镜像，并使用现有回归锁串行访问镜像。`--delay` 范围为 0..15，`--seed` 范围为 1..65535。等待注入只存在于 `tests/mem_req_delay.v` 中，不进入生产 RTL。各次仿真的配置、状态和日志路径记录在 `test_results/p1_run_*.json`。注入等待时自动延长仿真时限；调用者设置的 `BP_TIMEOUT_NS` 优先。

适配器单测覆盖读写、后备忙、响应背压、返回数据与错误保持，以及一次请求只启动一次后备访问。CPU 断言检查请求和响应在背压期间稳定、请求/响应 ID 配对、单笔在途、后备启动与请求接收一致、WB 不重复提交。

最终版本验证结果：

| 检查 | 结果与证据 |
| --- | --- |
| 适配器单测 | PASS；[日志](../test_results/p1_unit_20261020_235114_540219.log) |
| 零额外等待：5 项定向 ISA、4 项流水线集成、3 项计数器、6 项性能测试、CoreMark | 全部 PASS；[运行清单](../test_results/p1_run_20261020_235114_540219.json) |
| 0..7 周期随机等待：UART + ISA | 56/56 PASS，含 `fence_i`，无跳过；[汇总](../test_results/all_summary_20261020_235204_311390.txt) |
| 同一随机配置：分支预测 | 6/6 PASS；[汇总](../test_results/bp_summary_20261020_235218_892139.txt) |
| 同一随机配置：计数器、流水线集成与 CoreMark | 全部 PASS，CoreMark CRC 正确；[运行清单](../test_results/p1_run_20261020_235202_934756.json) |
| 0..15 周期随机等待，种子 7919：5 项定向 ISA、4 项流水线集成、3 项计数器 | 12/12 PASS；[运行清单](../test_results/p1_run_20261020_235300_063252.json) |
| 原有乘法完成保持检查 | 5/5 PASS；[汇总](../test_results/mul_wave_summary_20261020_235202.txt) |
| 原有除法完成保持检查 | 8/8 PASS；[汇总](../test_results/div_wave_summary_20261020_235247.txt) |
| 最终生产 RTL lint | PASS，无警告；[日志](../test_results/p1_lint_20261020_235542.log) |

0..15 周期等待波形见 [取指与访存波形](../test_results/p1_redirect_wait_20261020.vcd)，配有 [GTKWave 信号配置](../test_results/p1_redirect_wait_20261020.gtkw)。重点查看 `core_instrom_ren/if_req_ready`、`if_rsp_valid/if_rsp_ready`、`if_request_killed`、`frontend_flush`、`data_req_valid/data_req_ready`、`data_rsp_valid/data_rsp_ready`、`mem_wait`、`data_response_saved`、`retire_pulse`。

早期验证曾出现两项分支测试超时，以及随机等待下的计数器测试失败：前者通过按等待长度延长仿真预算解决，后者通过修正 `minstret` 的读取边界解决。原始失败日志保留，以上表格引用修正后的最终结果。

## 5. 性能与当前边界

同一工具链、同一 CoreMark 一次迭代、相同 `start_time` 到 `stop_time` 计算区间，不注入额外等待：

| 版本 | mcycle | minstret | CPI |
| --- | ---: | ---: | ---: |
| 修改前 | 373022 | 287265 | 1.2985 |
| 当前握手版本 | 686309 | 287265 | 2.3891 |

证据：[修改前](../test_results/coremark_summary_20261020_234803_807187.txt)、[当前版本](../test_results/coremark_summary_20261020_235138_548565.txt)。两者计算区间退休指令数相同；整个程序退出时的计数会受退休点与测试结束时机影响，不用它推导性能提升。一次迭代仅用于短程比较，不满足 CoreMark 正式分数的运行时长要求。

当前版本有明确的性能回退：单笔阻塞取指在请求之间增加空隙，RAM 数据访问也需要显式等待响应。握手协议本身允许流水化；后续应在保持协议的前提下增加取指队列、响应消费与下一请求并行，以及 Cache 命中路径吞吐优化。不能把本次 P1 当作性能优化已经完成。

此外需要明确：

- 当前仍传递原有 `req_alucex`，非对齐拼接和符号扩展留在旧 RAM 中。P2 才拆出 LSU，改用原始字接口与字节写掩码。
- 数据后备地址译码可以产生 `rsp_error`，UART 错误也会返回；适配器能保存错误，验证环境会立即报错。当前取指错误输入固定为零，CPU 也尚未将数据错误转成精确的访问故障 trap，当前实现不能声称已支持完整内存异常。
- MMU、Cache 行补充、失效维护、多笔在途和乱序响应尚未实现。当前四位 ID、取指作废标记和结果保存是后续接入所需的接口基础。
