use helper::Input;

enum Cmd {
    Forward,
    Down,
    Up,
}

struct Pos {
    horizontal: usize,
    depth: usize,
    aim: usize,
}

fn parse_line(line: &String) -> (Option<Cmd>, usize) {
    let mut parts = line.split(" ");
    let cmd = match parts.next() {
        Some("forward") => Some(Cmd::Forward),
        Some("down") => Some(Cmd::Down),
        Some("up") => Some(Cmd::Up),
        _ => None,
    };

    (
        cmd,
        parts
            .next()
            .and_then(|delta| delta.parse::<usize>().ok())
            .unwrap_or_default(),
    )
}

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let result = input.lines().iter().fold(
        Pos {
            horizontal: 0,
            depth: 0,
            aim: 0,
        },
        |mut pos, line| {
            let (cmd, delta) = parse_line(line);
            match cmd {
                Some(Cmd::Forward) => pos.horizontal += delta,
                Some(Cmd::Down) => pos.depth += delta,
                Some(Cmd::Up) => pos.depth -= delta,
                None => {}
            }
            pos
        },
    );

    result.depth * result.horizontal
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let result = input.lines().iter().fold(
        Pos {
            horizontal: 0,
            depth: 0,
            aim: 0,
        },
        |mut pos, line| {
            let (cmd, delta) = parse_line(line);
            match cmd {
                Some(Cmd::Forward) => {
                    pos.horizontal += delta;
                    pos.depth += pos.aim * delta
                }
                Some(Cmd::Down) => pos.aim += delta,
                Some(Cmd::Up) => pos.aim -= delta,
                None => {}
            }
            pos
        },
    );

    result.depth * result.horizontal
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 2, 2021).unwrap();
        assert_eq!(super::part1(test_input), 150);

        let test_input = Input::new("./inputs/input.txt".to_string(), 2, 2021).unwrap();
        assert_eq!(super::part1(test_input), 1580000);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 2, 2021).unwrap();
        assert_eq!(super::part2(test_input), 900);

        let test_input = Input::new("./inputs/input.txt".to_string(), 2, 2021).unwrap();
        assert_eq!(super::part2(test_input), 1251263225);
    }
}
