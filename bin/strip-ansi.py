#!/usr/bin/env python
import re

ansi_pattern = '\033\[((?:\d|;)*)([a-zA-Z])'
ansi_eng = re.compile(ansi_pattern)

def strip_escape(string=''):
    lastend = 0
    matches = []
    newstring = str(string)
    for match in ansi_eng.finditer(string):
        start = match.start()
        end = match.end()
        matches.append(match)
    matches.reverse()
    for match in matches:
        start = match.start()
        end = match.end()
        string = string[0:start] + string[end:]
    return string

if __name__ == '__main__':
    import sys
    import os

    lname = sys.argv[-1]
    fname = os.path.basename(__file__)
    if lname != fname:
        with open(lname, 'r') as fd:
            for line in fd.readlines():
                print strip_escape(line).rstrip()
    else:
        USAGE = '%s <filename>' % fname
        print USAGE

