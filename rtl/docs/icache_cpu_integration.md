# ICache 接入 CPU

`top` 默认 `ICACHE_ENABLE=1`、`DCACHE_ENABLE=0`。缓存主体位于
`rtl/vsrc/cache/icache.sv`，由正式 RTL 源文件列表编译；`rtl/tests/` 保留测试平台和脚本。
两个参数传入 `riscv_core`，取指适配器、地址检查、Cache/旁路和仲裁器均在 Core 内部直接连接。
ICache 保留 32 KiB、四路、128 组、64 字节行的配置。

```text
+------------------------------------------------------+
| riscv_core                                           |
| IF -> fetch_mem_adapter -> 地址转换与属性解码         |
|                                  |                   |
|                                  v                   |
| icache_phys_word：可缓存请求进入 icache               |
|                  不可缓存请求旁路，非法请求返回错误   |
|                                  |                   |
|                                  v                   |
|                         mem_burst_arbiter             |
+----------------------------------+-------------------+
                                   | 原生读/写接口
                                   v
                       +------------------------+
                       | 外部 axi4_master       |
                       | AXI4 互连、RAM、UART   |
                       +------------------------+
```

数据通道经独立数据适配器接入 LSU，关闭 DCache 时保留 `cache_word_bypass`。设置 `ICACHE_ENABLE=0` 可恢复取指旁路；
DCache 已通过独立的 `dcache_phys_word` 接入，配置和维护顺序见 [DCache 接入说明](dcache_cpu_integration.md)。

上层实例化时可用 `top #(.ICACHE_ENABLE(1))` 开启 ICache，或
`top #(.ICACHE_ENABLE(0))` 关闭；该参数在编译展开时选择硬件，并非运行时寄存器。
测试脚本对应使用 `--cache-mode 10`（开启）与 `--cache-mode 00`（关闭）。

`icache_phys_word` 的 `req_* / rsp_*` 面向上游，`mem_*` 面向仲裁器。
`mem_attr_decode` 对完整 34 位物理地址计算属性，`riscv_core.v` 再结合字对齐、取指可执行及
禁止取指写入，生成完整的 `req_access_ok`；`req_cacheable` 进一步要求整行可缓存。
`icache_phys_word` 直接使用这两个结果，不再重复解码 CPU 地址或检查同一组权限。
普通字访问实例也使用 `req_access_ok`；`req_cacheable` 仅在开启 ICache 时选择缓存或旁路。
独立实例化适配器时，调用方必须提供同样完整的许可，并在请求被阻塞时保持地址、
读写字段和属性稳定。被接收请求的许可结果由控制状态保存，不受下一请求属性变化影响。

## 接入改动

- `Makefile` 与 Verilator 系统测试自动收集 `vsrc/` 下的 `.v`、`.sv`，包含
  `vsrc/cache/icache.sv`，不再单独添加旧的 `tests/icache.sv` 路径。
- 缓存主体保留 Tag/Data/PLRU 和原有补行流程。命中路径允许在 `CHECK` 中同时返回旧结果、
  接收新地址并发起查询；有新请求时保持 `CHECK`，否则回到 `IDLE`。
- 指令接入逻辑独立位于 `icache_phys_word.v`，只保留 `ICACHE_ENABLE` 参数。
  数据接入逻辑位于 `dcache_phys_word.v`，只保留 `DCACHE_ENABLE` 参数；
  不再使用共用的物理字适配器或 `INSTRUCTION_PORT` 混合选择。
- CPU 请求的完整物理地址、对齐及访问种类检查集中在 `mem_attr_decode` 和 `top.v`；
  `icache_phys_word` 根据 `req_access_ok` 在查询或旁路前拒绝非法请求，
  根据 `req_cacheable` 选择缓存或旁路。适配器保留对生成的补行地址的独立检查：
  必须字对齐，且保持在已批准请求的同一物理行内；
  后端统一输出32位地址，直接接仲裁器，不再串接第二个物理字适配器。
  已接受请求的地址由相应路径保存，响应在接收前保持。
- 指令适配器处理后端错误，失败补行先排空到最后一拍，
  再复位指令缓存主体清除部分补行及所有 Valid，最后返回错误。该恢复策略会丢弃其他有效行，
  但下一次访问可以重新补行。
- `FENCE.I` 在较老访存完成、EX 接受时产生维护请求，同时刷新原有前端和预测器。
  接入层立即阻止新的缓存请求，等待旧取指完成后清除缓存，再允许重定向后的取指。
  维护不取消已被后端接受的字访问，因此旧补行不会在失效完成后重新安装。
- 返回来源：`00` 错误、`01` 旁路、`10` 命中、`11` 补行。

## 连续命中时序

在预热命中、上游持续请求且能接收响应时，请求在边沿 N 接收，响应在边沿 N+1 接收；
同一边沿还可接收下一请求。因此首条延迟一周期，之后每周期返回一条指令。
`array_addr` 在请求握手时选择新地址，补行及重查仍使用保存地址；响应阻塞时不接收新请求，
保持原有 `inst`、`hit` 和请求地址。

`icache_phys_word` 的 `CACHED` 状态也支持同拍交接，并在新请求被接收时更新保存地址和
`refilled` 来源标记。连续交接仅接受合法可缓存请求；不可缓存或非法请求等待 `IDLE`，
继续执行原来的旁路或错误处理。维护请求阻止新交接，等待旧响应完成后失效缓存。
缺失补行仍等待全部 16 个数据拍完成，再通过 `RESP` 返回。

`phys_icache_tb.sv` 包含跨组、跨 Tag、不同字偏移的 128 条连续命中测试，断言每个请求和
响应都没有空拍；另覆盖流中的响应背压、命中后缺失/旁路/非法请求/补行错误，以及
保持新请求时发起失效维护。测试期间记录 `[ICACHE-STREAM]` 的周期数和同拍交接次数。

外层错误已返回到现有 `fetch_mem_adapter` / `if_rsp_error` 接口。本次没有实现 CPU
精确 instruction-access-fault trap；原 CPU 的这条异常闭环仍属于后续工作。

## 重复验证

从 `rtl/` 运行：

```bash
python3 tests/run_phys_icache.py
python3 tests/run_cache.py --cache-mode 10 --suite all --suite bp --suite minstret \
  --suite coremark --build-dir /tmp/icache_cpu_on
```

加入随机等待：

```bash
python3 tests/run_cache.py --cache-mode 10 --suite all --suite bp --suite minstret \
  --suite coremark --delay 3 --seed 493 --build-dir /tmp/icache_cpu_delayed
```

`--cache-mode 00` 验证旁路配置；不同模式使用不同的构建目录。`--binary` 只能复用对应模式的
二进制，不能用旁路二进制验证启用缓存的配置。CoreMark 这里运行一轮并验证 CRC，属于短程比较，
不是满足十秒规则的正式分数。

VCS 仍可使用 `make simv_build`、`./run.sh all --build`，但需要可用的 VCS 许可证服务。
旧 `run_icache.py` / `icache_unit_tb.sv` 测试的是原先的阵列端口，不能用来验证当前握手控制器；
当前使用 `run_phys_icache.py` 和系统回归。

## CPU 波形

```bash
python3 tests/run_cache.py --cache-mode 10 --suite focused \
  --wave test_results/icache_cpu.vcd --build-dir /tmp/icache_cpu_wave
gtkwave test_results/icache_cpu.vcd
```

查看 `TOP.testbench.top.u_core.g_icache.physical_port.with_icache` 下的接入状态机及 `cache`
下的 `curr_state/cnt/ren/wen/hit/inst`。同时查看 `top.u_core` 内的 `cache_cpu_rsp_source[1:0]`、
`if_rsp_valid/if_rsp_ready`、`icache_invalidate` 和 `cache_maint_req_valid[0]`。

日志、VCD、计数器和回归摘要保存在 `rtl/test_results/`；不要用 `make clean` 删除需要保留的证据。
