# CoreMark调试报告 - 地址溢出问题

## 问题发现

您的观察非常正确！**确实存在地址范围问题**。

### 地址溢出分析

数据RAM使用双Bank交错存储：
- 每个Bank: 8192个字（32KB），地址范围0-8191
- 总容量: 64KB（16384个字）

**地址计算逻辑**（dataram_banked.v:60）：
```verilog
wire [BANK_ADDR_WIDTH-1:0] addr_bank0 = bank_sel ? (inner_addr + 1'b1) : inner_addr;
```

**问题**：当访问接近64KB边界的地址时会溢出：

| 物理地址 | word_addr | bank_sel | inner_addr | addr_bank0 | 状态 |
|---------|-----------|----------|------------|------------|------|
| 0x8000EFFC | 15359 | 1 | 7679 | 7680 | ✅ 正常 |
| 0x8000F000 | 15360 | 0 | 7680 | 7680 | ✅ 正常 |
| 0x8000FFFC | 16383 | 1 | 8191 | **8192** | ❌ **溢出！** |

当`addr_bank0=8192`时，超出了Bank0的范围（0-8191），会访问未定义的内存，导致X值。

### 栈指针设置的影响

- **旧设置**: `sp=0x8000F000`（60KB）- 接近边界，容易触发溢出
- **新设置**: `sp=0x80008000`（32KB）- 更安全，但仍然可能在栈增长时触发问题

## 根本原因

**PC变成X值不是因为栈指针本身，而是因为：**

1. **程序执行过程中访问了接近64KB边界的地址**
2. **地址计算逻辑在边界处会产生溢出**
3. **溢出导致访问未定义内存，产生X值**
4. **X值在流水线中传播，最终导致PC变成X值**

## 为什么简单测试能通过？

- RISC-V官方测试：代码小，栈使用少，不会触及边界
- 简单栈测试：只使用了少量栈空间，远离边界
- CoreMark：代码大（16KB），栈使用多，容易触及边界

## 解决方案

### 方案1：修复地址计算逻辑（推荐）

修改`dataram_banked.v`，防止地址溢出：

```verilog
// 原代码（第60行）：
wire [BANK_ADDR_WIDTH-1:0] addr_bank0 = bank_sel ? (inner_addr + 1'b1) : inner_addr;

// 修复方案：限制地址范围
wire [BANK_ADDR_WIDTH-1:0] addr_bank0 = bank_sel ?
    ((inner_addr == (BANK_DEPTH-1)) ? inner_addr : (inner_addr + 1'b1)) :
    inner_addr;
```

或者更简单的方案：**减小可用内存范围**，避免使用最后一个字：

```verilog
// 在dataram_banked.v开头添加：
localparam MAX_WORD_ADDR = (BANK_DEPTH * 2) - 2;  // 16382，避免最后一个字

// 在地址计算后添加范围检查：
wire addr_out_of_range = (word_addr > MAX_WORD_ADDR);
```

### 方案2：减小内存大小（临时方案）

将`BANK_ADDR_WIDTH`从13改为12：
- 每个Bank: 4096个字（16KB）
- 总容量: 32KB（8192个字）
- 避免了边界溢出问题

```verilog
// dataram_banked.v:38
localparam BANK_ADDR_WIDTH = 12;  // 改为12，总共32KB
```

然后将栈指针设置为：
```assembly
li sp, 0x80007000  # 28KB处，留4KB栈空间
```

### 方案3：使用单Bank内存（最简单）

如果不需要64KB内存，可以简化为单Bank设计，避免复杂的地址计算。

## 下一步调试

即使修复了地址溢出问题，CoreMark可能还有其他问题。建议：

1. **先修复地址溢出**（方案1或2）
2. **重新编译并测试**
3. **如果仍有问题，使用Verdi查看波形**

## Verdi调试要点

如果修复后仍有问题，在Verdi中查看：

1. **数据RAM访问信号**：
   - `testbench.top.dataram0.ex_dataram_addr`
   - `testbench.top.dataram0.addr_bank0`
   - `testbench.top.dataram0.addr_bank1`
   - `testbench.top.dataram0.inner_addr`

2. **检查是否有地址超出8191**

3. **查看X值首次出现的位置**

## 总结

您的直觉是对的！**地址范围确实是问题的根源**。数据RAM的双Bank交错存储设计在边界处有溢出bug，导致访问未定义内存时产生X值。

修复这个bug后，CoreMark应该能够正常运行。
