#!/usr/bin/env python3
"""Independently inspect the first CPU refill in a Verilator VCD.
Usage: python3 tests/check_axi4_wave.py test_results/axi4_verified_cpu.vcd
"""
import json
from pathlib import Path
import sys


def inspect(path):
    scope, names, values = [], {}, {}
    wanted = ['bridge_axi_arvalid', 'axi_bridge_arready', 'bridge_axi_araddr',
              'bridge_axi_arlen', 'axi_bridge_rvalid', 'bridge_axi_rready',
              'axi_bridge_rlast', 'axi_bridge_rresp', 'axi_bridge_rid',
              'cache_cpu_req_valid', 'cache_cpu_req_ready', 'cache_cpu_rsp_valid',
              'cache_cpu_rsp_ready', 'cache_cpu_rsp_source', 'cache_cpu_rsp_error']
    cycle, start, burst, beats, first_request = 0, None, None, [], None
    response = None
    def sample():
        nonlocal cycle, start, burst, first_request, response
        cycle += 1
        def v(name):
            return values.get(names[name], 0)
        if first_request is None and v('cache_cpu_req_valid') & v('cache_cpu_req_ready') & 1:
            first_request = cycle
        if (first_request is not None and response is None and
                v('cache_cpu_rsp_valid') & v('cache_cpu_rsp_ready') & 1 and
                v('cache_cpu_rsp_source') & 3 == 3):
            assert not v('cache_cpu_rsp_error') & 1
            response = cycle
        if v('bridge_axi_arvalid') and v('axi_bridge_arready'):
            if start is None:
                assert v('bridge_axi_arlen') == 15, 'first fetch was not a burst'
                start = cycle
                burst = {'address': hex(v('bridge_axi_araddr')), 'arlen': 15}
            elif len(beats) < 16:
                raise AssertionError('another AR was issued before the refill completed')
        if start is not None and len(beats) < 16 and v('axi_bridge_rvalid') and v('bridge_axi_rready'):
            assert v('axi_bridge_rid') == 0 and v('axi_bridge_rresp') == 0
            assert v('axi_bridge_rlast') == (len(beats) == 15), 'RLAST position'
            beats.append(cycle)
    with Path(path).open() as source:
        for line in source:
            tokens = line.split()
            if not tokens:
                continue
            if tokens[0] == '$scope': scope.append(tokens[2])
            elif tokens[0] == '$upscope': scope.pop()
            elif tokens[0] == '$var':
                where = '.'.join(scope)
                target = ('TOP.testbench.top.u_core' if tokens[4].startswith('cache_cpu_')
                          else 'TOP.testbench.top')
                if where == target and tokens[4] in wanted:
                    names[tokens[4]] = tokens[3]
                elif where == 'TOP.testbench' and tokens[4] == 'clk':
                    names['clk'] = tokens[3]
            elif tokens[0] == '$enddefinitions': break
        assert len(names) == len(wanted)+1, 'wave does not contain the CPU AXI/cache signals'
        tracked = set(names.values())
        changes = {}
        def flush():
            if changes.get(names['clk']) == 1 and values.get(names['clk'], 0) == 0:
                sample()  # sample the payload before sequential state changes
            values.update(changes)
            changes.clear()
        for line in source:
            line = line.strip()
            if line.startswith('#'):
                flush()
                if len(beats) == 16 and response is not None: break
            elif line and line[0] in '01':
                if line[1:] in tracked: changes[line[1:]] = int(line[0])
            elif line.startswith('b'):
                number, name = line[1:].split()
                if name in tracked and set(number) <= {'0', '1'}: changes[name] = int(number, 2)
        flush()
    assert len(beats) == 16 and response is not None, 'refill not completed'
    assert all(b == a+1 for a, b in zip(beats, beats[1:])), 'zero-wait R stream has bubbles'
    return {**burst, 'ar_handshakes': 1, 'r_handshakes': len(beats),
            'last_only_on_beat': 16, 'ar_to_first_r_cycles': beats[0]-start,
            'ar_to_last_r_cycles': beats[-1]-start,
            'cpu_cold_refill_cycles': response-first_request, 'wave': str(path)}


if __name__ == '__main__':
    wave = Path(sys.argv[1])
    result = inspect(wave)
    output = wave.with_suffix('.summary.json')
    output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))
