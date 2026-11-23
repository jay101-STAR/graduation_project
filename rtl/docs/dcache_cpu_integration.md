# DCache 接入与物理字适配器拆分

指令侧使用 `vsrc/mem/icache_phys_word.v`，数据侧使用
`vsrc/mem/dcache_phys_word.v`。原共用文件已移除；旧文件含未完成 DCache 草稿的
完整内容保存在本次 `test_results/dcache_cpu_integration_*/before/` 快照中。

`top.v` 保留两个独立编译期开关。默认仍为 `ICACHE_ENABLE=1, DCACHE_ENABLE=0`；
两个参数传入 `riscv_core`，适配器、LSU、地址检查、Cache/旁路和仲裁器均在 Core 内部。
现在可以启用正式的 `vsrc/cache/dcache.sv`。`tests/dcache.sv` 是历史测试副本，
不参与系统编译，也没有同步修改。

## 数据路径

Core 内部的数据请求依次经过 `mem_req_adapter`、LSU、地址/整行属性检查、DCache 或字旁路、
仲裁器，再通过原生读/写接口连接外部 `axi4_master` 和 AXI4 系统。

- DCache 保留 32 KiB、128 组、四路、64 字节行、34 位物理 tag。
- 写策略保留写回、写分配。LSU 继续负责符号扩展和跨字/跨行拆分；Cache 接收对齐字地址与字节掩码。
- UART 与 tohost 所在整个 64 字节行走旁路，写掩码原样保留，不扩展为补行。
- 补行和脏行写回使用 `mem_req_len=15` 的整行事务；写回逐拍使用 `wstrb=4'b1111`。
  `WRITE_MEM_REQ` 逐拍发送 16 个字，末拍握手后进入 `WRITE_MEM_RSP` 等待一次 B 完成响应。
- 总线允许 ICache 补行与 DCache 写回/旁路写重叠；仲裁器和 master 使用独立读、写通道。
  核内后端响应按来源分别打包，R/B 可同周期返回并独立背压。DCache 内部仍每次处理一个请求，
  脏行写回收到成功完成响应后才发出补行，无写回/补行重叠缓冲。
- 新旧请求、缓存/旁路响应以及维护的归属由各自保存的请求和状态机管理。
- 关闭 DCache 时保持原物理字适配器的组合合法通路，不增加请求流水级。

## 错误与维护

后端读失败不会安装部分缓存行；失败请求返回 `rsp_error`。脏行写回失败保留原有
有效数据与 dirty，后续缺失或 clean 可重试，不能通过复位整个 DCache 恢复而丢弃其他脏行。

`FENCE.I` 接受后，Core 内部维护状态机暂停流水线，Cache/总线事务仍可独立推进：

1. DCache 遍历全部组和 way，以 16 拍写突发写回有效脏行。
2. 收到 clean 完成后，再请求 ICache 失效（若 ICache 开启）。
3. 收到维护完成后释放 Core；D-only 模式在 clean 完成后直接释放。

写回每行全部成功后才清除该行 dirty。维护完成响应可被背压。clean 错误向上报告，
核内维护状态机保持暂停并在仿真中明确失败，避免执行陈旧指令；当前 CPU 已接入精确取指/load/store access fault 和 mtval，见 [精确访问异常](precise_access_faults.md)。维护失败路径仍按上述方式停止。

## 验证入口

从 `rtl/` 执行：

```sh
python3 tests/run_phys_icache.py
python3 tests/run_phys_dcache.py
python3 tests/run_axi4_units.py --bench cache_bus_parallel_tb --delay 5 --seed 493
python3 tests/run_cache.py --cache-mode 11 --suite cache --suite focused --suite all
```

`--cache-mode` 的两位依次为 I/D，可取 `00`、`10`、`01`、`11`。
CPU 定向汇编 `cache_tests/dcache_cpu_smoke.s` 覆盖跨字/跨行字节掩码、五路冲突替换、
以及两轮“修改指令 -> FENCE.I -> 执行新指令”。系统测试不跳过 `fence_i`。

CPU 波形中指令适配器位于 `top.u_core.g_icache.physical_port.with_icache`，
数据适配器位于 `top.u_core.g_dcache.physical_port.with_dcache`；查看数据适配器下 `cache`
的 CPU/后端握手、`maint_index/maint_line`、`wb_index/wb_line` 和 dirty 更新。
