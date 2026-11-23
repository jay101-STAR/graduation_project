#!/usr/bin/env python3
"""AXI4 protocol unit tests; image-free, independent of CPU instruction tests."""
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess

RTL = Path(__file__).resolve().parents[1]

def main(benches=None, delay=0, seed=493):
    stamp = datetime.now().strftime('%Y%m%d_%H%M%S_%f')
    prefix = RTL / 'test_results' / f'axi4_units_{stamp}'
    prefix.parent.mkdir(exist_ok=True)
    records = []
    sources = sorted(p for p in (RTL / 'vsrc').rglob('*') if p.suffix in ('.v', '.sv') and p.name != 'testbench.v')
    specifications = [('axi4_ram_tb', '[AXI4-RAM] PASS'),
                      ('axi4_uart_tb', '[AXI4-UART] PASS'),
                      ('axi4_master_tb', '[AXI4-MASTER-UNIT] PASS'),
                      ('axi4_write_burst_tb', '[AXI4-WRITE-BURST] PASS'),
                      ('axi4_parallel_tb', '[AXI4-PARALLEL] PASS'),
                      ('cache_bus_parallel_tb', '[CACHE-BUS-PARALLEL] PASS'),
                      ('axi4_fabric_tb', '[AXI4-FABRIC] PASS'),
                      ('mem_burst_arbiter_tb', '[BURST-ARBITER] PASS')]
    for bench, marker in specifications:
        if benches is not None and bench not in benches:
            continue
        build = Path(f'/tmp/axi4_units_{stamp}/{bench}')
        build.mkdir(parents=True)
        log = Path(f'{prefix}.{bench}.log')
        wave = Path(f'{prefix}.{bench}.vcd')
        extra_sources, options = [RTL / 'tests/axi4_master_serial_adapter.v'], []
        bench_sources = sources
        if bench == 'cache_bus_parallel_tb':
            master = RTL / 'vsrc/bus/axi4_master.v'
            impl = build / 'axi4_master_impl.v'
            impl.write_text(master.read_text().replace('module axi4_master (', 'module axi4_master_impl (', 1))
            bench_sources = [p for p in sources if p != master]
            extra_sources += [impl, RTL / 'tests/axi4_master_delay.v', RTL / 'tests/axi4_channel_delay.sv']
        command = ['verilator', '--binary', '--timing', '--trace', '-Wno-fatal',
                   '--unroll-count', '256', '--top-module', bench, '--Mdir', str(build), '-j', '4',
                   *options, *map(str, bench_sources), *map(str, extra_sources), str(RTL / f'tests/{bench}.sv')]
        with log.with_suffix('.build.log').open('w') as output:
            subprocess.run(command, cwd=RTL, check=True,
                           stdout=output, stderr=subprocess.STDOUT, timeout=180,
                           env={**os.environ, 'CCACHE_DIR': '/tmp/axi4_ccache'})
        with log.open('w') as output:
            result = subprocess.run([str(build / f'V{bench}'), f'+wave={wave}',
                                     f'+handshake_delay={delay}', f'+handshake_seed={seed}', f'+seed={seed}'], cwd=RTL,
                                    stdout=output, stderr=subprocess.STDOUT, timeout=30)
        passed = result.returncode == 0 and marker in log.read_text()
        records.append({'bench': bench, 'passed': passed, 'log': str(log), 'wave': str(wave),
                        'delay': delay, 'seed': seed, 'build_command': command})
        prefix.with_suffix('.json').write_text(json.dumps(records, indent=2)+'\n')
        print(log.read_text(), end='')
        if not passed:
            raise RuntimeError(f'Unit failed: {log}')
    print(f'Evidence: {prefix}.json')

if __name__ == '__main__':
    import argparse
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('--bench', action='append', choices=('axi4_ram_tb', 'axi4_uart_tb', 'axi4_master_tb', 'axi4_write_burst_tb', 'axi4_parallel_tb', 'cache_bus_parallel_tb', 'axi4_fabric_tb', 'mem_burst_arbiter_tb'))
    cli.add_argument('--delay', type=int, choices=range(16), default=0)
    cli.add_argument('--seed', type=int, default=493)
    args = cli.parse_args()
    main(args.bench, args.delay, args.seed)
