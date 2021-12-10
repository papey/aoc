use helper::Input;
use std::collections::HashMap;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .lines()
        .into_iter()
        .filter_map(|line| {
            let mut stack: Vec<char> = vec![];
            line.chars().find_map(|ch| handle(&mut stack, ch))
        })
        .sum()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let scoring: HashMap<char, usize> = HashMap::from([('(', 1), ('[', 2), ('{', 3), ('<', 4)]);
    const MULTIPLIER: usize = 5;

    let mut results: Vec<usize> = input
        .lines()
        .into_iter()
        .filter_map(|line| {
            let mut stack: Vec<char> = vec![];

            if let Some(_) = line.chars().find_map(|ch| handle(&mut stack, ch)) {
                return None;
            }

            let result = stack.iter().rev().fold(0, |acc, value| {
                acc * MULTIPLIER + scoring.get(value).unwrap_or(&0)
            });

            Some(result)
        })
        .collect();

    results.sort_unstable();

    results[results.len() / 2]
}

fn handle(stack: &mut Vec<char>, c: char) -> Option<usize> {
    if c == '(' || c == '{' || c == '[' || c == '<' {
        stack.push(c);
        return None;
    }

    match (stack.pop(), c) {
        (Some('('), ')') => {}
        (Some('['), ']') => {}
        (Some('{'), '}') => {}
        (Some('<'), '>') => {}
        (_, ')') => return Some(3),
        (_, ']') => return Some(57),
        (_, '}') => return Some(1197),
        (_, '>') => return Some(25137),
        _ => {}
    }

    None
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 10, 2021).unwrap();
        assert_eq!(super::part1(test_input), 26397);

        let input = Input::new("./inputs/input.txt".to_string(), 10, 2021).unwrap();
        assert_eq!(super::part1(input), 166191);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 10, 2021).unwrap();
        assert_eq!(super::part2(test_input), 288957);

        let input = Input::new("./inputs/input.txt".to_string(), 10, 2021).unwrap();
        assert_eq!(super::part2(input), 1152088313);
    }
}
