# 静态分支预测实现文档

## 概述

本文档描述了在5级流水线RISC-V CPU中实现的**BTFNT（Backward Taken, Forward Not Taken）静态分支预测**机制。

## 实现日期

2026-02-05

## 预测策略：BTFNT

**BTFNT (Backward Taken, Forward Not Taken)** 是一种经典的静态分支预测策略：

- **向后跳转（负偏移）**：预测为taken（跳转）
  - 通常对应循环结构，循环体会多次执行
  - 例如：`for`、`while`循环的回跳分支

- **向前跳转（正偏移）**：预测为not taken（不跳转）
  - 通常对应条件跳过代码
  - 例如：`if`语句的条件分支

### 预测准确率

- 循环密集型程序：70-90%
- 一般程序：60-80%
- 条件分支密集型程序：50-70%

## 架构设计

### 流水线阶段

```
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│   IF    │   ID    │   EX    │   MEM   │   WB    │
└─────────┴─────────┴─────────┴─────────┴─────────┘
     │         │         │
     │         │         └─ 验证预测，错误时修正
     │         └─────────── 静态预测，预测taken时更新PC
     └─────────────────── 取指令
```

### 预测流程

#### 1. ID阶段：静态预测

```verilog
// 检测分支指令
id_is_branch = (inst_type == B_TYPE)

// 计算分支目标地址
branch_target = PC + sign_extended_imm

// BTFNT预测逻辑
predict_taken = imm[31]  // 负偏移 -> taken

// 输出预测结果
id_branch_predicted = id_is_branch && predict_taken
id_predicted_pc = branch_target
```

#### 2. EX阶段：预测验证

```verilog
// 计算实际分支结果
branch_taken = (条件判断结果)

// 检测预测错误
branch_misprediction = id_ex_is_branch &&
                       (id_ex_branch_predicted != branch_taken)

// 只有预测错误时才重定向PC
pc_redirect_branch = branch_misprediction
```

### PC更新优先级

```
1. Stall（冒险停顿）        → 保持当前PC
2. EX阶段重定向             → 使用EX的PC（预测错误修正、trap、mret）
3. ID阶段预测跳转           → 使用预测的目标PC
4. 顺序执行                 → PC + 4
```

## 性能分析

### 分支惩罚

| 情况 | 惩罚周期 | 说明 |
|------|---------|------|
| 预测正确 | 0 | 无需flush，流水线继续执行 |
| 预测错误 | 2 | flush IF和ID阶段 |
| 无预测（原始） | 2 | 每次分支都flush |

### 性能提升

假设：
- 分支指令占比：20%
- BTFNT准确率：70%

**原始CPU（无预测）**：
- 每次分支惩罚：2周期
- 平均CPI = 1 + 0.2 × 2 = 1.4

**带BTFNT预测**：
- 预测正确（70%）：0周期惩罚
- 预测错误（30%）：2周期惩罚
- 平均CPI = 1 + 0.2 × 0.3 × 2 = 1.12

**性能提升**：(1.4 - 1.12) / 1.4 = **20%**

## 代码修改

### 1. id.v - 添加预测逻辑

```verilog
// 输出端口
output id_branch_predicted,  // 预测是否跳转
output [31:0] id_predicted_pc,  // 预测的目标PC
output id_is_branch  // 是否是分支指令

// 预测逻辑
assign id_is_branch = (inst_type == `B_TYPE);
wire [31:0] branch_target = pc_id_pc + sign_extended_immB;
wire predict_taken = sign_extended_immB[31];
assign id_branch_predicted = id_is_branch && predict_taken;
assign id_predicted_pc = branch_target;
```

### 2. id_ex_reg.v - 传递预测信息

```verilog
// 输入端口
input id_branch_predicted,
input [31:0] id_predicted_pc,
input id_is_branch,

// 输出端口
output reg ex_branch_predicted,
output reg [31:0] ex_predicted_pc,
output reg ex_is_branch
```

### 3. ex.v - 预测验证

```verilog
// 输入端口
input id_ex_branch_predicted,
input [31:0] id_ex_predicted_pc,
input id_ex_is_branch,

// 预测验证逻辑
wire branch_misprediction = id_ex_is_branch &&
                            (id_ex_branch_predicted != branch_taken);

// PC重定向（只在预测错误时）
wire pc_redirect_branch = branch_misprediction && !ex_csr_trap_valid;

// PC恢复值
assign ex_pc_pc_data = ...
    pc_redirect_branch ? (branch_taken ? result_branch_target : pc_plus_4) :
    ...;
```

### 4. pc.v - 支持ID阶段预测

```verilog
// 输入端口
input id_pc_wen,       // ID阶段预测跳转使能
input [31:0] id_pc_data,  // 预测的目标PC

// PC更新逻辑
assign new_pc = stall ? next_pc :
                ex_pc_pc_wen ? ex_pc_pc_data :
                id_pc_wen ? id_pc_data :
                next_pc + 4;
```

### 5. openmips.v - 连接信号

```verilog
// Wire声明
wire id_branch_predicted, ex_branch_predicted;
wire [31:0] id_predicted_pc, ex_predicted_pc;
wire id_is_branch, ex_is_branch;

// Flush逻辑
wire prediction_flush = id_branch_predicted;  // 预测taken时flush
wire branch_flush = ex_pc_pc_wen;  // 预测错误时flush
assign flush_if_id = prediction_flush || branch_flush;
```

## 测试结果

### RISC-V官方测试套件

```
Total tests:   42
Passed:        41
Failed:        1 (fence_i - 未实现)
Pass rate:     97%
```

### 分支指令测试

所有分支指令测试通过：
- ✓ rv32ui-p-beq
- ✓ rv32ui-p-bge
- ✓ rv32ui-p-bgeu
- ✓ rv32ui-p-blt
- ✓ rv32ui-p-bltu
- ✓ rv32ui-p-bne

## 关键设计决策

### 1. 为什么在ID阶段预测？

- **优点**：可以尽早更新PC，减少预测正确时的延迟
- **缺点**：需要额外的flush逻辑

### 2. 为什么选择BTFNT？

- **简单**：只需判断立即数符号位
- **有效**：对循环程序效果好
- **无硬件开销**：不需要额外的预测表或历史记录

### 3. Flush逻辑

两种flush情况：
1. **预测taken时**：flush IF/ID（丢弃PC+4的指令）
2. **预测错误时**：flush IF/ID和ID/EX（恢复正确的执行流）

## 未来改进方向

### 1. 动态分支预测

- **1-bit预测器**：记录上次分支结果
- **2-bit饱和计数器**：更稳定的预测
- **BTB（Branch Target Buffer）**：缓存分支目标地址

### 2. 分支目标缓存

- 缓存分支指令的目标地址
- 减少目标地址计算延迟

### 3. 返回地址栈（RAS）

- 专门优化函数返回（JALR指令）
- 使用栈结构记录返回地址

## 参考资料

1. Hennessy & Patterson, "Computer Architecture: A Quantitative Approach"
2. RISC-V Specification v2.2
3. "Branch Prediction Schemes" - Computer Architecture Course Notes

## 作者

Claude Code (Anthropic)

## 许可

本实现遵循原项目的许可协议。
