use helper::Input;
use std::cmp::Ordering;
use std::collections::BinaryHeap;

#[allow(dead_code)]
fn part1(input: Input) -> Option<u32> {
    let maze: Maze = input
        .transform(|line| {
            line.chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect();

    let y_dest = maze.len() - 1;
    let x_dest = maze[0].len() - 1;

    djikstra(&maze, (0, 0), (x_dest, y_dest))
}

#[allow(dead_code)]
fn part2(input: Input) -> Option<u32> {
    let maze_tile: Maze = input
        .transform(|line| {
            line.chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect();

    let maze = expand_maze(maze_tile);

    dbg!(&maze[1]);

    let y_dest = maze.len() - 1;
    let x_dest = maze[0].len() - 1;

    djikstra(&maze, (0, 0), (x_dest, y_dest))
}

fn djikstra(maze: &Maze, origin: Coord, dest: Coord) -> Option<u32> {
    let width = maze.len();
    let len = maze[0].len();

    let mut distances: Maze = vec![vec![u32::MAX; len]; width];
    let mut pq = BinaryHeap::new();

    distances[origin.1][origin.0] = 0;
    pq.push(State {
        cost: 0,
        position: origin,
    });

    while let Some(State { cost, position }) = pq.pop() {
        if position == dest {
            return Some(cost);
        }

        if cost > distances[position.1][position.0] {
            continue;
        }

        for nhbr in neighbors(position, width as isize, len as isize) {
            let candidate = State {
                cost: cost + maze[nhbr.1][nhbr.0],
                position: nhbr,
            };

            if candidate.cost < distances[nhbr.1][nhbr.0] {
                pq.push(candidate);
                distances[nhbr.1][nhbr.0] = candidate.cost;
            }
        }
    }

    None
}

const DIRECTIONS: [(isize, isize); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];

fn neighbors(position: Coord, width: isize, len: isize) -> impl Iterator<Item = (usize, usize)> {
    DIRECTIONS.iter().filter_map(move |(dx, dy)| {
        let nx: isize = position.0 as isize + dx;
        let ny: isize = position.1 as isize + dy;
        if nx >= len || nx < 0 || ny >= width || ny < 0 {
            return None;
        }

        Some((nx as usize, ny as usize))
    })
}

type Maze = Vec<Vec<u32>>;
type Coord = (usize, usize);

#[derive(Copy, Clone, Eq, PartialEq, Debug)]
struct State {
    cost: u32,
    position: Coord,
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn expand_maze(maze_tile: Maze) -> Maze {
    const MULTIPLIER: usize = 5;

    let tile_width = maze_tile.len();
    let tile_len = maze_tile[0].len();
    let maze_width = tile_width * MULTIPLIER;
    let maze_len = tile_len * MULTIPLIER;

    (0..maze_width).fold(vec![vec![0; maze_len]; maze_width], |maze, y| {
        (0..maze_len).fold(maze, |mut m, x| {
            m[y][x] = wrap(
                maze_tile[y % tile_width][x % tile_len]
                    + (x / tile_len) as u32
                    + (y / tile_width) as u32,
            );
            m
        })
    })
}

fn wrap(value: u32) -> u32 {
    if value > 9 {
        value - 9
    } else {
        value
    }
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 15, 2021).unwrap();
        assert_eq!(super::part1(test_input), Some(40));

        let input = Input::new("inputs/input.txt".to_string(), 15, 2021).unwrap();
        assert_eq!(super::part1(input), Some(656));
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 15, 2021).unwrap();
        assert_eq!(super::part2(test_input), Some(315));

        let input = Input::new("inputs/input.txt".to_string(), 15, 2021).unwrap();
        assert_eq!(super::part2(input), Some(2979));
    }
}
