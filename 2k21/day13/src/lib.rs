use helper::Input;
use regex::Regex;
use std::collections::HashSet;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let (dots, instructions) = parse_input(input);

    instructions
        .iter()
        .take(1)
        .fold(dots, |current_dots, inst| {
            current_dots
                .iter()
                .fold(HashSet::new(), |next_dots, (x, y)| {
                    fold_paper(next_dots, (*x, *y), &inst)
                })
        })
        .len()
}

#[allow(dead_code)]
fn part2(input: Input) -> String {
    let (dots, instructions) = parse_input(input);

    let paper = instructions.iter().fold(dots, |current_dots, inst| {
        current_dots
            .iter()
            .fold(HashSet::new(), |next_dots, (x, y)| {
                fold_paper(next_dots, (*x, *y), &inst)
            })
    });

    let (max_x, _) = paper
        .iter()
        .max_by(|(x1, _), (x2, _)| x1.cmp(x2))
        .unwrap_or(&(0, 0));
    let (_, max_y) = paper
        .iter()
        .max_by(|(_, y1), (_, y2)| y1.cmp(y2))
        .unwrap_or(&(0, 0));

    let code = (0..*max_y + 1).fold(String::new(), |result, y| {
        let line = (0..*max_x + 1).fold(result, |acc, x| match paper.get(&(x, y)) {
            Some(_) => format!("{}🎅", acc),
            None => format!("{}🎄", acc),
        });
        format!("{}\n", line)
    });

    println!("{}", code);

    "".to_string()
}

fn parse_input(input: Input) -> (HashSet<Coord>, Vec<Instruction>) {
    let instruction_regex: Regex = Regex::new(r"fold along (\w)=(\d+)").unwrap();

    let mut dots: HashSet<Coord> = HashSet::new();
    let mut instructions: Vec<Instruction> = Vec::new();

    for l in input.lines() {
        match l {
            raw_dots if raw_dots.contains(",") => {
                if let Some((raw_x, raw_y)) = raw_dots.split_once(",") {
                    let x = raw_x.parse::<usize>().unwrap();
                    let y = raw_y.parse::<usize>().unwrap();
                    dots.insert((x, y));
                }
            }
            raw_instruction if raw_instruction.contains("fold along") => {
                match instruction_regex.captures(&raw_instruction) {
                    Some(data) => {
                        instructions.push(Instruction::new(
                            &data[1],
                            data[2].parse::<usize>().unwrap(),
                        ));
                    }
                    _ => {}
                }
            }
            _ => {}
        }
    }

    (dots, instructions)
}

fn fold_paper(mut dots: HashSet<Coord>, (x, y): Coord, inst: &Instruction) -> HashSet<Coord> {
    match inst.axis {
        Axis::X => {
            if x < inst.at {
                dots.insert((x, y));
            } else {
                dots.insert((x - 2 * (x - inst.at), y));
            }
        }
        Axis::Y => {
            if y < inst.at {
                dots.insert((x, y));
            } else {
                dots.insert((x, y - 2 * (y - inst.at)));
            }
        }
    };
    dots
}

type Coord = (usize, usize);

#[derive(Debug)]
enum Axis {
    X,
    Y,
}

#[derive(Debug)]
struct Instruction {
    axis: Axis,
    at: usize,
}

impl Instruction {
    fn new(raw_axis: &str, at: usize) -> Self {
        let axis = match raw_axis {
            "x" => Axis::X,
            "y" => Axis::Y,
            _ => unreachable!(),
        };

        Instruction { axis: axis, at: at }
    }
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 13, 2021).unwrap();
        assert_eq!(super::part1(test_input), 17);

        let input = Input::new("inputs/input.txt".to_string(), 13, 2021).unwrap();
        assert_eq!(super::part1(input), 655);
    }

    #[test]
    fn test_p2() {
        let input = Input::new("inputs/input.txt".to_string(), 13, 2021).unwrap();
        assert_eq!(super::part2(input), "");
    }
}
