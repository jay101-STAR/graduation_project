# RISC-V 测试工具集

本目录包含用于测试 RISC-V 处理器的完整工具集。

## 🚀 快速开始

### 1. 编译仿真器

```bash
cd rtl
make comp
```

### 2. 运行批量测试

```bash
./run_tests.sh
```

## 📋 工具列表

### 主要测试脚本

| 脚本 | 用途 | 推荐度 |
|------|------|--------|
| `run_tests.sh` | 批量运行测试（快速，推荐） | ⭐⭐⭐⭐⭐ |
| `run_single_test.sh` | 运行单个测试 | ⭐⭐⭐⭐ |
| `run_riscv_tests.sh` | 完整版批量测试 | ⭐⭐⭐ |

### 使用示例

#### 运行所有 RV32UI 测试

```bash
./run_tests.sh
```

#### 运行特定类别的测试

```bash
# Load/Store 指令
./run_tests.sh "rv32ui-p-l*"
./run_tests.sh "rv32ui-p-s*"

# 分支指令
./run_tests.sh "rv32ui-p-b*"

# 算术指令
./run_tests.sh "rv32ui-p-add*"
```

#### 运行单个测试并查看详细输出

```bash
./run_single_test.sh rv32ui-p-add
```

#### 运行 M 扩展测试（需要先实现 M 扩展）

```bash
./run_tests.sh "rv32um-p-*"
```

## 📊 测试结果

测试结果保存在 `test_results/` 目录：

```
test_results/
├── summary_20260125_130000.txt      # 测试摘要
├── failed_tests_20260125_130000.txt # 失败测试列表
├── rv32ui-p-add.log                 # 单个测试日志
├── rv32ui-p-addi.log
└── ...
```

### 结果格式

```
========================================
Test Summary
========================================
Total tests:   42
Passed:        38
Failed:        4
Skipped:       0
Pass rate:     90%
```

## 🔍 调试失败的测试

### 方法 1: 查看测试日志

```bash
cat test_results/rv32ui-p-add.log
```

### 方法 2: 单独运行并查看波形

```bash
# 运行单个测试
./run_single_test.sh rv32ui-p-add

# 查看波形
make verdi
```

### 方法 3: 查看测试源码

```bash
# 查看反汇编
cat ../verification/riscv-tests/isa/rv32ui-p-add.dump

# 查看源码
cat ../verification/riscv-tests/isa/rv32ui/add.S
```

## 📈 预期测试结果

### 当前实现（RV32I + Load/Store + CSR）

| 指令类别 | 预期通过率 | 说明 |
|---------|-----------|------|
| 算术逻辑 | 100% | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| 立即数 | 100% | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| 分支 | 100% | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| 跳转 | 100% | JAL, JALR |
| 上位立即数 | 100% | LUI, AUIPC |
| Load | 100% | LB, LH, LW, LBU, LHU |
| Store | 100% | SB, SH, SW |
| FENCE | 0% | 未实现 |
| M 扩展 | 0% | 未实现 |

**预期总通过率**: ~95% (40/42 tests)

### 实现 M 扩展后

| 指令类别 | 预期通过率 |
|---------|-----------|
| 乘法 | 100% | MUL, MULH, MULHSU, MULHU |
| 除法 | 100% | DIV, DIVU, REM, REMU |

## 🛠️ 故障排除

### 问题 1: 找不到 riscv32-unknown-elf-objcopy

**解决方案**: 安装 RISC-V 工具链

```bash
sudo apt-get install gcc-riscv64-unknown-elf
```

### 问题 2: simv 不存在

**解决方案**: 先编译仿真器

```bash
make comp
```

### 问题 3: 所有测试都失败

**可能原因**:
1. 处理器基本功能有问题
2. tohost 地址不正确
3. 测试程序入口地址不匹配

**调试步骤**:
1. 运行简单的测试: `./run_single_test.sh rv32ui-p-add`
2. 查看波形: `make verdi`
3. 检查 PC 是否正确递增
4. 检查指令是否正确执行

### 问题 4: 测试超时

**可能原因**:
1. 处理器陷入死循环
2. 分支指令有问题
3. 跳转指令有问题

**调试步骤**:
1. 查看波形，找到死循环位置
2. 检查分支条件判断逻辑
3. 检查跳转地址计算

## 📚 详细文档

更多详细信息请参考:
- [TEST_GUIDE.md](TEST_GUIDE.md) - 完整测试指南
- [CLAUDE.md](../CLAUDE.md) - 项目总体说明

## 🎯 测试策略建议

### 阶段 1: 基础指令验证

```bash
# 测试算术指令
./run_tests.sh "rv32ui-p-add"
./run_tests.sh "rv32ui-p-sub"

# 测试逻辑指令
./run_tests.sh "rv32ui-p-and"
./run_tests.sh "rv32ui-p-or"
./run_tests.sh "rv32ui-p-xor"
```

### 阶段 2: 分支和跳转

```bash
# 测试分支
./run_tests.sh "rv32ui-p-b*"

# 测试跳转
./run_tests.sh "rv32ui-p-jal"
./run_tests.sh "rv32ui-p-jalr"
```

### 阶段 3: Load/Store

```bash
# 测试 Load
./run_tests.sh "rv32ui-p-l*"

# 测试 Store
./run_tests.sh "rv32ui-p-s*"
```

### 阶段 4: 完整测试

```bash
# 运行所有 RV32UI 测试
./run_tests.sh
```

### 阶段 5: M 扩展（可选）

```bash
# 运行 M 扩展测试
./run_tests.sh "rv32um-p-*"
```

## 💡 提示

1. **首次运行**: 建议先运行单个简单测试，确保工具链正常工作
2. **批量测试**: 批量测试可能需要 5-10 分钟，请耐心等待
3. **失败分析**: 重点关注第一个失败的测试，后续失败可能是连锁反应
4. **波形调试**: 对于复杂问题，波形分析是最有效的调试方法
5. **增量开发**: 建议每实现一个功能就运行相关测试，而不是全部实现后再测试

## 📞 获取帮助

如果遇到问题:
1. 查看 [TEST_GUIDE.md](TEST_GUIDE.md) 的故障排除部分
2. 检查测试日志文件
3. 使用波形查看器分析问题
4. 查看 RISC-V 规范确认指令行为

祝测试顺利！🎉
