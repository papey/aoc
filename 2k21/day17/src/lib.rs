use helper::Input;
use itertools::Itertools;
use lazy_static::lazy_static;
use regex::Regex;
use std::ops::RangeInclusive;
use std::str::FromStr;

#[allow(dead_code)]
fn part1(input: Input) -> isize {
    let area = Area::from_str(&input.first()).unwrap();

    let (_, candidates) = (0..*area.x.end())
        .cartesian_product(*area.y.start()..(*area.y.start()).abs())
        .map(|(vx, vy)| Probe::new(vx, vy))
        .fold((area, Vec::new()), |(area, mut candidates), mut probe| {
            let m = std::iter::from_fn(move || {
                probe.step();
                Some(probe)
            })
            .take_while(|p| !p.is_in(&area) && p.can_hit(&area))
            .map(|p| p.pos.1)
            .max();

            if let Some(max) = m {
                candidates.push(max)
            }

            (area, candidates)
        });

    *candidates.iter().max().unwrap_or(&isize::MIN)
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let area = Area::from_str(&input.first()).unwrap();

    let (_, candidates) = (0..*area.x.end() + 1)
        .cartesian_product(*area.y.start()..(*area.y.start()).abs() + 1)
        .map(|(vx, vy)| Probe::new(vx, vy))
        .fold((area, 0), |(area, candidates), mut probe| {
            let is_in = std::iter::from_fn(move || {
                probe.step();
                Some(probe)
            })
            .skip_while(|p| !p.is_in(&area) && p.can_hit(&area))
            .take(1)
            .map(|p| p.is_in(&area))
            .last()
            .unwrap_or_default();

            (area, candidates + (is_in as usize))
        });

    candidates
}

#[derive(Debug, Clone, Copy)]
struct Probe {
    pos: (isize, isize),
    vel: (isize, isize),
}

impl Probe {
    fn new(xvel: isize, yvel: isize) -> Probe {
        Probe {
            pos: (0, 0),
            vel: (xvel, yvel),
        }
    }

    fn step(&mut self) {
        self.pos.0 += self.vel.0;
        self.pos.1 += self.vel.1;

        if self.vel.0 != 0 {
            self.vel.0 -= 1;
        }
        self.vel.1 -= 1;
    }

    fn is_in(&self, area: &Area) -> bool {
        area.x.contains(&self.pos.0) && area.y.contains(&self.pos.1)
    }

    fn can_hit(&self, area: &Area) -> bool {
        self.pos.1 > *area.y.start()
            && (area.x.contains(&self.pos.0) || self.vel.0 > 0 && self.pos.0 <= *area.x.end())
    }
}

lazy_static! {
    static ref AREA_REGEX: Regex =
        Regex::new(r"target area: x=(\d+)..(\d+), y=(-\d+)..(-\d+)").unwrap();
}

#[derive(Debug)]
#[allow(dead_code)]
struct Area {
    x: RangeInclusive<isize>,
    y: RangeInclusive<isize>,
}

#[derive(Debug)]
struct AreaNotFoundError {}

impl FromStr for Area {
    type Err = AreaNotFoundError;

    fn from_str(s: &str) -> Result<Area, AreaNotFoundError> {
        if let Some(captures) = AREA_REGEX.captures(s) {
            let limits = captures
                .iter()
                .skip(1)
                .take(4)
                .filter_map(|result| {
                    if let Some(raw) = result {
                        return raw.as_str().parse::<isize>().ok();
                    }
                    None
                })
                .collect::<Vec<_>>();

            return Ok(Area {
                x: limits[0]..=limits[1],
                y: limits[2]..=limits[3],
            });
        }

        Err(AreaNotFoundError {})
    }
}

impl Area {}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 17, 2021).unwrap();
        assert_eq!(super::part1(test_input), 45);

        let input = Input::new("inputs/input.txt".to_string(), 17, 2021).unwrap();
        assert_eq!(super::part1(input), 13041)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 17, 2021).unwrap();
        assert_eq!(super::part2(test_input), 112);

        let input = Input::new("inputs/input.txt".to_string(), 17, 2021).unwrap();
        assert_eq!(super::part2(input), 1031)
    }
}
