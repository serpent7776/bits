#!/usr/bin/env python3
# source: https://twitter.com/UnixToolTip/status/1762902215398678965
import sys

cp = sys.argv[1]
ch = eval(f"chr(0x{cp})")
print(ch)
