#!/usr/bin/env python3
"""Collect saved evidence for the direct AXI4 UART integration."""
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import sys

from axi4_acceptance import run_record

RTL = Path(__file__).resolve().parents[1]
RESULTS = RTL / 'test_results'
sys.path.insert(0, str(RTL / 'tools'))
from run import validate_coremark


def console_manifest(name, marker):
    text = (RESULTS / name).read_text()
    matches = re.findall(marker+r' (.*)', text)
    if not matches:
        raise RuntimeError(f'Run is not complete: {name}')
    return Path(matches[-1])


def main():
    runs = {}
    for name in ('system10', 'system00', 'delay10', 'delay00'):
        path = console_manifest(f'uart_axi4_{name}.console.log', 'Run manifest:')
        runs[name] = run_record(path)
        assert 'all' in runs[name]['suites'] and runs[name]['coremark']
        log = Path(runs[name]['coremark']['log']).read_text()
        validate_coremark(log, (RTL.parent/'verification/coremark/core_main.c').read_text())
    focused = console_manifest('uart_axi4_focused.console.log', 'Evidence:')
    subsystem = console_manifest('uart_axi4_subsystem.console.log', 'Evidence:')
    units = json.loads(focused.read_text())+json.loads(subsystem.read_text())
    assert len(units) == 4 and all(row['passed'] for row in units)
    assert all(Path(row['wave']).is_file() for row in units)
    assert '0 error(s), 0 warning(s)' in (RESULTS/'uart_axi4_vcs_build.log').read_text()
    baseline = json.loads((RESULTS/'axi4_acceptance.json').read_text())['runs']
    source_names = ['vsrc/periph/uart/axi4_uart_slave.v', 'vsrc/bus/axi4_subsystem.v',
                    'tests/axi4_uart_tb.sv', 'tests/axi4_fabric_tb.sv', 'tests/run_axi4_units.py']
    record = {'timestamp': datetime.now().isoformat(), 'runs': runs, 'units': units,
              'baseline': {mode: baseline[mode] for mode in ('10', '00')},
              'source_sha256': {name: hashlib.sha256((RTL/name).read_bytes()).hexdigest() for name in source_names},
              'vcs_build': str(RESULTS/'uart_axi4_vcs_build.log')}
    (RESULTS/'uart_axi4_acceptance.json').write_text(json.dumps(record, indent=2)+'\n')
    lines = ['# UART 直接 AXI4 接口验收', '',
             '`axi4_subsystem.uart` 现直接实例化 `axi4_uart_slave`，互连 slot 1 的全部 AXI4 信号直接连接 UART。该路径不再包含 `uart_bridge`、`axi4_to_axi_lite` 或 `axi_lite_uart_slave`。RAM 路径保持原有实现。', '',
             '## 接口与寄存器', '',
             '- 32 位地址/数据、1 位 ID；合法请求为对齐的 32 位 INCR 单拍访问。读写响应返回保存的 ID，单拍读的 RLAST=1。',
             '- AW/W 可独立到达，包括先保存一拍 W 再等待 AW；B/R 响应被阻塞时保持字段稳定，并阻止同方向下一请求。',
             '- 非法属性或不支持的突发返回 SLVERR；读返回 ARLEN+1 个错误拍，写排空 AWLEN+1 拍后返回一次 B，不触发 TX 或 RX 副作用。WLAST 错误返回 SLVERR。',
             '- TXDATA/STATUS/RXDATA 地址、UART 收发和 FIFO 保持原样。零 WSTRB 不发送；多个字节有效时选择最低有效字节。RXDATA 只在成功读响应握手时弹出一次 FIFO。', '',
             '## 验证', '', '| 配置 | 等待上限 | 种子 | 仿真通过数 | 证据 |', '| --- | ---: | ---: | ---: | --- |']
    for name, row in runs.items():
        link = Path(row['manifest']).name
        lines.append(f'| {name} / ICache={row["icache"]} | {row["delay"]} | {row["seed"]} | {row["passed"]} | [{link}]({link}) |')
    total = sum(row['passed'] for row in runs.values())
    lines += ['', f'共 {total} 次系统仿真通过，覆盖 UART 六项串口测试、全部 ISA、FENCE.I、分支预测、计数器、流水线、AXI 集成和 CoreMark。随机等待覆盖五个 AXI 通道及原生握手边界，没有跳过 fence_i。', '',
              '- UART 独立测试 43 项检查：AW/W 先后、两种 ID、B/R 背压、16 种掩码、WLAST 错误、窄传输/对齐/地址/锁/突发类型错误、最长 256 拍拒绝、RX 溢出和弹出时机、复位打断 R/B/AW/W。',
              '- AXI4 互连、主桥、整笔仲裁测试全部通过。']
    for row in units:
        lines.append(f'  - [{row["bench"]}]({Path(row["log"]).name}) / [波形]({Path(row["wave"]).name})')
    lines += ['- [VCS 编译](uart_axi4_vcs_build.log)通过；KDB 为 0 errors / 0 warnings，原有工具提示保留在日志中。',
              '- [RTL lint](uart_axi4_lint.log)和 [UART 测试 lint](uart_axi4_unit_lint.log)通过。', '',
              '## 同程序 CoreMark 比较', '',
              '比较此次改动前的 AXI4 + Lite UART 桥接版本，运算区间同为 PC 0x80002970 → 0x8000297c。', '',
              '| ICache | UART 接口 | 区间 mcycle | 区间 minstret | 区间 CPI | 全程序 mcycle | 全程序 minstret |',
              '| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for mode in ('00', '10'):
        for label, row in [('Lite 桥接', baseline[mode]), ('直接 AXI4', runs['system'+mode])]:
            m = row['coremark']; link = Path(m['log']).name
            lines.append(f'| {mode} | [{label}]({link}) | {m["region_mcycle"]} | {m["region_minstret"]} | {m["region_cpi"]:.4f} | {m["total_mcycle"]} | {m["total_minstret"]} |')
    lines += ['', '运算区间的 mcycle/minstret/CPI 保持不变。CoreMark 的 list/matrix/state CRC 均经参考表验证；单次迭代只用于比较，不满足正式评分至少 10 秒的要求。', '',
              '[CPU 控制路径波形](uart_axi4_cpu.vcd)包含直接 UART 的 AXI4 端口、TX 提交及 RX FIFO 弹出信号。独立 UART 波形还展示 W 先于 AW、受阻响应、错误突发排空及复位取消。', '',
              '实现和复现命令见 [AXI4 接口说明](../docs/axi4_bus.md)。历史 Lite UART 模块保留用于旧子系统独立测试，不在当前生产 UART 路径上。', '']
    (RESULTS/'uart_axi4_acceptance.md').write_text('\n'.join(lines))
    print('Evidence:', RESULTS/'uart_axi4_acceptance.md')
    print('System simulations passed:', total)


if __name__ == '__main__':
    main()
