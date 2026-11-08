#!/usr/bin/env python3
"""Darwin-only suite timeout adapter; preserves GNU timeout's 124 deadline status."""
import os
import signal
import subprocess
import sys

limit = float(sys.argv[1])
process = subprocess.Popen(sys.argv[2:], start_new_session=True)
def stop_group(signum, _frame=None):
    try:
        os.killpg(process.pid, signum)
    except ProcessLookupError:
        pass
signal.signal(signal.SIGTERM, lambda signum, frame: stop_group(signum))
signal.signal(signal.SIGINT, lambda signum, frame: stop_group(signum))
try:
    status = process.wait(timeout=limit)
except subprocess.TimeoutExpired:
    stop_group(signal.SIGTERM)
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        stop_group(signal.SIGKILL)
        process.wait()
    sys.exit(124)
sys.exit(status if status >= 0 else 128 - status)
