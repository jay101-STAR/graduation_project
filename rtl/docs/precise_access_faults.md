# 精确取指、load、store 访问异常

当前 CPU 已将 Instruction access fault（1）、Load access fault（5）、Store access fault（7）接入 M 模式异常入口。ECALL/EBREAK 和 MRET 保留；新增可读写的 `mtval`（0x343）。没有增加 MMU、PMP、S/U 特权模式、页故障或中断。

## 数据与控制路径

```text
取指错误 + 请求 PC
       |
       v
 IF2 -> IF/ID -> ID/EX -> EX 异常候选 --------+
       随 valid、stall、flush 保存/清除       |
                                             v
数据响应错误 + 故障地址 -> MEM 异常候选 -> 按指令先后选择 -> CSR / PC 重定向
                           |                 |
                           +-- 优先于 EX ----+
```

- 取指响应失败时，以 NOP 作为译码载荷，错误标志和原始 PC 随流水级前进。较老分支/跳转可以先冲刷它；只有仍有效且到达 EX 的失败取指才触发异常。
- EX/MEM 保存指令 PC。数据响应及保存寄存器携带 error 和 fault_addr，load/store 类型由当前 MEM 请求决定。MEM 故障优先于年轻 EX 的 ECALL、CSR、分支、JAL、MUL/DIV。
- MEM 故障被接受时，较老 WB 指令仍允许在该边沿退休；故障指令不进入 WB，年轻 EX/MEM 项被清除，年轻 CSR 和预测器更新禁止。错误数据也不参与 MEM→EX 转发。
- 年轻乘除法操作在 MEM trap 时取消；测试在 MRET 后再次执行 MUL/DIV，确认不复用旧完成状态。
- trap 保存 mepc=故障指令 PC、mcause=原因、mtval=故障地址，更新 mstatus 后跳转至 mtvec 的直接入口。ECALL/EBREAK 的 mtval 置零。MRET 跳回软件写入的 mepc，不自动加 4。

## 地址与错误语义

| 情况 | mcause | mepc / mtval |
| --- | ---: | --- |
| 有效取指返回访问错误 | 1 | 原始取指 PC / 原始取指地址 |
| load 返回访问错误 | 5 | load 指令 PC / 故障数据地址 |
| store 返回访问错误 | 7 | store 指令 PC / 故障数据地址 |
| JAL/JALR/已采取分支目标未按 4 字节对齐 | 0 | 控制流指令 PC / 错误目标地址 |

原因码 0 是为避免把对齐错误误报为 access fault 的配套分类。ID 的提前 JAL 重定向只处理对齐目标；未对齐目标在 EX 触发异常且不写链接寄存器。未采取分支不因其未对齐目标产生异常。当前仍不支持压缩指令。

LSU 保留已有非对齐 RAM 访问拆分。第一部分失败时报告原始地址；第二部分失败时报告第二个字的起始地址。RAM 越界预检报告首个超出 RAM 的字节 0x80010000，并在预检失败时不发起任何子写。适配器在响应背压期间同时保存数据、错误和故障地址。

失败 load 不写 rd，包括对 x0 的 load 也必须报告错误。异常指令不增加 minstret。跨字 store 已成功的前一部分可能保留，精确异常不承诺普通 store 的原子回滚。

DCache 仍为阻塞式写回、写分配。store miss 的读补行失败归属 store；脏行写回失败经现有 Cache 返回给当前缺失请求，按当前请求报告 5 或 7，并保留原脏行。FENCE.I clean 失败仍采用原来的停止和仿真 fatal 路径，不把维护错误冒充成某条 load/store 的精确异常。

## 验证

从 rtl/ 执行：

```bash
# 独立程序镜像，不修改项目 bank HEX；四种 Cache 组合，零等待及随机等待
python3 tests/run_access_faults.py --cache-mode 00 --cache-mode 10 \
  --cache-mode 01 --cache-mode 11

# 指定读突发的失败拍，验证错误聚合和完整排空
python3 tests/run_access_faults.py --cache-mode 11 --fault-beat 0 --fault-beat 15

# ISA/UART 和退休计数器系统回归，不运行 CoreMark
python3 tests/run_mem_handshake.py --icache-enable 1 --dcache-enable 1 \
  --suite all --suite minstret --suite cache --suite pipeline \
  --delay-master --delay 5 --seed 493 \
  --extra-checks tests/axi_ram_checks.svh --extra-checks tests/cache_checks.svh \
  --build-dir /tmp/access_faults_verify
```

独立汇编 access_faults.s 校验 mcause/mepc/mtval、MIE/MPIE、失败目的寄存器、年轻 store/CSR 副作用以及 MRET 恢复。每个故障点前读取 minstret，在异常处理程序第一条指令再次读取，精确核对期间正常退休的指令数。独立 native 内存模型注入返回错误，并检查写突发长度与响应归属。
