use helper::Input;
use std::collections::VecDeque;

#[allow(dead_code)]
fn part1(input: Input) -> u32 {
    let mut data = parse(input.first());

    let pkg = Pkg::new(&mut data);

    checksum(&pkg)
}

#[allow(dead_code)]
fn part2(input: Input) -> u64 {
    let mut data = parse(input.first());

    let pkg = Pkg::new(&mut data);

    value(&pkg)
}

fn value(pkg: &Pkg) -> u64 {
    match pkg {
        Pkg::Literal(_, value) => *value,
        Pkg::Operator(_, 0, pkgs) => pkgs.iter().map(value).sum(),
        Pkg::Operator(_, 1, pkgs) => pkgs.iter().map(value).product(),
        Pkg::Operator(_, 2, pkgs) => pkgs.iter().map(value).min().unwrap(),
        Pkg::Operator(_, 3, pkgs) => pkgs.iter().map(value).max().unwrap(),
        Pkg::Operator(_, 5, pkgs) => (value(&pkgs[0]) > value(&pkgs[1])) as u64,
        Pkg::Operator(_, 6, pkgs) => (value(&pkgs[0]) < value(&pkgs[1])) as u64,
        Pkg::Operator(_, 7, pkgs) => (value(&pkgs[0]) == value(&pkgs[1])) as u64,
        _ => unreachable!(),
    }
}

fn checksum(pkg: &Pkg) -> u32 {
    match pkg {
        Pkg::Literal(v, _) => *v,
        Pkg::Operator(v, _, pkgs) => pkgs.iter().fold(*v, |acc, pkg| acc + checksum(pkg)),
    }
}

fn parse(data: String) -> VecDeque<u8> {
    data.chars()
        .flat_map(|ch| {
            let value = ch.to_digit(16).unwrap_or_default() as u8;
            (0..4).rev().map(move |shift| (value >> shift) & 0x1)
        })
        .collect::<VecDeque<_>>()
}

fn consume(bits: &mut VecDeque<u8>, len: usize) -> u32 {
    (0..len).rev().fold(0, |acc, index| match bits.pop_front() {
        Some(1) => acc | (1 << index),
        _ => acc,
    })
}

fn consume_literal(bits: &mut VecDeque<u8>, value: u64) -> u64 {
    (0..4)
        .rev()
        .fold(value, |acc, _| (acc << 1) | consume(bits, 1) as u64)
}

#[derive(Debug)]
enum Pkg {
    Literal(u32, u64),
    Operator(u32, u32, Vec<Pkg>),
}

const TYPE_LITERAL: u32 = 4;

impl Pkg {
    fn new(bits: &mut VecDeque<u8>) -> Pkg {
        let v = consume(bits, 3);
        match consume(bits, 3) {
            TYPE_LITERAL => {
                let mut res = 0;
                loop {
                    let end = consume(bits, 1) == 0;

                    res = consume_literal(bits, res);

                    if end {
                        break;
                    }
                }
                Pkg::Literal(v, res)
            }
            type_id => {
                let pkgs = match consume(bits, 1) {
                    0 => {
                        let mut sub = std::iter::repeat(0).take(consume(bits, 15) as usize).fold(
                            VecDeque::new(),
                            |mut acc, _| {
                                acc.push_back(consume(bits, 1) as u8);
                                acc
                            },
                        );
                        std::iter::from_fn(|| {
                            if sub.is_empty() {
                                return None;
                            }

                            Some(Pkg::new(&mut sub))
                        })
                        .collect::<Vec<_>>()
                    }
                    1 => (0..consume(bits, 11))
                        .map(|_| Pkg::new(bits))
                        .collect::<Vec<_>>(),
                    _ => unreachable!(),
                };
                Pkg::Operator(v, type_id, pkgs)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test_p1.txt".to_string(), 16, 2021).unwrap();
        assert_eq!(super::part1(test_input), 31);

        let input = Input::new("inputs/input.txt".to_string(), 16, 2021).unwrap();
        assert_eq!(super::part1(input), 852);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test_p2.txt".to_string(), 16, 2021).unwrap();
        assert_eq!(super::part2(test_input), 1);

        let input = Input::new("inputs/input.txt".to_string(), 16, 2021).unwrap();
        assert_eq!(super::part2(input), 19348959966392);
    }
}
