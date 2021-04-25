#!/usr/bin/env python3
'''
Reads from numberlink https://github.com/thomasahle/numberlink and converts it
to something we can easily input to our level packs.

USAGE:
python3 /path/to/numberlink/gen/gen.py --no-colors --terminal-only 4 4 5 | scripts/parse_numberlink.py
'''

import sys

class _Puzzle(object): 
    pass

def process_lines(lines):
    puzzles = []
    curr_puzzle = None
    for line in lines:
        if curr_puzzle is None:
            curr_puzzle = _Puzzle()
            mStr, nStr = line.split(' ', 1)
            curr_puzzle.dimensions = (int(mStr), int(nStr))
            curr_puzzle.lines = []
        elif len(curr_puzzle.lines) < curr_puzzle.dimensions[1]:
            curr_puzzle.lines.append(line.strip())
        else:
            # should be empty
            puzzles.append(curr_puzzle)
            curr_puzzle = None

    rs = "123456"
    starts = "abcdef"
    ends = "ABCDEF"
    for p in puzzles:
        puzzle_str = ''.join(p.lines)
        for r, s, e in zip(rs, starts, ends):
            puzzle_str = puzzle_str.replace(r, s, 1)
            puzzle_str = puzzle_str.replace(r, e, 1)
        print("- board: %s" % puzzle_str)


if __name__ == '__main__':
    if sys.stdin.isatty():
        print(__doc__)
    else:
        process_lines(line for line in sys.stdin)
