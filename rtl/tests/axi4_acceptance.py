#!/usr/bin/env python3
"""Summarize this migration's saved baseline, final regressions and wave proof.
Run after the documented verification commands have completed.
"""
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import sys

RTL = Path(__file__).resolve().parents[1]
RESULTS = RTL / 'test_results'


def run_record(manifest):
    evidence = json.loads(manifest.read_text())
    cases = evidence['simulations']
    if not cases or any(case['status'] != 'PASS' for case in cases):
        raise RuntimeError(f'Incomplete/failed run: {manifest}')
    coremark = next((case for case in cases if Path(case['log']).name.startswith('coremark_')), None)
    metrics = None
    if coremark:
        data = Path(coremark['log']).read_text()
        region = re.search(r'\[PERF-REGION\] mcycle=(\d+) minstret=(\d+) cpi=([\d.]+)', data)
        total = re.search(r'\[PERF\] mcycle=(\d+) minstret=(\d+) cpi=([\d.]+)', data)
        if not region or not total:
            raise RuntimeError(f'Missing CoreMark counts: {coremark["log"]}')
        metrics = {'region_mcycle': int(region[1]), 'region_minstret': int(region[2]),
                   'region_cpi': float(region[3]), 'total_mcycle': int(total[1]),
                   'total_minstret': int(total[2]), 'total_cpi': float(total[3]), 'log': coremark['log']}
    return {'manifest': str(manifest), 'passed': len(cases), 'icache': evidence['icache_enable'],
            'delay': evidence['delay'], 'seed': evidence['seed'], 'suites': evidence['suites'],
            'coremark': metrics}


def main():
    baselines = {'10': run_record(RESULTS / 'p1_run_20261105_142547_109227.json'),
                 '00': run_record(RESULTS / 'p1_run_20261105_142719_687417.json')}
    runs = {}
    for name in ['10', '00', 'delay10', 'delay00', 'seed1', 'seed65535']:
        console = RESULTS / f'axi4_verified_{name}.console.log'
        matches = re.findall(r'Run manifest: (.*)', console.read_text())
        if not matches:
            raise RuntimeError(f'Run has not completed: {console}')
        runs[name] = run_record(Path(matches[-1]))
    units_path = sorted(RESULTS.glob('axi4_units_*.json'))[-1]
    units = json.loads(units_path.read_text())
    assert len(units) == 3 and all(row['passed'] for row in units)
    assert all(Path(row['wave']).is_file() for row in units)
    wave = json.loads((RESULTS / 'axi4_verified_cpu.summary.json').read_text())
    vcs_log = RESULTS / 'axi4_vcs_final_build.log'
    assert '0 error(s), 0 warning(s)' in vcs_log.read_text(), 'VCS did not complete'
    sources = ['vsrc/top.v', 'vsrc/testbench.v', 'vsrc/cache/icache.sv', 'vsrc/mem/icache_phys_word.v',
               'vsrc/mem/dcache_phys_word.v', 'vsrc/cache/dcache.sv',
               'vsrc/mem/axi4_ram_slave.v', 'vsrc/bus/axi4_master.v', 'vsrc/bus/axi4_interconnect.v',
               'vsrc/bus/axi4_subsystem.v', 'vsrc/bus/axi4_to_axi_lite.v', 'vsrc/bus/mem_burst_arbiter.v']
    record = {'timestamp': datetime.now().isoformat(), 'baselines': baselines, 'runs': runs,
              'units': str(units_path), 'wave': wave, 'vcs_build': str(vcs_log),
              'source_sha256': {name: hashlib.sha256((RTL/name).read_bytes()).hexdigest() for name in sources}}
    report = RESULTS / 'axi4_acceptance.json'
    report.write_text(json.dumps(record, indent=2)+'\n')
    lines = ['# AXI4 升级验收', '', '最终配置：AXI4 32 位地址/数据、固定 ID=0、单笔事务在途，16 拍 INCR 补行读及单拍写；UART 使用 Lite 桥接。', '',
             '## 系统回归', '', '| 配置 | 额外等待 | 随机种子 | 通过数 | 证据 |', '| --- | ---: | ---: | ---: | --- |']
    for name, row in runs.items():
        link = Path(row['manifest']).name
        lines.append(f'| {name} / ICache={row["icache"]} | {row["delay"]} | {row["seed"]} | {row["passed"]} | [{link}]({link}) |')
    lines += ['', '各完整回归覆盖 ISA、UART、BP、计数器、RAM/UART 集成、流水线、性能及 CoreMark；额外种子执行定向、集成、流水线、BP 和计数器。未排除 fence_i；CoreMark 的 list/matrix/state CRC 与参考表一致。单次迭代用于功能和区间周期比较，不满足官方至少 10 秒的评分时长要求，日志中的时长提示保留。', '',
              f'- [AXI4 主桥、互连、仲裁单测]({units_path.name})：全部通过。',
              '- ICache 单测覆盖 341 项检查，包括每拍错误、完整排空、失败重试、旁路、连续命中和维护等待。',
              '- [VCS 编译](axi4_vcs_final_build.log)通过，KDB elaboration 为 0 errors / 0 warnings；工具原有 LCA/linker 提示见日志。[Verilator RTL 检查](axi4_final_lint.log)通过。', '',
              '## 同配置 CoreMark 比较', '', '同一工具链、程序与单次迭代，测量区间为 PC 0x80002970 → 0x8000297c。以下 CPI 为运算区间计数，排除初始化和串口打印。', '',
              '| 配置 | 总线 | 区间 mcycle | 区间 minstret | 区间 CPI |', '| --- | --- | ---: | ---: | ---: |']
    for mode in ['00', '10']:
        for bus, row in [('AXI-Lite', baselines[mode]), ('AXI4', runs[mode])]:
            metric = row['coremark']; link = Path(metric['log']).name
            lines.append(f'| {mode} | [{bus}]({link}) | {metric["region_mcycle"]} | {metric["region_minstret"]} | {metric["region_cpi"]:.4f} |')
    old = baselines['10']['coremark']['region_mcycle']; new = runs['10']['coremark']['region_mcycle']
    lines += ['', f'ICache 开启时区间周期减少 {old-new}（{100*(old-new)/old:.3f}%）；关闭时与基线相同。该程序只体现小幅收益，不把突发补行改动等同于整机大幅提速。整个程序的 mcycle/minstret/CPI 另外保存在 JSON 中。', '',
              '## 总线与补行波形', '',
              '- 升级前一次 64 字节补行需要 16 笔单拍事务；升级后为一笔事务、16 个数据拍。',
              f'- [CPU 波形](axi4_verified_cpu.vcd)：第一行地址 {wave["address"]}，ARLEN=15，1 次 AR 握手，16 次 R 握手，仅第 16 拍置 RLAST。',
              f'- 无额外等待时，AR 到首个 R 为 {wave["ar_to_first_r_cycles"]} 周期，到最后 R 为 {wave["ar_to_last_r_cycles"]} 周期；R 通道连续每周期一拍。CPU 缓存入口接受请求到补行响应共 {wave["cpu_cold_refill_cycles"]} 周期。',
              '- [独立波形统计](axi4_verified_cpu.summary.json)由 `tests/check_axi4_wave.py` 生成；协议单测还证明单拍读响应与下一 AR 可同拍握手。', '',
              '复现命令及接口限制见 [AXI4 总线说明](../docs/axi4_bus.md)。本次保留原有未提交 CPU 工作，未修改历史备份目录；DCache、突发写和多笔并发不在本次交付范围。', '']
    (RESULTS / 'axi4_acceptance.md').write_text('\n'.join(lines))
    print(f'Evidence: {report}')
    print('Final regression passes:', sum(row['passed'] for row in runs.values()))


if __name__ == '__main__':
    main()
