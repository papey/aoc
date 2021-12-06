use helper::Input;
use std::collections::HashMap;

#[allow(dead_code)]
fn part1(input: Input) -> isize {
    solve(&input, 80)
}

#[allow(dead_code)]
fn part2(input: Input) -> isize {
    solve(&input, 256)
}

fn solve(input: &Input, days: usize) -> isize {
    (0..days)
        .fold(init_fishes_pool(input), |f, _| {
            (0..=8).fold(HashMap::new(), |mut acc, age| {
                if age == 0 {
                    *acc.entry(8).or_insert(0) += f.get(&age).unwrap_or(&0);
                    *acc.entry(6).or_insert(0) += f.get(&age).unwrap_or(&0);
                } else {
                    *acc.entry(age - 1).or_insert(0) += *f.get(&age).unwrap_or(&0);
                }
                acc
            })
        })
        .values()
        .cloned()
        .sum()
}

fn init_fishes_pool(input: &Input) -> HashMap<isize, isize> {
    input
        .transform(move |line| {
            line.clone()
                .split(",")
                .filter_map(|num| num.parse::<isize>().ok())
                .collect::<Vec<_>>()
        })
        .nth(0)
        .unwrap()
        .iter()
        .fold(HashMap::new(), |mut f, age| {
            *f.entry(*age).or_insert(0) += 1;
            f
        })
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 6, 2021).unwrap();
        assert_eq!(super::part1(test_input), 5934);

        let input = Input::new("inputs/input.txt".to_string(), 6, 2021).unwrap();
        assert_eq!(super::part1(input), 352872);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 6, 2021).unwrap();
        assert_eq!(super::part2(test_input), 26984457539);

        let input = Input::new("inputs/input.txt".to_string(), 6, 2021).unwrap();
        assert_eq!(super::part2(input), 1604361182149);
    }
}
