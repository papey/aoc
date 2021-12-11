use helper::Input;
use lazy_static::lazy_static;
use std::collections::HashMap;
use std::collections::HashSet;

#[allow(dead_code)]
fn part1(input: Input) -> u32 {
    let len = input.entry_len() as isize;
    let width = input.input_len() as isize;
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
        (0..len as usize).fold(res, |acc, x| {
            let height = heightmap[y][x];
            if neighbors(len, width, x, y).any(|(nx, ny)| heightmap[ny][nx] <= height) {
                return acc;
            }
            acc + height + 1
        })
    })
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let len = input.entry_len() as isize;
    let width = input.input_len() as isize;
    let heightmap: Vec<Vec<u32>> = input
        .transform(|line| {
            line.chars()
                .map(|num| num.to_digit(10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect();

    // for each line in the map
    let mut basins: Vec<usize> = heightmap.iter().enumerate().fold(vec![], |res, (y, _)| {
        // for each pos in the current line
        (0..len as usize).fold(res, |mut acc, x| {
            // push the size of the current basin
            acc.push(basin(len, width, &heightmap, x, y));
            acc
        })
    });

    // reverse sort
    basins.sort_by(|a, b| b.cmp(a));

    // take the 3 first element and sum
    basins.iter().take(3).product()
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

fn neighbors(len: isize, width: isize, x: usize, y: usize) -> impl Iterator<Item = (usize, usize)> {
    DIRS.iter().filter_map(move |(_, (dx, dy))| {
        let nx = x as isize + dx;
        let ny = y as isize + dy;

        if nx < 0 || nx >= len || ny < 0 || ny >= width {
            return None;
        }

        Some((nx as usize, ny as usize))
    })
}

const MAX_HEIGHT: u32 = 9;

// basin uses bfs to find all coords forming a basin
// return len of the basin
fn basin(len: isize, width: isize, heightmap: &Vec<Vec<u32>>, x: usize, y: usize) -> usize {
    let mut seen: HashSet<(usize, usize)> = HashSet::new();
    let mut queue: Vec<(usize, usize)> = vec![(x, y)];

    seen.insert((x, y));

    while let Some((cx, cy)) = queue.pop() {
        let height = heightmap[cy][cx];

        for (nx, ny) in neighbors(len, width, cx, cy) {
            let neighbor_height = heightmap[ny][nx];

            if !seen.contains(&(nx, ny))
                && neighbor_height < MAX_HEIGHT
                && heightmap[ny][nx] > height
            {
                queue.push((nx, ny));
                seen.insert((nx, ny));
            }
        }
    }

    seen.len()
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part1(test_input), 15);

        let input = Input::new("inputs/input.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part1(input), 545)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part2(test_input), 1134);

        let input = Input::new("inputs/input.txt".to_string(), 9, 2021).unwrap();
        assert_eq!(super::part2(input), 950600);
    }
}
