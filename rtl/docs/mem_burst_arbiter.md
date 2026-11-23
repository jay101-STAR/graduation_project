# mem_burst_arbiter 读写并行

第 0 路为 ICache/取指旁路，只读；第 1 路为 DCache/数据旁路，可读写。
两个读请求按完整事务轮询，数据侧写使用独立通道。因此可同时进行一笔 ICache 读和一笔 DCache 写。
每个来源仍最多一笔事务，DCache 的写回与补行保持串行。

```text
lane 0 读 ──┐
            ├── read owner / round-robin ── rd_req / rd_rsp ── AXI AR/R
lane 1 读 ──┘
lane 1 写 ────── write active / sending ── wr_req / wr_rsp ── AXI AW/W/B
```

## 接口

缓存侧保留读请求一次握手、写数据每拍握手的协议，`s_req_len` 表示拍数减一。
第 1 路的 `s_req_wlast` 标记写末拍；单拍写自动置末拍。
写通道根据首拍保存的 LEN 统计是否发送完声明的拍数，以便 master 对 LAST 错误排空并报告。

下游使用独立的 `rd_req_* / rd_rsp_*` 与 `wr_req_* / wr_rsp_*`。
读响应有 `rdata/error/last`，写响应只有一次 `valid/ready/error`，在 AXI B 完成后返回。
缓存侧 `s_rsp_rdata[63:0]`、`s_rsp_error[1:0]`、`s_rsp_last[1:0]` 按来源打包，
低位为取指、高位为数据；写完成向数据侧返回零数据和 last=1。
这使 R/B 同周期返回、错误不同或某一侧暂停接收时仍能分别路由。

## 控制与保持

| 控制寄存器 | 作用 | 释放或更新条件 |
| --- | --- | --- |
| `rd_active / rd_owner` | 保存正在读取的来源 | 最后一个读响应握手；新读可同边沿接替 |
| `rd_offer_locked / rd_offer_owner` | 保存被背压的读候选，避免新竞争者改变载荷 | 下游接收读请求 |
| `last_read_owner` | 两路都有读请求时选择上次读来源的另一侧 | 每笔读请求握手更新，写不影响读轮询 |
| `wr_active` | 数据侧写事务仍在途 | 写完成响应握手 |
| `wr_sending / wr_sent / wr_len` | 接收一整笔写数据，允许续拍间隙 | 声明长度的末拍握手，之后仅等待写响应 |

- 两个方向的有效位和就绪位独立，没有全局忙标志。
- 写期间可以接收取指读；读期间可以接收数据写。两个读仍按一笔一笔处理。
- DCache 读响应未完成时不启动其写；DCache 写响应未完成时不接受其读。
- 请求被背压时，上游保持有效和载荷。仲裁器锁定读来源，写来源固定为数据侧。
- 写末拍只结束发送阶段，写响应归属仍保留到 B 完成；提前写响应不会传给数据侧。
- 复位取消两个方向的所有控制状态；RAM 内容的复位语义由从设备管理。

## 验证

从 `rtl/` 执行：

```bash
python3 tests/run_axi4_units.py --bench mem_burst_arbiter_tb
python3 tests/run_axi4_units.py --bench axi4_parallel_tb
python3 tests/run_axi4_units.py --bench cache_bus_parallel_tb --delay 5 --seed 493
python3 tests/run_axi4_units.py
```

仲裁测试覆盖读竞争及交接、读写重叠、写间隙、两侧背压、错误归属、提前写响应屏蔽和复位。
master 集成测试分别阻塞 AR/AW/W/R/B，要求另一方向完成，并验证同时 R/B 的不同错误、非法请求排空及复位。
真实缓存测试包含五路冲突脏行替换、clean 与取指补行重叠、写回数据比较、旁路回读以及 clean 后 ICache 失效。

历史串行状态机和逐周期等价证据见 `test_results/arbiter_fsm_20261114_175404_354261/`；
本实现的行为已改为读写并行，因此不再使用旧串行模块的逐周期等价选项。
