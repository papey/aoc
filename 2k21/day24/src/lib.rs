use either::Either;
use helper::Input;
use std::{
    collections::{HashSet, VecDeque},
    hash::Hash,
};

const CHUNK_SIZE: usize = 18;
const MODEL_NUMBER_SIZE: u32 = 14;

#[allow(dead_code)]
fn part1(input: Input) -> i64 {
    let variables: Vec<(i64, i64, i64)> = parse_program(&input)
        .chunks(CHUNK_SIZE)
        .map(|insts| {
            (
                insts[4].operand().unwrap().immediate().unwrap() as i64,
                insts[5].operand().unwrap().immediate().unwrap() as i64,
                insts[15].operand().unwrap().immediate().unwrap() as i64,
            )
        })
        .collect();

    find(
        &mut HashSet::new(),
        0,
        &variables,
        Either::Left((1..=9).rev()),
        0,
    )
    .unwrap()
}

#[allow(dead_code)]
fn part2(input: Input) -> i64 {
    let variables: Vec<(i64, i64, i64)> = parse_program(&input)
        .chunks(CHUNK_SIZE)
        .map(|insts| {
            (
                insts[4].operand().unwrap().immediate().unwrap() as i64,
                insts[5].operand().unwrap().immediate().unwrap() as i64,
                insts[15].operand().unwrap().immediate().unwrap() as i64,
            )
        })
        .collect();

    find(&mut HashSet::new(), 0, &variables, Either::Right(1..=9), 0).unwrap()
}

type Range =
    Either<std::iter::Rev<std::ops::RangeInclusive<usize>>, std::ops::RangeInclusive<usize>>;

fn find(
    cache: &mut HashSet<(usize, i64)>,
    block_no: usize,
    variables: &Vec<(i64, i64, i64)>,
    range: Range,
    z: i64,
) -> Option<i64> {
    if block_no == variables.len() {
        if z == 0 {
            return Some(0);
        } else {
            return None;
        }
    }

    if cache.contains(&(block_no, z)) {
        return None;
    }

    let (v1, v2, v3) = variables.get(block_no).unwrap();

    // clone before consuming by the for loop
    let r = range.clone();

    for i in range {
        let z = if z % 26 + v2 == i as i64 {
            z / v1
        } else {
            (z / v1) * 26 + i as i64 + v3
        };

        // clone range on each iteration, we do not want it to be moved
        if let Some(j) = find(cache, block_no + 1, variables, r.clone(), z) {
            return Some(i as i64 * 10i64.pow(MODEL_NUMBER_SIZE - (block_no + 1) as u32) + j);
        }
    }

    cache.insert((block_no, z));
    None
}

#[allow(dead_code)]
fn run(regs: &mut Registers, inp: &mut Inp, program: &Vec<Instruction>) {
    program.iter().fold((regs, inp), |(regs, inp), inst| {
        inst.eval(regs, inp);
        (regs, inp)
    });
}

fn parse_program(input: &Input) -> Vec<Instruction> {
    input
        .lines()
        .iter()
        .map(|line| {
            let parts: Vec<&str> = line.split_whitespace().collect();
            let reg = to_char(parts[1]);

            match parts[0] {
                "inp" => Instruction::Inp(reg),
                "add" => Instruction::Add(reg, Operand::new(parts[2])),
                "mul" => Instruction::Mul(reg, Operand::new(parts[2])),
                "div" => Instruction::Div(reg, Operand::new(parts[2])),
                "mod" => Instruction::Mod(reg, Operand::new(parts[2])),
                "eql" => Instruction::Eql(reg, Operand::new(parts[2])),
                _ => unreachable!(),
            }
        })
        .collect()
}

#[derive(Debug)]
enum Operand {
    Immediate(isize),
    Reg(char),
}

impl Operand {
    fn new(data: &str) -> Self {
        if ["w", "x", "y", "z"].contains(&data) {
            return Operand::Reg(to_char(data));
        }

        Operand::Immediate(data.parse::<isize>().unwrap_or_default())
    }

    fn value(&self, regs: &Registers) -> isize {
        match self {
            Self::Reg(a) => regs.get(*a),
            Self::Immediate(v) => *v,
        }
    }

    fn immediate(&self) -> Option<isize> {
        match self {
            &Self::Immediate(v) => Some(v),
            _ => None,
        }
    }
}

#[derive(Debug)]
enum Instruction {
    Inp(char),
    Add(char, Operand),
    Mul(char, Operand),
    Div(char, Operand),
    Mod(char, Operand),
    Eql(char, Operand),
}

impl Instruction {
    fn eval(&self, regs: &mut Registers, inputs: &mut Inp) {
        match self {
            Self::Inp(reg) => regs.set(*reg, inputs.pop().unwrap()),
            Self::Add(reg, ope) => regs.set(*reg, regs.get(*reg) + ope.value(regs)),
            Self::Mul(reg, ope) => regs.set(*reg, regs.get(*reg) * ope.value(regs)),
            Self::Div(reg, ope) => regs.set(*reg, regs.get(*reg) / ope.value(regs)),
            Self::Mod(reg, ope) => regs.set(*reg, regs.get(*reg) % ope.value(regs)),
            Self::Eql(reg, ope) => {
                if regs.get(*reg) == ope.value(regs) {
                    regs.set(*reg, 1)
                } else {
                    regs.set(*reg, 0)
                }
            }
        }
    }

    fn operand(&self) -> Option<&Operand> {
        match self {
            Self::Inp(_) => None,
            Self::Add(_, ope) => Some(ope),
            Self::Mul(_, ope) => Some(ope),
            Self::Div(_, ope) => Some(ope),
            Self::Mod(_, ope) => Some(ope),
            Self::Eql(_, ope) => Some(ope),
        }
    }
}

#[derive(Debug)]
struct Inp {
    value: VecDeque<isize>,
}

#[allow(dead_code)]
impl Inp {
    fn new(value: isize) -> Self {
        let (numbers, _) =
            (0..value.to_string().len()).fold((VecDeque::new(), value), |(mut acc, value), _| {
                acc.push_front(value % 10);
                (acc, value / 10)
            });
        Inp { value: numbers }
    }

    fn pop(&mut self) -> Option<isize> {
        self.value.pop_front()
    }
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
struct Registers {
    values: [isize; 4],
}

#[allow(dead_code)]
impl Registers {
    fn new() -> Self {
        Registers {
            values: [0, 0, 0, 0],
        }
    }

    fn get(&self, name: char) -> isize {
        self.values[self.to_idx(name)]
    }

    fn set(&mut self, name: char, value: isize) {
        self.values[self.to_idx(name)] = value
    }

    fn to_idx(&self, name: char) -> usize {
        match name {
            'w' => 0,
            'x' => 1,
            'y' => 2,
            'z' => 3,
            _ => unreachable!(),
        }
    }
}

fn to_char(data: &str) -> char {
    data.chars().nth(0).unwrap_or_default()
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input: Input = Input::new("inputs/input.txt".to_string(), 24, 2021).unwrap();
        assert_eq!(super::part1(test_input), 92969593497992)
    }

    #[test]
    fn test_p2() {
        let test_input: Input = Input::new("inputs/input.txt".to_string(), 24, 2021).unwrap();
        assert_eq!(super::part2(test_input), 81514171161381)
    }
}
