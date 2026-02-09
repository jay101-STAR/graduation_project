# CoreMark调试指南

## 问题总结

CoreMark在运行约50个时钟周期后崩溃，PC变成X值（未知值）。

### 关键发现

1. **崩溃时间点**：
   - t=2000ns: PC=0x80000a8c (正常)
   - t=3000ns: PC=0xxxxxxxxx (崩溃)
   - 约50个时钟周期后崩溃

2. **崩溃位置**：
   - 地址：0x80000a8c
   - 指令：`li a0,2`
   - 上下文：正在调用`get_seed_32`函数

3. **已验证正常的功能**：
   - RISC-V官方测试：通过
   - 简单栈测试：通过
   - 函数调用：正常
   - 内存访问：正常

4. **已修复的问题**：
   - ✅ 栈指针从0x80010000改为0x8000F000（在64KB范围内）
   - ✅ 移除了UART调试代码（0x10000000）
   - ✅ 修复了testbench时钟周期（从2ns恢复为20ns）
   - ✅ 增加了仿真超时时间（200ms）

## 必须使用Verdi调试

### 步骤1：生成波形文件

波形文件已经生成：`rtl/testbench.fsdb`

### 步骤2：打开Verdi

```bash
cd rtl
make verdi
```

### 步骤3：查看关键信号

在Verdi中添加以下信号到波形窗口：

**PC相关**：
- `testbench.top.openmips0.pc_if_pc` - 程序计数器
- `testbench.top.openmips0.pc0.next_pc` - 下一个PC
- `testbench.top.openmips0.pc0.ren` - PC使能信号

**流水线控制**：
- `testbench.top.openmips0.stall_if_id` - IF/ID流水线暂停
- `testbench.top.openmips0.flush_if_id` - IF/ID流水线冲刷
- `testbench.rst` - 复位信号
- `testbench.clk` - 时钟信号

**指令相关**：
- `testbench.top.instrom0.openmips_instrom_addr` - 指令地址
- `testbench.top.instrom0.instrom_openmips_data` - 读取的指令
- `testbench.top.openmips0.if_id_inst` - IF/ID阶段的指令

**寄存器文件**：
- `testbench.top.openmips0.registerfile0.rs1_rdata` - rs1读取数据
- `testbench.top.openmips0.registerfile0.rs2_rdata` - rs2读取数据
- `testbench.top.openmips0.reg_rd_wen` - 寄存器写使能
- `testbench.top.openmips0.reg_rd_data` - 寄存器写数据

**内存访问**：
- `testbench.top.openmips0.ex_dataram_addr` - 数据内存地址
- `testbench.top.openmips0.ex_dataram_wen` - 数据内存写使能
- `testbench.top.openmips0.ex_dataram_ren` - 数据内存读使能

### 步骤4：定位问题

1. **找到t=2000ns到t=3000ns之间的波形**
2. **查看PC在什么时候变成X值**
3. **回溯X值的来源**：
   - 是从指令ROM读取的？
   - 是从寄存器文件读取的？
   - 是从某个未初始化的信号传播的？
4. **检查流水线控制信号**：
   - stall信号是否正常？
   - flush信号是否正常？
   - 是否有异常的流水线行为？

## 可能的问题原因

### 1. 指令ROM读取问题
- 检查`instrom.v`中的地址计算
- 检查是否有地址越界

### 2. 数据RAM读取问题
- 检查`dataram_banked.v`中的bank选择逻辑
- 检查是否有未初始化的内存被读取

### 3. 流水线hazard检测问题
- 检查`openmips.v`中的hazard检测逻辑
- 检查数据前递（forwarding）逻辑

### 4. CSR访问问题
- CoreMark可能使用了CSR指令（如mcycle）
- 检查`csr.v`中的CSR读取逻辑

### 5. 乘法/除法单元问题
- CoreMark使用了乘法指令
- 检查`mul_3cycle.v`和`div.v`的输出

## 临时解决方案

如果无法立即修复，可以尝试：

1. **使用更简单的benchmark**：
   - Dhrystone（比CoreMark简单）
   - 自定义的简单循环测试

2. **减少CoreMark的迭代次数**：
   ```bash
   ITERATIONS=0 ./run_coremark.sh  # 最小化测试
   ```

3. **使用Spike模拟器验证CoreMark二进制**：
   ```bash
   spike --isa=RV32IM verification/coremark/coremark_spike.elf
   ```

## 下一步行动

**必须使用Verdi查看波形**，这是唯一能确定问题根源的方法。文本日志无法提供足够的信息来诊断X值传播问题。

祝调试顺利！
