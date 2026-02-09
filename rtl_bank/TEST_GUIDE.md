# RISC-V Tests 批量测试工具

本目录包含用于批量运行 RISC-V 测试套件的脚本。

## 文件说明

- `run_tests.sh` - 主测试脚本（推荐使用）
- `run_riscv_tests.sh` - 完整版测试脚本
- `quick_test.sh` - 快速测试脚本
- `test_results/` - 测试结果目录（自动创建）

## 使用方法

### 1. 准备工作

首先确保已经编译好仿真器：

```bash
cd rtl
make comp
```

### 2. 运行测试

#### 运行所有 RV32UI 测试（推荐）

```bash
cd rtl
chmod +x run_tests.sh
./run_tests.sh
```

#### 运行特定测试

```bash
# 只测试 load/store 指令
./run_tests.sh "rv32ui-p-l*"

# 只测试分支指令
./run_tests.sh "rv32ui-p-b*"

# 测试特定指令
./run_tests.sh "rv32ui-p-add"
```

#### 运行 M 扩展测试（乘法除法）

```bash
./run_tests.sh "rv32um-p-*"
```

### 3. 查看结果

测试完成后，结果保存在 `test_results/` 目录：

- `summary_YYYYMMDD_HHMMSS.txt` - 测试摘要
- `failed_tests_YYYYMMDD_HHMMSS.txt` - 失败的测试列表
- `<test_name>.log` - 每个测试的详细日志

## 测试分类

### RV32UI - 用户级整数指令

| 测试名称 | 测试内容 |
|---------|---------|
| rv32ui-p-add | ADD 指令 |
| rv32ui-p-addi | ADDI 指令 |
| rv32ui-p-and | AND 指令 |
| rv32ui-p-andi | ANDI 指令 |
| rv32ui-p-auipc | AUIPC 指令 |
| rv32ui-p-beq | BEQ 分支指令 |
| rv32ui-p-bge | BGE 分支指令 |
| rv32ui-p-bgeu | BGEU 分支指令 |
| rv32ui-p-blt | BLT 分支指令 |
| rv32ui-p-bltu | BLTU 分支指令 |
| rv32ui-p-bne | BNE 分支指令 |
| rv32ui-p-jal | JAL 跳转指令 |
| rv32ui-p-jalr | JALR 跳转指令 |
| rv32ui-p-lb | LB 加载字节 |
| rv32ui-p-lbu | LBU 加载无符号字节 |
| rv32ui-p-lh | LH 加载半字 |
| rv32ui-p-lhu | LHU 加载无符号半字 |
| rv32ui-p-lw | LW 加载字 |
| rv32ui-p-lui | LUI 指令 |
| rv32ui-p-or | OR 指令 |
| rv32ui-p-ori | ORI 指令 |
| rv32ui-p-sb | SB 存储字节 |
| rv32ui-p-sh | SH 存储半字 |
| rv32ui-p-sw | SW 存储字 |
| rv32ui-p-sll | SLL 逻辑左移 |
| rv32ui-p-slli | SLLI 立即数逻辑左移 |
| rv32ui-p-slt | SLT 有符号比较 |
| rv32ui-p-slti | SLTI 立即数有符号比较 |
| rv32ui-p-sltiu | SLTIU 立即数无符号比较 |
| rv32ui-p-sltu | SLTU 无符号比较 |
| rv32ui-p-sra | SRA 算术右移 |
| rv32ui-p-srai | SRAI 立即数算术右移 |
| rv32ui-p-srl | SRL 逻辑右移 |
| rv32ui-p-srli | SRLI 立即数逻辑右移 |
| rv32ui-p-sub | SUB 减法指令 |
| rv32ui-p-xor | XOR 异或指令 |
| rv32ui-p-xori | XORI 立即数异或 |

### RV32UM - 乘法除法扩展

| 测试名称 | 测试内容 |
|---------|---------|
| rv32um-p-mul | MUL 乘法 |
| rv32um-p-mulh | MULH 高位乘法 |
| rv32um-p-mulhsu | MULHSU 有符号×无符号高位乘法 |
| rv32um-p-mulhu | MULHU 无符号高位乘法 |
| rv32um-p-div | DIV 有符号除法 |
| rv32um-p-divu | DIVU 无符号除法 |
| rv32um-p-rem | REM 有符号取余 |
| rv32um-p-remu | REMU 无符号取余 |

## 测试结果说明

### 通过标准

- `tohost = 1` 表示测试通过
- `tohost != 1` 表示测试失败，具体值指示失败的测试用例编号

### 常见失败原因

1. **指令未实现** - 处理器不支持该指令
2. **指令实现错误** - 指令逻辑有bug
3. **内存访问错误** - load/store 指令地址计算或数据处理错误
4. **CSR 错误** - 控制状态寄存器实现不正确
5. **超时** - 测试程序陷入死循环或执行时间过长

## 调试失败的测试

### 1. 查看测试日志

```bash
cat test_results/<test_name>.log
```

### 2. 查看测试源码

```bash
cat ../verification/riscv-tests/isa/<test_name>.dump
```

### 3. 单独运行失败的测试

```bash
# 转换测试为 hex
riscv32-unknown-elf-objcopy -O binary \
    ../verification/riscv-tests/isa/rv32ui-p-add \
    vsrc/instrom/test.bin

od -An -tx4 -w4 -v vsrc/instrom/test.bin | awk '{print $1}' > vsrc/instrom/instrom.hex

# 运行仿真
make comp

# 查看波形
make verdi
```

## 性能优化

脚本使用以下优化：

1. **不重新编译** - 直接替换 hex 文件，使用已编译的 simv
2. **超时控制** - 每个测试最多运行 10 秒
3. **并行准备** - 可以修改脚本支持并行测试（需要多个 simv 实例）

## 预期结果

### 当前实现（RV32I + Load/Store）

预期通过的测试：
- ✅ 所有算术逻辑指令（add, sub, and, or, xor, sll, srl, sra, slt, sltu）
- ✅ 所有立即数指令（addi, andi, ori, xori, slli, srli, srai, slti, sltiu）
- ✅ 所有分支指令（beq, bne, blt, bge, bltu, bgeu）
- ✅ 跳转指令（jal, jalr）
- ✅ 上位立即数指令（lui, auipc）
- ✅ Load 指令（lb, lh, lw, lbu, lhu）
- ✅ Store 指令（sb, sh, sw）

预期失败的测试：
- ❌ fence_i（FENCE.I 指令未实现）
- ❌ RV32UM 所有测试（M 扩展未实现）

### 实现 M 扩展后

额外通过的测试：
- ✅ mul, mulh, mulhsu, mulhu
- ✅ div, divu, rem, remu

## 故障排除

### 问题：找不到 riscv32-unknown-elf-objcopy

**解决方案**：安装 RISC-V 工具链

```bash
# Ubuntu/Debian
sudo apt-get install gcc-riscv64-unknown-elf

# 或者从源码编译
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32i
make
```

### 问题：simv 不存在

**解决方案**：先编译仿真器

```bash
cd rtl
make comp
```

### 问题：所有测试都超时

**解决方案**：检查处理器是否陷入死循环，查看波形文件

```bash
make verdi
```

## 贡献

如果发现脚本有问题或需要改进，请提交 issue 或 PR。
