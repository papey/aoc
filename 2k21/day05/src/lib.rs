use helper::Input;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::error::Error;
use std::str::FromStr;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .transform(|line| line.parse::<Vent>().unwrap())
        .into_iter()
        .filter(|v| v.p1.x == v.p2.x || v.p1.y == v.p2.y)
        .fold(HashMap::new(), |clouds, vent| {
            if vent.p1.x == vent.p2.x {
                range_distance(vent.p1.y, vent.p2.y).fold(clouds, |mut clds, y| {
                    *clds.entry((vent.p1.x, y)).or_insert(0) += 1;
                    clds
                })
            } else {
                range_distance(vent.p1.x, vent.p2.x).fold(clouds, |mut clds, x| {
                    *clds.entry((x, vent.p1.y)).or_insert(0) += 1;
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
struct Point {
    x: usize,
    y: usize,
}

#[derive(Debug)]
struct Vent {
    p1: Point,
    p2: Point,
}

impl Vent {
    fn new(data: &[usize]) -> Vent {
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
                let parsed: Vec<usize> = data
                    .iter()
                    .skip(1)
                    .filter_map(|cap| cap)
                    .filter_map(|value| value.as_str().parse::<usize>().ok())
                    .collect();
                Ok(Vent::new(&parsed[..4]))
            }
            None => unreachable!(),
        }
    }
}

fn range_distance(c1: usize, c2: usize) -> std::ops::Range<usize> {
    if c1 > c2 {
        c2..c1 + 1
    } else {
        c1..c2 + 1
    }
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part1(test_input), 5);

        let input = Input::new("./inputs/input.txt".to_string(), 5, 2021).unwrap();
        assert_eq!(super::part1(input), 5294)
    }
}
