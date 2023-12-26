import sympy


class Hailstone:
    def __init__(self, raw_input):
        (sx, sy, sz) = map(int, raw_input.split("@")[0].split(","))
        (vx, vy, vz) = map(int, raw_input.split("@")[1].split(","))

        self.sx = sx
        self.sy = sy
        self.sz = sz

        self.vx = vx
        self.vy = vy
        self.vz = vz


def in_bound(x, y):
    return 2e14 <= x <= 4e14 and 2e14 <= y <= 4e14


def is_future(hs1, hs2, x, y):
    return all([(x - hs.sx) * hs.vx >= 0 and (y - hs.sy) * hs.vy >= 0 for hs in [hs1, hs2]])


def part1(hs):
    total = 0

    for i, hs1 in enumerate(hs):
        for hs2 in hs[:i]:
            px, py = sympy.symbols("px py")
            solutions = sympy.solve([hs.vy * (px - hs.sx) - hs.vx * (py - hs.sy) for hs in [hs1, hs2]])
            if solutions:
                x, y = solutions[px], solutions[py]
                if in_bound(x, y) and is_future(hs1, hs2, x, y):
                    total += 1

    print("Part 1:", total)


def part2(hs):
    xr, yr, zr, vxr, vyr, vzr = sympy.symbols("xr yr zr vxr vyr vzr")
    equations = []

    for h in hs:
        equations.append((xr - h.sx) * (h.vy - vyr) - (yr - h.sy) * (h.vx - vxr))
        equations.append((yr - h.sy) * (h.vz - vzr) - (zr - h.sz) * (h.vy - vyr))

    answers = sympy.solve(equations)

    print("Part 2:", answers[0][xr] + answers[0][yr] + answers[0][zr])


hailstones = [Hailstone(line) for line in open("../../main/resources/24.txt", "r").readlines() if line.strip() != ""]

part1(hailstones)

part2(hailstones)
