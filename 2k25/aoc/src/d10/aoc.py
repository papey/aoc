#!/usr/bin/env python3
from collections import defaultdict

from z3 import Int, Optimize, IntVector, sat

def parse_problem(line):
    parts = line.strip().split(' ')
    buttons = [[int(b) for b in part[1:-1].split(',')] for part in parts[1:-1]]
    joltages = [int(j) for j in parts[-1][1:-1].split(',')]
    return buttons, joltages

def solve(buttons, joltages):
    opt = Optimize()

    b_vars = IntVector('b', len(buttons))
    total_presses = Int('total')

    index_to_vars = defaultdict(list)
    for b_var, indices in zip(b_vars, buttons):
        for index in indices:
            index_to_vars[index].append(b_var)

    for i, target_val in enumerate(joltages):
        opt.add(sum(index_to_vars[i]) == target_val)

    opt.add([b >= 0 for b in b_vars])

    opt.add(total_presses == sum(b_vars))
    opt.minimize(total_presses)

    if opt.check() == sat:
        return opt.model()[total_presses].as_long()

    return None


problems = [parse_problem(l) for l in open('../../inputs/d10.txt').readlines()]
solutions = [solve(buttons, joltages) for buttons, joltages in problems]

print(f"p2: {sum(solutions)}")
