# C0：Cache 接入边界与地址属性

实现日期：2026-10-23。C0 已建立 Cache 字接口、物理地址边界、属性译码、关闭模式和维护协议。没有实现 Cache 数据阵列、Tag、命中、补行或 MMU；ICache 独立实现从 C1 开始。

后续进度：I/D Cache 已接入，物理字适配器分别位于 `icache_phys_word.v`、
`dcache_phys_word.v`，共用旧文件已移除。当前配置见 [ICache 接入 CPU](icache_cpu_integration.md)
和 [DCache 接入 CPU](dcache_cpu_integration.md)。本页其余部分保留 C0 阶段的接口与历史配置说明。
2026-11-04 整理地址检查职责：本页的关闭模式接口沿用，上游统一生成完整访问许可，
`phys_word_adapter` 使用该结果执行请求，不再重复属性解码。

## 实际连接

```text
Core IF -> fetch_mem_adapter ---------> cache_ports[0]
Core D  -> data_adapter -> data_lsu --> cache_ports[1]

每侧 cache_ports[n]：
  32 位字接口
    -> addr_translate_bypass：32 -> 34 位零扩展
    -> mem_attr_decode + top.v：统一生成 access_ok / req_cacheable
    -> cache_word_bypass：当前关闭模式，未来替换成 ICache/DCache
    -> phys_word_adapter：根据 access_ok 放行或报错，34 -> 32 位
    -> word_arbiter -> AXI4-Lite -> RAM / UART
```

响应沿相反方向返回。`top.v` 中 `cache_cpu_*` 是适配器/LSU 一侧的 32 位接口；每个生成实例中的 `phys_addr` 是 Cache 输入地址，`mem_addr` 是 Cache 后端地址；`word_s_*` 仍是原仲裁器的两路来源。`fetch_mem_adapter` 的返回缓冲、数据适配器及 LSU 的内部行为均未改动，Core 四位请求 ID 仍由适配器保存。

属性译码是组合逻辑，画图中的箭头不表示寄存器或新的流水级。

## 文件与职责

| 文件 | 实现内容 |
| --- | --- |
| `vsrc/mem/addr_translate_bypass.v` | `phys_addr = {2'b00, effective_addr}`，不翻译页表、不检查页权限 |
| `vsrc/mem/mem_attr_decode.v` | 对完整 34 位 PA 判断映射、执行许可、缓存许可、整行缓存许可及 MMIO |
| `vsrc/cache/cache_word_bypass.v` | 关闭模式直通；单请求对应关系；维护接收/完成分离；响应来源标记 |
| `vsrc/mem/phys_word_adapter.v` | 使用上游完整访问许可；合法请求无额外流水级，拒绝请求本地错误应答 |
| `vsrc/top.v` | 两侧模块实例、完整物理地址属性与对齐/访问种类组合、独立配置与维护连线 |
| `tests/cache_checks.svh` | Cache 字请求/响应配对、背压稳定、来源与属性检查 |
| `tests/run_cache.py` | C0 单测及现有 SoC 回归入口，支持随机等待与波形 |

## 固定的字接口协议

请求包含 `req_valid/ready`、`req_addr`、`req_write`、`req_wdata[31:0]`、`req_wstrb[3:0]`。Cache 物理地址宽度是 34 位；现有上下游有效地址/AXI 地址仍为 32 位。地址必须按 4 字节对齐，读请求的字节提取、符号扩展和跨字拼接由 LSU 完成。

响应包含 `rsp_valid/ready`、`rsp_rdata[31:0]`、`rsp_error`。读和写都必须返回响应。

- `req_valid && req_ready` 才接收请求；接收后请求方可以改变输入。
- `rsp_valid && rsp_ready` 才消费响应，不能把请求接收等同于访问成功。
- 任一通道被背压时，发送方保持 VALID 和全部字段，直到握手或复位。
- 每侧最多一个未完成字请求；旧响应消费和新请求接收允许在同一沿发生。
- 已接收请求恰好完成一次；复位可以取消在途事务。复位时不对外握手。
- 合法请求/响应组合直通。后端必须至少在请求接收后的下一周期返回响应，不支持请求与其自身响应在同一沿发生。

`cache_word_bypass` 与 `phys_word_adapter` 的 pending 位只管理归属，不额外寄存合法请求或返回数据。未映射、未对齐、不允许执行和高位非法请求，接收后下一周期返回零数据与错误；该错误响应可被背压。

`cpu_rsp_source[1:0]` 是观测用的响应来源，与响应一起保持稳定：`00` 错误、`01` 旁路、`10` 命中、`11` 补行。C0 只产生前两种。后续控制器需在真实命中或整行成功后生成相应来源，配合 C1/C3 的阵列及补行检查，不能只改标记绕过验证。

## 地址属性

| 完整物理范围 | addr_valid | executable | cacheable / line_cacheable |
| --- | --- | --- | --- |
| `0x0_80000000..0x0_8000ffff`，除测试出口行 | 1 | 1 | 1 / 1 |
| `0x0_80001000..0x0_8000101f` | 1 | 1 | 0 / 0 |
| `0x0_10000000..0x0_1000000f` | 1 | 0 | 0 / 0，is_mmio=1 |
| 其余，包括高两位非零的低位别名 | 0 | 0 | 0 / 0 |

译码器判断完整物理字节地址属性，不检查对齐；`top.v` 的 `access_ok` 再结合字对齐、取指可执行和禁止取指写入，`req_cacheable = access_ok && cacheable && line_cacheable`。高位地址别名在完整 PA 属性解码时被拒绝。`phys_word_adapter` 直接根据该完整许可，在缓存查询和地址截取前放行或返回错误；内部不再实例化另一份属性译码器。独立使用该适配器的调用方也必须提供同样的完整许可。

`TOHOST_ADDR` 默认 `0x0_80001000`，`LINE_BYTES` 默认 32，测试出口排除区间按行向下对齐并覆盖整行；单测另用 64 B 行和非行首 TOHOST_ADDR 验证。`line_cacheable` 对整行起止位置及特殊行重叠进行检查，不能只检查请求字。未来改变 RAM/UART 映射必须同步修改物理译码、后端译码和相关边界预检。

C0 所有有效访问仍是单字旁路，不会补行。后续 Cache 必须让不可缓存访问走单字通路，不能预读 UART；写 tohost 的副作用仍只在原 RAM 提交处发生。LSU 现有全访问范围/跨字检查保持不变。

## 维护与配置

每侧预留独立 `maint_req_valid/ready` 与 `maint_done_valid/ready`，本轮操作定义为整 Cache 失效。接收只表示开始，不表示维护完成。

关闭模式没有缓存有效位：没有在途字请求、没有待确认完成且没有上游 word VALID 时，才能接受维护；下一周期置 DONE 并保持到确认，DONE 未确认期间不接受正常字请求。字请求优先于维护，确保维护到来时不会撤回已被后端背压的请求。调用者需要停止发出新的字请求，消费完旧响应后维护才能被接收。

本轮在 `top.v` 将维护请求接 0、完成 READY 接 1；独立单测已经验证协议。Core `fence.i` 到维护接口的连接、前端排空/作废、Valid 扫描与重定向属于 C2，当前 `fence.i` 保持原来的无 Cache 行为。维护端口不表示已经实现这些 Core 控制。

`top` 新增 `ICACHE_ENABLE=0`、`DCACHE_ENABLE=0`，参数在实例化时固定，不支持运行中切换。C0 的有效运行模式仅 `00`。`run_cache.py --cache-mode 10/01/11` 明确拒绝；直接将 RTL Cache 参数设为非零也会在仿真开始时报错，不能把直通执行算作开启 Cache。C2、C4 分别加入真实控制器后再开放对应模式。

访存错误在字接口返回，当前 Core 精确访存异常仍待 C5。未来 MMU 还要迁移适配器/LSU 的有效地址范围检查、处理跨页翻译、权限、异常与页表遍历，不能只替换零扩展模块。

## 验证方法

在 `rtl/` 下执行：

```bash
# C0 单测 -> 取指/load/store/fence.i/乘除法定向 -> RAM/UART 子系统
python3 tests/run_cache.py

# 单测后执行完整零等待回归
python3 tests/run_cache.py --suite focused --suite axi --suite pipeline \
  --suite minstret --suite all --suite bp --suite perf --suite coremark \
  --wave test_results/c0_soc_zero.vcd

# 复用上一步二进制，对适配器/AXI 主桥注入 0..7 周期等待
python3 tests/run_cache.py --binary /tmp/cache_c0_verilator/Vtestbench \
  --delay 7 --seed 493 --suite focused --suite axi --suite pipeline \
  --suite minstret --suite all --suite bp --wave test_results/c0_soc_waits.vcd
```

`run_cache.py` 在原生 AXI 主桥和数据适配器边界注入等待，不向可综合 RTL 添加随机逻辑。完整 CPU 仿真包含既有原生握手、AXI 通道稳定/路由检查，以及新的 Cache 字接口检查。关闭 ICache 时，仍保留「每个 CPU 指令响应完成一次 AXI 读」的检查；开启后的来源检查需要随真实 Cache 控制器扩展。

地址单测检查全部 65536 个 RAM 字节、UART 全窗口、区间前后边界、高两位别名和参数化 tohost 行。字边界单测分别运行数据/指令端口，覆盖全部写掩码、UART 与 tohost 单字访问、非法访问无下游请求、后端读写错误、请求/响应背压、旧响应与新请求同周期交接、维护与受阻请求/响应、完成背压以及复位取消。负向配置测试必须观测到预期拒绝。

## 本次验收结果

使用 Verilator 5.027 和现有 RISC-V GCC。可综合 `top` lint 无警告，见 [lint 日志](../test_results/c0_lint_20261023.log)。

| 验证 | 结果与证据 |
| --- | --- |
| 地址、I/D 字边界、提前启用负向检查，以及主桥/取指适配/RAM/LSU | [8 项全部通过](../test_results/c0_units_20261023_105643_688747.json)，另有原数据适配器 [单测通过](../test_results/p1_unit_20261023_105650_779955.log) |
| 零等待 CPU 回归 | [82/82](../test_results/p1_run_20261023_105650_779955.json) |
| 随机等待 0..7，seed=493 | [75/75](../test_results/p1_run_20261023_110031_131589.json) |
| UART 与 ISA 全集 | [零等待 56/56](../test_results/all_summary_20261023_105709_359108.txt)、[随机等待 56/56](../test_results/all_summary_20261023_110033_861911.txt)，含 `fence_i`，无跳过 |
| 同窗口性能与配置对照 | [自动核对结果](../test_results/c0_acceptance_20261023.json) |

字边界单测统计中的 requests 比 responses 多 2，是专门被复位取消的两个请求；复位测试前，已检查请求与响应数量相等。整机结束时允许有一条尚未返回的推测取指；每个已返回响应的归属仍由断言逐次检查。

本次修改前重新构建并运行了 [基线](../test_results/p1_run_20261023_104809_945152.json)，五项 ISA 定向的 mcycle/minstret/CPI 均与 C0 后一致。CoreMark 使用相同编译选项、一次迭代和 start_time～stop_time 区间：

| 指标 | 修改前 | C0 后 |
| --- | ---: | ---: |
| mcycle | 593825 | 593825 |
| minstret | 287265 | 287265 |
| CPI | 2.0672 | 2.0672 |

[修改前 CoreMark](../test_results/coremark_summary_20261023_104831_279743.txt)、[修改后 CoreMark](../test_results/coremark_summary_20261023_105724_326200.txt) 均通过 CRC 和计数器一致性检查。该结果是短程性能对照，未测综合时序/Fmax。

波形证据：

- 整机零等待：[VCD](../test_results/c0_soc_zero_20261023.vcd)、[GTKWave 会话](../test_results/c0_soc_zero_20261023.gtkw)、[前 64 次字接口取指](../test_results/c0_soc_zero_20261023.fetch.csv)、[时延统计](../test_results/c0_soc_zero_20261023.summary.json)。该 lw 用例观察到 368 次返回，Cache 上游字接口接受到消费响应为 1 周期，最短接受间隔 1 周期；不代表每条 CPU load 都只需要一周期。
- 整机随机等待：[VCD](../test_results/c0_soc_waits_20261023.vcd)、[GTKWave 会话](../test_results/c0_soc_waits_20261023.gtkw)。
- 数据字边界：[VCD](../test_results/c0_boundary_1_20261023_105643_688747.vcd)，包括非法高 PA、错误返回和维护完成背压；取指字边界：[VCD](../test_results/c0_boundary_2_20261023_105643_688747.vcd)。

C0 验收完成，默认配置保持两 Cache 关闭。下一步是 C1 的 ICache 独立模块与补行单测。
