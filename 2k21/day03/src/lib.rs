use helper::Input;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let mut gama = 0;
    let mut epsilon = 0;
    let size = input.entry_len();

    let data = input.transform(|line| isize::from_str_radix(line.as_str(), 2).unwrap());

    for i in (0..size).rev() {
        let mut counters = [0, 0];
        for n in &data {
            counters[(n >> i & 0x1) as usize] += 1;
        }
        let current = counters[0] > counters[1];
        gama |= (current as usize) << i;
        epsilon |= (!current as usize) << i;
    }

    gama * epsilon
}

#[cfg(test)]
mod tests {
    use helper::Input;
    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part1(test_input), 198);

        let input = Input::new("inputs/input.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part1(input), 198);
    }
}
