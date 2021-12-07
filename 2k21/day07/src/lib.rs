use helper::Input;
use std::collections::HashMap;

type Escadron = HashMap<isize, isize>;

#[allow(dead_code)]
fn part1(input: Input) -> isize {
    let submarines = init_submarines_pool(&input);

    let (min, max) = find_levels(&submarines);
    (min..=max)
        .map(|target| {
            submarines.iter().fold(0, |fuel, (level, quantity)| {
                fuel + (level - target).abs() * quantity
            })
        })
        .min()
        .unwrap()
}

#[allow(dead_code)]
fn part2(input: Input) -> isize {
    let submarines = init_submarines_pool(&input);

    let (min, max) = find_levels(&submarines);
    (min..=max)
        .map(|target| {
            submarines.iter().fold(0, |fuel, (level, quantity)| {
                let delta = (level - target).abs();
                fuel + (delta * (delta + 1) / 2) * quantity
            })
        })
        .min()
        .unwrap()
}

#[allow(dead_code)]
fn init_submarines_pool(input: &Input) -> Escadron {
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
        .fold(HashMap::new(), |mut f, v| {
            *f.entry(*v).or_insert(0) += 1;
            f
        })
}

fn find_levels(submarines: &Escadron) -> (isize, isize) {
    submarines.keys().fold((0, 0), |(mut min, mut max), v| {
        if *v < min {
            min = *v
        }
        if *v > max {
            max = *v
        }
        (min, max)
    })
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 7, 2021).unwrap();
        assert_eq!(super::part1(test_input), 37);

        let input = Input::new("./inputs/input.txt".to_string(), 7, 2021).unwrap();
        assert_eq!(super::part1(input), 359648)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 7, 2021).unwrap();
        assert_eq!(super::part2(test_input), 168);

        let test_input = Input::new("./inputs/input.txt".to_string(), 7, 2021).unwrap();
        assert_eq!(super::part2(test_input), 100727924)
    }
}
