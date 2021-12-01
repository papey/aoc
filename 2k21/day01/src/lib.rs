use helper::Input;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .transform(|line: String| line.parse::<usize>().unwrap())
        .windows(2)
        .filter(|w| w[0] < w[1])
        .count()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    input
        .transform(|line: String| line.parse::<usize>().unwrap())
        .windows(4)
        .filter(|w| w[0] < w[3])
        .count()
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 1, 2021).unwrap();
        assert_eq!(super::part1(test_input), 7);

        let test_input = Input::new("./inputs/input.txt".to_string(), 1, 2021).unwrap();
        assert_eq!(super::part1(test_input), 1342);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 1, 2021).unwrap();
        assert_eq!(super::part2(test_input), 5);

        let test_input = Input::new("./inputs/input.txt".to_string(), 1, 2021).unwrap();
        assert_eq!(super::part2(test_input), 1378);
    }
}
