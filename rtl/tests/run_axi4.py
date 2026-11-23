#!/usr/bin/env python3
"""AXI4 units and CPU regression. Use --cache-mode 00/10/01/11; other options
match run_cache.py. --delay adds independent AXI channel and native waits.
"""
import sys
import run_axi4_units
import run_cache

if __name__ == '__main__':
    if not any(flag in sys.argv for flag in ('--binary', '--baseline', '--help', '-h')):
        run_axi4_units.main()
    run_cache.main()
