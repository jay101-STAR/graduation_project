# I2C接口设计文档

## 项目概述
本项目使用Verilog实现了一个完整的I2C（IIC）接口，支持单字节和多字节的读写操作。

## 文件列表
1. **i2c_master.v** - I2C主机控制器
2. **i2c_slave.v** - I2C从机模块（用于测试）
3. **i2c_tb.v** - 测试平台
4. **run_sim.do** - ModelSim仿真脚本

## 模块说明

### 1. I2C Master (i2c_master.v)
主机控制器，负责发起I2C通信。

**端口说明：**
- `clk` - 系统时钟输入
- `rst_n` - 异步复位（低电平有效）
- `slave_addr[6:0]` - 7位从机地址
- `rw` - 读写控制（1=读，0=写）
- `wr_data[7:0]` - 写数据输入
- `num_bytes[7:0]` - 传输字节数
- `start` - 启动传输信号
- `rd_data[7:0]` - 读数据输出
- `busy` - 忙标志
- `done` - 传输完成标志
- `ack_error` - 应答错误标志
- `sda` - I2C数据线（双向）
- `scl` - I2C时钟线（输出）

**功能特性：**
- 支持标准I2C协议（START、STOP、ACK/NACK）
- 可配置传输字节数（1-255字节）
- 自动生成SCL时钟
- ACK错误检测
- 状态机控制，确保时序正确

### 2. I2C Slave (i2c_slave.v)
从机模块，用于测试主机功能。

**端口说明：**
- `clk` - 系统时钟
- `rst_n` - 复位信号
- `slave_addr[6:0]` - 本从机地址（默认0x50）
- `sda` - I2C数据线
- `scl` - I2C时钟线

**功能特性：**
- 256字节内部存储器
- 自动响应地址匹配
- 支持连续读写
- START/STOP条件检测

### 3. Testbench (i2c_tb.v)
测试平台，验证I2C接口功能。

**测试用例：**
1. **Test 1**: 单字节写操作 - 写入0xA5
2. **Test 2**: 多字节写操作 - 写入3字节（0x11, 0x22, 0x33）
3. **Test 3**: 单字节读操作 - 读取1字节
4. **Test 4**: 多字节读操作 - 读取3字节

## ModelSim仿真步骤

### 方法1：使用DO脚本（推荐）
```bash
# 在i2c_interface目录下执行
cd /home/jay/Desktop/graduation_project/i2c_interface
vsim -do run_sim.do
```

### 方法2：手动执行
1. 启动ModelSim
2. 切换到项目目录：
   ```
   cd /home/jay/Desktop/graduation_project/i2c_interface
   ```
3. 创建工作库：
   ```
   vlib work
   ```
4. 编译源文件：
   ```
   vlog i2c_master.v
   vlog i2c_slave.v
   vlog i2c_tb.v
   ```
5. 启动仿真：
   ```
   vsim work.i2c_tb
   ```
6. 添加波形：
   ```
   add wave -r /*
   ```
7. 运行仿真：
   ```
   run -all
   ```

## 关键波形观察点

### 写操作波形特征：
1. **START条件**：SCL为高时，SDA由高变低
2. **地址传输**：7位地址 + 1位R/W位（0表示写）
3. **ACK应答**：从机拉低SDA表示应答
4. **数据传输**：8位数据 + ACK
5. **STOP条件**：SCL为高时，SDA由低变高

### 读操作波形特征：
1. **START条件**
2. **地址传输**：7位地址 + 1位R/W位（1表示读）
3. **ACK应答**
4. **数据接收**：从机发送8位数据
5. **ACK/NACK**：主机发送ACK（继续）或NACK（结束）
6. **STOP条件**

## 仿真截图要求

请在Word文档中包含以下截图：

### 1. 单字节写操作波形
- 时间范围：包含完整的START到STOP过程
- 关键信号：clk, rst_n, start, sda, scl, wr_data, busy, done
- 标注：START条件、地址字节、ACK、数据字节、STOP条件

### 2. 多字节写操作波形
- 显示连续写入多个字节的过程
- 标注每个字节的边界和ACK位置

### 3. 单字节读操作波形
- 显示完整的读操作时序
- 标注数据采样点

### 4. 多字节读操作波形
- 显示连续读取过程
- 标注最后一个字节的NACK

### 5. 整体仿真结果
- 显示所有测试用例的执行情况
- 包含控制台输出信息

## 预期仿真结果

控制台应显示：
```
=== I2C Interface Test Started ===
Time: 200

--- Test 1: Single Byte Write ---
Writing 0xA5 to slave address 0x50
SUCCESS: Single byte write completed

--- Test 2: Multiple Byte Write ---
Writing 3 bytes: 0x11, 0x22, 0x33
SUCCESS: Multiple byte write completed

--- Test 3: Single Byte Read ---
Reading 1 byte from slave
SUCCESS: Single byte read completed, data = 0xXX

--- Test 4: Multiple Byte Read ---
Reading 3 bytes from slave
SUCCESS: Multiple byte read completed, last data = 0xXX

=== All Tests Completed ===
```

## 技术参数

- **系统时钟频率**：100 MHz
- **I2C时钟频率**：约390 kHz（通过256分频）
- **支持的传输模式**：标准模式
- **最大传输字节数**：255字节
- **地址位宽**：7位

## 注意事项

1. 仿真时确保SDA和SCL有上拉电阻（testbench中已包含pullup）
2. 多字节传输时，当前实现简化了数据更新机制，实际应用中需要添加握手信号
3. 从机地址默认为0x50，可根据需要修改
4. 时钟分频比可在i2c_master.v中调整（当前为256分频）

## 提交清单

请在Word文档中包含：
1. ✅ 项目说明（本文档内容）
2. ✅ 单字节写操作仿真波形截图
3. ✅ 多字节写操作仿真波形截图
4. ✅ 单字节读操作仿真波形截图
5. ✅ 多字节读操作仿真波形截图
6. ✅ 完整的源代码（i2c_master.v, i2c_slave.v, i2c_tb.v）
7. ✅ 仿真脚本（run_sim.do）

---
**作者**：Claude Code
**日期**：2026-01-19
**版本**：1.0
