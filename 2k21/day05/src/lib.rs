use helper::Input;
use itertools::Either;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::error::Error;
use std::str::FromStr;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .transform(|line| line.parse::<Vent>().unwrap())
        .filter(|v| v.p1.x == v.p2.x || v.p1.y == v.p2.y)
        .fold(HashMap::new(), |clouds, vent| {
            if vent.p1.x == vent.p2.x {
                range_inline_distance(vent.p1.y, vent.p2.y).fold(clouds, |mut clds, y| {
                    *clds.entry((vent.p1.x, y)).or_insert(0) += 1;
                    clds
                })
            } else {
                range_inline_distance(vent.p1.x, vent.p2.x).fold(clouds, |mut clds, x| {
                    *clds.entry((x, vent.p1.y)).or_insert(0) += 1;
                    clds
                })
            }
        })
        .iter()
        .filter(|(_key, v)| **v > 1)
        .count()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    input
        .transform(|line| line.parse::<Vent>().unwrap())
        .fold(HashMap::new(), |clouds, vent| {
            if vent.p1.x == vent.p2.x {
                range_inline_distance(vent.p1.y, vent.p2.y).fold(clouds, |mut clds, y| {
                    *clds.entry((vent.p1.x, y)).or_insert(0) += 1;
                    clds
                })
            } else if vent.p1.y == vent.p2.y {
                range_inline_distance(vent.p1.x, vent.p2.x).fold(clouds, |mut clds, x| {
                    *clds.entry((x, vent.p1.y)).or_insert(0) += 1;
                    clds
                })
            } else {
                range_diagonal_distance(vent.p1, vent.p2).fold(clouds, |mut clds, (dx, dy)| {
                    *clds.entry((dx, dy)).or_insert(0) += 1;
                    clds
                })
            }
        })
        .iter()
        .filter(|(_key, v)| **v > 1)
        .count()
}

lazy_static! {
    static ref VENT_REGEX: Regex = Regex::new(r"(\d+),(\d+)\s+->\s+(\d+),(\d+)").unwrap();
}

#[derive(Debug)]
pub struct Point {
    x: isize,
    y: isize,
}

#[derive(Debug)]
struct Vent {
    p1: Point,
    p2: Point,
}

impl Vent {
    fn new(data: &[isize]) -> Vent {
        Vent {
            p1: Point {
                x: data[0],
                y: data[1],
            },
            p2: Point {
                x: data[2],
                y: data[3],
            },
        }
    }
}

impl FromStr for Vent {
    type Err = Box<dyn Error>;

    fn from_str(input: &str) -> Result<Vent, Self::Err> {
        match VENT_REGEX.captures(input) {
            Some(data) => {
                let parsed: Vec<isize> = data
                    .iter()
                    .skip(1)
                    .filter_map(|cap| cap)
                    .filter_map(|value| value.as_str().parse::<isize>().ok())
                    .collect();
                Ok(Vent::new(&parsed[..4]))
            }
            None => unreachable!(),
        }
    }
}

fn range_inline_distance(c1: isize, c2: isize) -> std::ops::RangeInclusive<isize> {
    if c1 > c2 {
        c2..=c1
    } else {
        c1..=c2
    }
}

pub fn range_diagonal_distance(p1: Point, p2: Point) -> impl Iterator<Item = (isize, isize)> {
    let dx = p2.x - p1.x;
    let dy = p2.y - p1.y;

    let rx = if dx > 0 {
        Either::Left(p1.x..=p1.x + dx)
    } else {
        Either::Right((p2.x..=p2.x + dx.abs()).rev())
    };

    let ry = if dy > 0 {
        Either::Left(p1.y..=p1.y + dy)
    } else {
        Either::Right((p2.y..=p2.y + dx.abs()).rev())
    };

    rx.zip(ry)
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_range_diagonal_distance() {
        use super::Point;
        let p1 = Point { x: 9, y: 7 };
        let p2 = Point { x: 7, y: 9 };

        assert_eq!(
            super::range_diagonal_distance(p1, p2).collect::<Vec<_>>(),
            vec![(9, 7), (8, 8), (7, 9)]
        )
    }

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part1(test_input), 5);

        let input = Input::new("./inputs/input.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part1(input), 5294)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part2(test_input), 12);

        let input = Input::new("./inputs/input.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part2(input), 21698)
    }
}
