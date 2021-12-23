use helper::Input;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::num::ParseIntError;
use std::ops::RangeInclusive;

lazy_static! {
    static ref REGEX: Regex =
        Regex::new(r"(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)").unwrap();
}

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .transform(|line| {
            let mut instruction = line.parse::<Instruction>().unwrap();
            instruction.reduce(-50..=50);
            instruction
        })
        .into_iter()
        .fold(HashSet::new(), |mut cubes, instruction| {
            for x in instruction.x.clone() {
                for y in instruction.y.clone() {
                    for z in instruction.z.clone() {
                        match instruction.order {
                            Turn::On => cubes.insert((x, y, z)),
                            Turn::Off => cubes.remove(&(x, y, z)),
                        };
                    }
                }
            }
            cubes
        })
        .len()
}

#[allow(dead_code)]
fn part2(input: Input) -> isize {
    input
        .transform(|line| line.parse::<Instruction>().unwrap())
        .into_iter()
        .fold(
            HashMap::new(),
            |cubes: HashMap<MetaCube, isize>, instruction| {
                let cube = MetaCube::new(instruction.clone());
                let mut next = cubes.clone().iter().fold(cubes, |mut cubes, (other, v)| {
                    if let Some(intersect) = cube.intersect(other) {
                        *cubes.entry(intersect).or_insert(0) -= *v;
                    }

                    cubes
                });

                if instruction.order == Turn::On {
                    *next.entry(cube.to_owned()).or_insert(0) += 1;
                }

                next
            },
        )
        .iter()
        .fold(0, |acc, (c, v)| acc + c.cubes() * *v)
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Turn {
    On,
    Off,
}

#[derive(Debug)]
enum NoInstructionError {
    PatternNotFound,
    Parse(ParseIntError),
}

#[derive(Debug, Clone)]
struct Instruction {
    order: Turn,
    x: RangeInclusive<isize>,
    y: RangeInclusive<isize>,
    z: RangeInclusive<isize>,
}

impl From<ParseIntError> for NoInstructionError {
    fn from(err: ParseIntError) -> NoInstructionError {
        NoInstructionError::Parse(err)
    }
}

impl std::str::FromStr for Instruction {
    type Err = NoInstructionError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let captures = REGEX
            .captures(s)
            .ok_or(NoInstructionError::PatternNotFound {})?;

        Ok(Instruction {
            order: if captures[1] == *"on" {
                Turn::On
            } else {
                Turn::Off
            },
            x: str_to_range(&captures[2], &captures[3])?,
            y: str_to_range(&captures[4], &captures[5])?,
            z: str_to_range(&captures[6], &captures[7])?,
        })
    }
}

impl Instruction {
    fn reduce(&mut self, range: RangeInclusive<isize>) {
        self.x = reduce_range(self.x.clone(), range.clone());
        self.y = reduce_range(self.y.clone(), range.clone());
        self.z = reduce_range(self.z.clone(), range.clone());
    }
}

fn str_to_range(r1: &str, r2: &str) -> Result<RangeInclusive<isize>, std::num::ParseIntError> {
    let v1 = r1.parse::<isize>()?;
    let v2 = r2.parse::<isize>()?;
    Ok(v1.min(v2)..=v1.max(v2))
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct MetaCube {
    x: RangeInclusive<isize>,
    y: RangeInclusive<isize>,
    z: RangeInclusive<isize>,
}

impl MetaCube {
    fn new(instruction: Instruction) -> Self {
        MetaCube {
            x: instruction.x.clone(),
            y: instruction.y.clone(),
            z: instruction.z.clone(),
        }
    }

    fn intersect(&self, other: &MetaCube) -> Option<MetaCube> {
        let x = reduce_range(self.x.clone(), other.x.clone());
        let y = reduce_range(self.y.clone(), other.y.clone());
        let z = reduce_range(self.z.clone(), other.z.clone());
        if x.is_empty() || y.is_empty() || z.is_empty() {
            return None;
        }

        Some(MetaCube {
            x: x.clone(),
            y: y.clone(),
            z: z.clone(),
        })
    }

    fn cubes(&self) -> isize {
        (self.x.end() - self.x.start() + 1)
            * (self.y.end() - self.y.start() + 1)
            * (self.z.end() - self.z.start() + 1)
    }
}

fn reduce_range(
    initial: RangeInclusive<isize>,
    target: RangeInclusive<isize>,
) -> RangeInclusive<isize> {
    *target.start().max(initial.start())..=*target.end().min(initial.end())
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 22, 2021).unwrap();
        assert_eq!(super::part1(test_input), 590784);

        let input = Input::new("inputs/input.txt".to_string(), 22, 2021).unwrap();
        assert_eq!(super::part1(input), 644257)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test_p2.txt".to_string(), 22, 2021).unwrap();
        assert_eq!(super::part2(test_input), 2758514936282235);

        let input = Input::new("inputs/input.txt".to_string(), 22, 2021).unwrap();
        assert_eq!(super::part2(input), 644257)
    }
}
