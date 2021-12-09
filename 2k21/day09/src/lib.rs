use helper::Input;
use lazy_static::lazy_static;
use std::collections::HashMap;

#[allow(dead_code)]
fn part1(input: Input) -> u32 {
    let len = input.entry_len();
    let width = input.input_len();
    let heightmap: Vec<Vec<u32>> = input
        .transform(|line| {
            line.chars()
                .map(|num| num.to_digit(10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect();

    // for each line in the map
    heightmap.iter().enumerate().fold(0, |res, (y, _)| {
        // for each pos in the current line
        (0..len).fold(res, |acc, x| {
            let height = heightmap[y][x];
            if neighbors(len, width, x, y).any(|(nx, ny)| heightmap[ny][nx] <= height) {
                return acc;
            }
            acc + height + 1
        })
    })
}

#[derive(Debug, PartialEq, Eq, Hash)]
enum Directions {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}

lazy_static! {
    static ref DIRS: HashMap<Directions, (isize, isize)> = HashMap::from([
        (Directions::UP, (0, -1)),
        (Directions::DOWN, (0, 1)),
        (Directions::LEFT, (-1, 0)),
        (Directions::RIGHT, (1, 0)),
    ]);
}

fn neighbors(len: usize, width: usize, x: usize, y: usize) -> impl Iterator<Item = (usize, usize)> {
    DIRS.iter().filter_map(move |(_, (dx, dy))| {
        let nx = x as isize + dx;
        let ny = y as isize + dy;

        if nx < 0 || nx > (len - 1) as isize || ny < 0 || ny > (width - 1) as isize {
            return None;
        }

        Some((nx as usize, ny as usize))
    })
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part1(test_input), 15);

        let input = Input::new("inputs/input.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part1(input), 549)
    }
}
