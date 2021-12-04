use helper::Input;
use regex::Regex;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let (numbers, mut boards) = parse_input(input);

    numbers
        .iter()
        .find_map(|n| {
            boards.iter_mut().find_map(|b| {
                b.mark(*n);
                if b.is_winning() {
                    return Some(b.bingo(*n));
                }
                None
            })
        })
        .unwrap()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let (numbers, boards) = parse_input(input);
    let mut tracker: Vec<(Board, bool)> = boards.into_iter().map(|b| (b, false)).collect();

    *numbers
        .iter()
        .flat_map(|n| {
            tracker
                .iter_mut()
                .filter(|(_, state)| *state == false)
                .filter_map(|(b, state)| {
                    b.mark(*n);
                    if b.is_winning() {
                        *state = true;
                        return Some(b.bingo(*n).clone());
                    }

                    None
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>()
        .last()
        .unwrap()
}

const BOARD_LEN: usize = 5;

type Numbers = Vec<usize>;
type Grid = Vec<Vec<(usize, bool)>>;

#[derive(Debug)]
struct Board {
    grid: Grid,
    length: usize,
    width: usize,
}

impl Board {
    pub fn new(board_lines: &[&String]) -> Board {
        let split_board_regex: regex::Regex = Regex::new(r"\s+").unwrap();

        Board {
            grid: board_lines
                .iter()
                .map(|line| {
                    split_board_regex
                        .split(line.trim())
                        .map(|n| (n.parse::<usize>().unwrap(), false))
                        .collect::<Vec<(usize, bool)>>()
                })
                .collect(),
            length: BOARD_LEN,
            width: BOARD_LEN,
        }
    }

    pub fn mark(&mut self, num: usize) {
        for i in 0..self.width {
            for j in 0..self.length {
                if self.grid[i][j].0 == num {
                    self.grid[i][j].1 = true
                }
            }
        }
    }

    pub fn is_winning(&self) -> bool {
        self.has_winning_line() || self.has_winning_row()
    }

    pub fn bingo(&self, multiplier: usize) -> usize {
        multiplier * self.checksum()
    }

    fn checksum(&self) -> usize {
        // quick and dirty !
        self.grid.iter().fold(0, |acc, row| {
            acc + row
                .iter()
                .filter(|(_, state)| *state == false)
                .fold(0, |acc, (v, _)| acc + v)
        })
    }

    fn has_winning_line(&self) -> bool {
        self.grid
            .iter()
            .any(|line| line.iter().all(|(_, state)| *state))
    }

    fn has_winning_row(&self) -> bool {
        self.transpose()
            .iter()
            .any(|line| line.iter().all(|(_, state)| *state))
    }

    fn transpose(&self) -> Grid {
        (0..self.length)
            .map(|i| {
                (0..self.width)
                    .map(move |j| self.grid[j][i])
                    .collect::<Vec<_>>()
            })
            .collect()
    }
}

type Boards = Vec<Board>;

fn parse_input(input: Input) -> (Numbers, Boards) {
    // get the lines
    let mut lines = input.lines();
    // get the numbers
    let numbers: Vec<usize> = lines
        .remove(0)
        .split(",")
        .map(|num| num.parse::<usize>().unwrap())
        .collect();

    // get all the boards
    let boards = lines
        .iter()
        .filter(|l| !l.is_empty())
        .collect::<Vec<_>>()
        .chunks(BOARD_LEN)
        .map(|lines| Board::new(lines))
        .collect();

    (numbers, boards)
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 4, 2021).unwrap();
        assert_eq!(super::part1(test_input), 4512);

        let input = Input::new("./inputs/input.txt".to_string(), 4, 2021).unwrap();
        assert_eq!(super::part1(input), 16674);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 4, 2021).unwrap();
        assert_eq!(super::part2(test_input), 1924);

        let input = Input::new("./inputs/input.txt".to_string(), 4, 2021).unwrap();
        assert_eq!(super::part2(input), 7075);
    }
}
