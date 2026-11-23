# AXI4 内部总线、原生 RAM 与 Cache 突发传输

当前生产顶层使用 AXI4：ICache 和 DCache 缺失均通过一笔 16 拍读事务补齐 64 字节；DCache 脏行替换和 clean 使用一笔 16 拍写事务。ICache 读可与 DCache 写回或旁路写并行；DCache 内部仍按写回完成后补行的顺序工作。旁路访问保持单拍。RAM 和 UART 均通过原生 AXI4 从接口连接互连；RAM 直接连接双 bank BRAM，生产路径没有 AXI4→Lite 转换。

取指/数据适配器、LSU、地址属性检查、Cache/旁路、维护控制和 `mem_burst_arbiter`
直接实例化于 `riscv_core`。Core 通过 `mem_rd_* / mem_wr_*` 原生突发接口连接
`top` 中的 `axi4_master`；AXI4 主控、互连、RAM 和 UART 均位于 Core 外部。
具体端口和层级见 [Core 封装边界](core_boundary.md)。

```text
+--------------------------------------------------+
| riscv_core                                       |
| ICache / 取指旁路 ---+                            |
| DCache / 数据旁路 ---+--> mem_burst_arbiter        |
+--------------------------------+-----------------+
                                 | 原生读/写接口
                                 v
                      +---------------------+
                      |     axi4_master     |
                      | AR/R 与 AW/W/B 独立 |
                      +----------+----------+
                                 | AXI4
                                 v
                      +---------------------+
                      |  axi4_interconnect  |
                      |      RAM / UART     |
                      +---------------------+
```

## 接口与支持范围

- 顶层外部端口、Core 请求 ID、LSU 的子字和跨字处理保持原样。支持 `--cache-mode 00/10/01/11`，两位依次控制 ICache 和 DCache。
- 缓存后端 `req_len[7:0]` 表示拍数减一。读请求握手一次，响应逐拍返回 `rdata/error/rlast`；写请求每拍握手一次，`req_wlast` 标记末拍，首拍保存地址和长度，整笔写在 B 握手后返回一次完成响应。原生写数据需要按声明长度完整提供，失败响应前也必须排空。
- 地址和数据宽度均为 32 位，AXI ID 宽度为 1 位，CPU 主桥固定发出 ID=0。Core 的四位 ID 仍由现有入口适配器保存，和 AXI ID 分开。
- 主桥仅产生对齐的 32 位 INCR 访问：`ARSIZE=AWSIZE=2`，`ARLEN/AWLEN=0/15`，`WLAST` 只在声明长度的末拍置位。LOCK/CACHE/PROT/QOS/REGION 固定为零，无 USER 信号。
- RAM 从端支持单拍和 16 拍 INCR 读写；每拍 32 位，地址按 4 字节递增。支持逐拍 WSTRB，包括零掩码空操作，WLAST 必须与 AWLEN 指定的末拍一致。
- 全局最多一笔读和一笔写同时在途。ICache 与 DCache 的读请求按完整读事务轮询；写通道独立服务数据侧，保持到 B 完成。每个缓存侧仍最多一笔事务，DCache 写回结束后才发起自己的补行。读末拍或写响应可与同方向下一请求在同一边沿握手。R 与 B 的有效位、就绪位和错误独立，两侧缓存使用分别打包的响应数据、错误及末拍标志。
- CPU 主桥不实现同方向多笔在途、FIXED/WRAP、窄传输、独占访问、外部 DDR 接口。完整 AXI4 信号接口不代表支持协议中的所有可选事务。

## 模块与访问语义

- `axi4_master` 将原生事务转换为 AXI4。读、写各有独立的 active、地址、长度、错误和 available；原生读请求/响应使用 `rd_req_* / rd_rsp_*`，写逐拍请求/完成使用 `wr_req_* / wr_rsp_*`。当前写事务的后续数据由缓冲空间控制；一拍 W 缓冲同时保存数据、掩码和末拍信息，支持发送旧拍的同一边沿接收下一拍。AW 仅发一次，与 W 独立等待；写数据发完后保持事务直到 B 完成。`mem_burst_arbiter` 仲裁两路读请求并独立转发数据侧写，任何一个方向的背压不会阻止另一方向；`axi4_interconnect` 负责 RAM/UART 的事务归属及未映射地址响应。
- `axi4_ram_slave` 直接实例化两个 `std_bram_tdp`，保留 64 KiB 交错 bank 布局和 HEX 初始化。A 端按 WSTRB 写入，B 端同步读取；无背压时突发读写均可每周期一拍，AR 后下一周期即可返回首个 R 数据拍。RAM 内部与 CPU 主桥均允许一笔读和一笔写在途。
- RAM 用一拍写数据缓冲接收先于 AW 到达的 W；AW/W 分别握手，完整接收后只返回一次 B，B 背压期间不接受下一笔写。R 背压时保存数据，避免后续同地址写改变已发出的读响应；同一边沿读写同字采用 BRAM 的读前写语义。读末拍与下一笔 AR 可以同边沿握手。
- `axi4_uart_slave` 直接接收互连的 AXI4 信号，支持独立 AW/W 到达、B/R 背压及 ID 返回。仅合法单拍请求访问寄存器；不支持的突发完整排空并返回 SLVERR，不触发 TX 或 RX 副作用。UART 路径不再实例化 `axi4_to_axi_lite` 或 `axi_lite_uart_slave`。
- `icache` 保存行首地址，接收全部 16 拍后安装整行；保留 32 KiB、四路、128 组、64 字节行和原有 PLRU。命中响应与下一请求可重叠，无背压热命中每周期一条。
- `icache_phys_word` 和 `dcache_phys_word` 在缩窄物理地址前检查上游访问许可及 Cache 后端地址。UART、tohost 所在整行保持不可缓存，旁路访问不扩展为补行。Cache 补行和 DCache 写回均使用 `len=15`；不可缓存访问和关闭缓存后的旁路使用 `len=0`。

| 地址 | 行为 |
| --- | --- |
| `0x80000000..0x8000ffff` | 原有 64 KiB 双 bank RAM，镜像格式和按字节写语义保持兼容 |
| `0x80001000` | tohost 观察值，按写掩码更新；其所在缓存行使用旁路 |
| `0x10000000..0x1000000f` | UART MMIO，单拍访问 |
| 其他地址 | 互连返回 DECERR，不启动从设备 |

不支持的从接口请求属性返回 SLVERR。被拒绝的读请求按 ARLEN 返回完整数量的错误拍；被拒绝的写请求接收 AWLEN 指定的数据拍后返回一次错误，不写 RAM 或 UART。合法突发不跨 4 KiB 边界；非法请求不能通过缩窄地址访问低位别名。

RAM 发现 WLAST 与 AWLEN 不一致时记录错误，禁止该拍及后续拍写入，仍按 AWLEN+1 排空并返回 SLVERR。此前已写入的字保留，不保证突发写原子性。复位丢弃预收的 W、未完成事务和阻塞响应，并清零 tohost 观察值；已提交的 BRAM 内容保留。

补行任一拍出错时记录失败，继续接收至 LAST，再返回一次上游错误；失败行不安装。`FENCE.I` 等待已接受补行/旧响应排空后失效缓存，维护完成前不接受新取指。总线错误沿模块接口传播，Core 按原始取指/load/store 归属触发精确 access fault，保存 mepc/mcause/mtval，见 [精确访问异常](precise_access_faults.md)。复位取消协议状态和 tohost 观察值，不清除 RAM。

UART 的零 WSTRB 写是成功的空操作；多个字节有效时选择最低有效字节发送。RXDATA 在 AR 时保存返回值，只在成功 R 握手时弹出一个 FIFO 字节；错误读和背压不会提前弹出。读写各保留一笔在途事务，B/R 响应未完成时不接受同方向下一笔事务。

旧 Lite 模块和 `axi4_to_axi_lite` 保留用于兼容与独立测试；生产顶层的 RAM/UART 路径均不再实例化它们。旧文档中逐字 AXI-Lite 补行的描述只适用于升级前版本。

## 复现验证

从 `rtl/` 执行：

```bash
# 原生 RAM、UART、主桥、RAM/UART 互连、整笔仲裁独立单测和波形
python3 tests/run_axi4_units.py

# 单独验证 RAM 的突发读写、AW/W 独立到达、背压、错误和复位
python3 tests/run_axi4_units.py --bench axi4_ram_tb

# 主桥写突发、独立 AW/W 等待、背压、非法命令排空和复位
python3 tests/run_axi4_units.py --bench axi4_write_burst_tb

# 真实 I/D Cache、仲裁器、master、互连和 RAM 的并行写回/补行
python3 tests/run_axi4_units.py --bench cache_bus_parallel_tb --delay 5 --seed 493

# 独立背压、同时 R/B、错误隔离、非法请求排空和复位
python3 tests/run_axi4_units.py --bench axi4_parallel_tb

# 独立检查 CPU 冒烟 VCD 中的读写重叠与拍数
python3 tests/check_axi4_parallel_wave.py test_results/axi4_parallel_cpu11.vcd

# ICache 错误、命中吞吐、维护和旁路单测
python3 tests/run_phys_icache.py

# 四种缓存配置分别执行完整系统回归及性能测量
for mode in 00 10 01 11; do
  python3 tests/run_axi4.py --cache-mode "$mode" --suite all --suite bp \
    --suite minstret --suite axi --suite cache --suite pipeline --suite perf --suite coremark
done

# 指定可复用的构建目录；首次构建后用 --binary 复用模拟器
python3 tests/run_axi4.py --cache-mode 10 --build-dir /tmp/axi4_verify \
  --suite all --suite bp --suite minstret --suite axi --suite pipeline \
  --delay 7 --seed 493

# 保存并独立检查零等待时 CPU 的实际 AXI 补行波形
python3 tests/run_cache.py --cache-mode 10 --suite focused \
  --wave test_results/axi4_cpu.vcd
python3 tests/check_axi4_wave.py test_results/axi4_cpu.vcd

make simv_build
```

随机等待只在测试包装中启用，覆盖五个 AXI 通道以及独立的原生读请求、写逐拍请求、读响应和写响应边界。每通道使用独立种子的单项队列，VALID 一旦发出就保持至握手；`--delay 0` 为直通，不增加队列延迟。ISA/UART/BP/计数器用例不跳过 `fence_i`；成功要求 tohost=1，CoreMark 需通过原有 CRC 验证。此处使用单次迭代进行区间周期比较，不作为满足官方 10 秒要求的正式 CoreMark 得分。

UART 直接接入的验收和波形见 [UART AXI4 验收报告](../test_results/uart_axi4_acceptance.md)。首次总线升级的历史基线及补行统计见 [AXI4 升级记录](../test_results/axi4_acceptance.md)。统计以相同 CoreMark PC 区间的 mcycle/minstret 为主，另列整个程序的计数，避免串口输出时间影响区间比较。

RAM 原生 AXI4 改造的实现范围、突发写波形、四种缓存配置回归及 CoreMark 对比见 [原生 RAM 验收报告](../test_results/native_axi4_ram_20261112_105648_261438/report.md)。
