use helper::Input;
use std::collections::HashMap;

type Coords = (usize, usize);
type Octopuses = HashMap<Coords, u32>;

#[derive(Debug)]
struct Grid {
    map: Octopuses,
    len: isize,
    width: isize,
}

const MAX_ENERGY: u32 = 9;

impl Grid {
    fn new(input: Input) -> Self {
        let octos = input
            .lines()
            .iter()
            .enumerate()
            .fold(HashMap::new(), |octos, (y, line)| {
                line.chars().enumerate().fold(octos, |mut acc, (x, ch)| {
                    acc.insert((x, y), ch.to_digit(10).unwrap());
                    acc
                })
            });

        Grid {
            map: octos,
            len: input.entry_len() as isize,
            width: input.input_len() as isize,
        }
    }

    fn step(&mut self) -> u32 {
        self.increase();
        self.flashes()
    }

    fn is_all_flashing(&self) -> bool {
        self.map.iter().all(|(_, v)| *v == 0)
    }

    fn increase(&mut self) {
        self.map.iter_mut().for_each(|(_, v)| *v += 1);
    }

    fn flashes(&mut self) -> u32 {
        let mut flashes = 0;

        let mut to_flash: Vec<(usize, usize)> = self
            .map
            .iter()
            .filter_map(|(coords, v)| {
                if *v > MAX_ENERGY {
                    return Some(*coords);
                }
                None
            })
            .collect::<Vec<_>>();

        while let Some((fx, fy)) = to_flash.pop() {
            flashes += 1;
            for (nx, ny) in neighbors(self.width, self.len, fx, fy) {
                if let Some(n) = self.map.get_mut(&(nx, ny)) {
                    *n += 1;
                    if *n == MAX_ENERGY + 1 {
                        to_flash.push((nx, ny))
                    }
                }
            }
        }

        self.map.iter_mut().for_each(|(_, v)| {
            if *v > MAX_ENERGY {
                *v = 0
            }
        });

        flashes
    }
}

const DIRECTIONS: [(isize, isize); 8] = [
    (1, 0),
    (-1, 0),
    (0, 1),
    (0, -1),
    (1, 1),
    (1, -1),
    (-1, 1),
    (-1, -1),
];

fn neighbors(width: isize, len: isize, x: usize, y: usize) -> impl Iterator<Item = (usize, usize)> {
    DIRECTIONS.iter().filter_map(move |(dx, dy)| {
        let nx: isize = x as isize + dx;
        let ny: isize = y as isize + dy;
        if nx > len || nx < 0 || ny > width || ny < 0 {
            return None;
        }

        Some((nx as usize, ny as usize))
    })
}

#[allow(dead_code)]
fn part1(input: Input) -> u32 {
    let mut grid = Grid::new(input);

    (0..100).fold(0, |acc, _| acc + grid.step())
}

#[allow(dead_code)]
fn part2(input: Input) -> u32 {
    let mut grid = Grid::new(input);

    (0..)
        .skip_while(|_| {
            grid.step();
            !grid.is_all_flashing()
        })
        .next()
        .unwrap()
        + 1
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 11, 2021).unwrap();
        assert_eq!(super::part1(test_input), 1656);

        let input = Input::new("./inputs/input.txt".to_string(), 11, 2021).unwrap();
        assert_eq!(super::part1(input), 1747);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 11, 2021).unwrap();
        assert_eq!(super::part2(test_input), 195);

        let input = Input::new("./inputs/input.txt".to_string(), 11, 2021).unwrap();
        assert_eq!(super::part2(input), 505);
    }
}
