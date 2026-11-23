# Core 封装边界

`riscv_core.v` 直接实例化取指/数据适配器、LSU、地址映射及属性检查、
ICache/DCache 或旁路、`FENCE.I` 维护控制和 `mem_burst_arbiter`。
流水线与这些模块通过核内信号连接；模块源码仍按职责保留在 `core/`、`bus/`、
`mem/` 和 `cache/` 目录。

`top.v` 实例化复位同步器、`riscv_core`、`axi4_master` 和 `axi4_subsystem`。
AXI4 主控、互连、RAM 和 UART 均位于 Core 外部。

```text
+---------------------------------------------------------------+
| riscv_core                                                    |
|                                                               |
| Pipeline -> fetch_mem_adapter -> address checks -> ICache      |
|                                                       |       |
| Pipeline -> mem_req_adapter -> LSU -> checks -> DCache  |       |
|                                                  |    |       |
|                       +--------------------------+----+       |
|                       v                                       |
|              +---------------------+                          |
|              |  mem_burst_arbiter  |                          |
|              +----------+----------+                          |
+-------------------------+-------------------------------------+
                          | native read/write requests/responses
                          v
                 +-------------------+
                 |    axi4_master    |
                 +--------+----------+
                          | AXI4
                          v
                 +-------------------+
                 |  axi4_subsystem   |
                 | fabric, RAM, UART |
                 +-------------------+
```

两侧 Cache 均有关闭后的旁路路径。`top` 将 `ICACHE_ENABLE` 和 `DCACHE_ENABLE`
参数传入 Core；两层默认值均为 `1` 和 `0`。

## Core 的原生访存接口

所有接口与 Core 共用时钟及高有效复位。请求、响应均在 `valid && ready` 时握手；
背压期间发送方保持有效位和载荷稳定。读写方向独立，沿用现有仲裁器和主控的时序。

| 端口 | 相对 Core 的方向 | 含义 |
| --- | --- | --- |
| `mem_rd_req_valid/ready` | 输出 / 输入 | 一笔读事务的请求握手 |
| `mem_rd_req_addr[31:0]`、`mem_rd_req_len[7:0]` | 输出 | 起始字节地址、拍数减一 |
| `mem_rd_rsp_valid/ready` | 输入 / 输出 | 逐拍读响应握手 |
| `mem_rd_rsp_rdata[31:0]`、`mem_rd_rsp_error`、`mem_rd_rsp_last` | 输入 | 读数据、错误、末拍标志 |
| `mem_wr_req_valid/ready` | 输出 / 输入 | 逐拍写请求握手 |
| `mem_wr_req_addr[31:0]`、`mem_wr_req_len[7:0]` | 输出 | 写事务地址、拍数减一，首拍被接收时保存 |
| `mem_wr_req_wdata[31:0]`、`mem_wr_req_wstrb[3:0]`、`mem_wr_req_wlast` | 输出 | 每拍写数据、字节掩码、末拍标志 |
| `mem_wr_rsp_valid/ready`、`mem_wr_rsp_error` | 输入 / 输出 / 输入 | 整笔写事务的一次完成响应及错误 |

当前产生的长度为 `0`（单拍旁路）或 `15`（64 字节 Cache 行）。
Core 内的请求 ID 由入口适配器保存；Core 边界使用上述原生事务接口，
外部 `axi4_master` 负责 AXI4 的 AW/W/B/AR/R 通道。
寄存器 tohost 及分支预测统计继续由 Core 输出；RAM tohost 和 UART 由外部子系统提供。

## 维护与观察层级

`FENCE.I` 维护状态机已移入 Core。开启 DCache 时，维护依次执行 DCache clean
和 ICache invalidate，并通过核内 `top_core_mem_stall` 暂停流水线。
这个信号保留旧名，便于现有流水线检查和计数脚本继续使用；它已是核内连线。
Cache 和外部总线继续推进，直到维护完成。

系统仿真的观察路径为：

- `top.u_core.fetch_port`、`top.u_core.data_adapter`、`top.u_core.data_lsu`。
- `top.u_core.g_icache.physical_port`、`top.u_core.g_dcache.physical_port`，或对应旁路分支。
- `top.u_core.word_arbiter`、`top.u_core.word_s_*`、`top.u_core.cache_cpu_*`。
- `top.word_rd_* / top.word_wr_*`：Core 与外部主控之间的连线。
- `top.axi4_master0`、`top.axi4_subsystem0`：外部 AXI4 系统。

系统检查中的层级引用和 CPU 波形解析脚本随封装更新。验证命令见
[AXI4 总线说明](axi4_bus.md) 和 [DCache 接入说明](dcache_cpu_integration.md)。
