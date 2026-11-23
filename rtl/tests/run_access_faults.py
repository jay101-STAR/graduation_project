#!/usr/bin/env python3
"""Build and verify precise access faults without changing the system HEX files."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess

RTL = Path(__file__).resolve().parents[1]


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('--cache-mode', action='append', choices=('00', '10', '01', '11'))
    cli.add_argument('--case', type=int, action='append', choices=range(24))
    cli.add_argument('--delay', type=int, action='append', default=None)
    cli.add_argument('--seed', type=int, default=493)
    cli.add_argument('--fault-beat', type=int, action='append', choices=range(16))
    cli.add_argument('--binary', type=Path, help='Reuse one cache-mode build')
    args = cli.parse_args()
    modes=args.cache_mode or ['11']
    if args.binary and len(modes)!=1:
        cli.error('--binary requires one cache mode')
    stamp=datetime.now().strftime('%Y%m%d_%H%M%S_%f')
    out=RTL/'test_results'/f'access_faults_tests_{stamp}'
    out.mkdir(parents=True)
    buildroot=Path('/tmp')/out.name
    buildroot.mkdir()
    elf=buildroot/'access_faults.elf'
    compile_cmd=['riscv32-unknown-elf-gcc','-march=rv32im_zicsr_zifencei','-mabi=ilp32',
                 '-nostdlib','-nostartfiles','-Wl,--no-relax,-Ttext=0x80000000',
                 str(RTL/'vsrc/instrom/access_faults.s'),'-o',str(elf)]
    with (out/'assembly.log').open('w') as log:
        subprocess.run(compile_cmd,check=True,stdout=log,stderr=subprocess.STDOUT)
    binary_image=elf.with_suffix('.bin')
    subprocess.run(['riscv32-unknown-elf-objcopy','-O','binary',str(elf),str(binary_image)],check=True)
    data=binary_image.read_bytes()
    image=buildroot/'image.hex'
    image.write_text(''.join(f'{int.from_bytes(data[k:k+4],"little"):08x}\n' for k in range(0,len(data),4)))
    nm=subprocess.check_output(['riscv32-unknown-elf-nm',str(elf)],text=True)
    symbols={row.split()[2]:int(row.split()[0],16) for row in nm.splitlines() if len(row.split())==3}
    (out/'symbols.json').write_text(json.dumps(symbols,indent=2)+'\n')
    sources=sorted(p for p in (RTL/'vsrc').rglob('*') if p.suffix in ('.v','.sv') and p.name!='testbench.v')
    records=[]
    builds=[]
    for mode in modes:
        binary=args.binary
        if binary is None:
            build=buildroot/f'mode{mode}'
            command=['verilator','--binary','--timing','--trace','--trace-depth','7','-Wno-fatal',
                     '--unroll-count','256','--top-module','access_faults_tb','--Mdir',str(build),'-j','4',
                     f'-GICACHE_ENABLE={mode[0]}',f'-GDCACHE_ENABLE={mode[1]}',*map(str,sources),str(RTL/'tests/access_faults_tb.sv')]
            with (out/f'build_{mode}.log').open('w') as log:
                subprocess.run(command,cwd=RTL,check=True,stdout=log,stderr=subprocess.STDOUT,timeout=180,
                               env={**os.environ,'CCACHE_DIR':'/tmp/access_faults_ccache'})
            binary=build/'Vaccess_faults_tb'
            builds.append({'mode':mode,'binary':str(binary),'command':command})
        for delay in args.delay or [0,5]:
            for beat in args.fault_beat or [7]:
                for case in args.case or list(range(24)):
                    label=f'mode{mode}_delay{delay}_beat{beat}_case{case}'
                    log=out/f'{label}.log'
                    wave=out/f'{label}.vcd'
                    command=[str(binary),f'+image={image}',f'+case={case}',f'+delay={delay}',
                             f'+seed={args.seed}',f'+fault_beat={beat}',
                             f'+wrong_path_pc={symbols["wrong_path_pc"]:x}',f'+wave={wave}']
                    with log.open('w') as stream:
                        result=subprocess.run(command,cwd=RTL,stdout=stream,stderr=subprocess.STDOUT,timeout=30)
                    passed=result.returncode==0 and '[ACCESS-FAULTS] PASS' in log.read_text()
                    records.append({'mode':mode,'case':case,'delay':delay,'fault_beat':beat,'passed':passed,
                                    'log':str(log),'wave':str(wave),'command':command})
                    (out/'manifest.json').write_text(json.dumps({'builds':builds,'tests':records,'assembly_command':compile_cmd},indent=2)+'\n')
                    print(label,'PASS' if passed else 'FAIL',flush=True)
                    if not passed:
                        raise RuntimeError(log.read_text())
    print(f'Evidence: {out}/manifest.json',flush=True)


if __name__=='__main__':
    main()
