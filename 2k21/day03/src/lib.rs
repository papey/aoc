use helper::Input;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let mut gama = 0;
    let mut epsilon = 0;
    let size = input.entry_len();

    let data = input
        .transform(|line| isize::from_str_radix(line.as_str(), 2).unwrap())
        .collect::<Vec<_>>();

    for i in (0..size).rev() {
        let freqs = frequencies(&data, i);
        let res = freqs[0] > freqs[1];
        gama |= (res as usize) << i;
        epsilon |= (!res as usize) << i;
    }

    gama * epsilon
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let size = input.entry_len();

    let mut oxygen_data = input
        .transform(|line| isize::from_str_radix(line.as_str(), 2).unwrap())
        .collect::<Vec<_>>();
    let mut scrubber_data = oxygen_data.clone();

    for i in (0..size).rev() {
        filter_candidates(&mut oxygen_data, i, |a, b| a <= b);
        filter_candidates(&mut scrubber_data, i, |a, b| a > b);
        if oxygen_data.len() == 1 && scrubber_data.len() == 1 {
            break;
        }
    }

    oxygen_data[0] as usize * scrubber_data[0] as usize
}

fn filter_candidates(
    candidates: &mut Vec<isize>,
    index: usize,
    compare: fn(a: usize, b: usize) -> bool,
) {
    if candidates.len() <= 1 {
        return;
    }

    let freqs = frequencies(&candidates, index);
    let common = compare(freqs[0], freqs[1]);

    candidates.retain(|elem| elem >> index & 0x1 == (common as isize));
}

type Freq = [usize; 2];

fn frequencies(data: &Vec<isize>, index: usize) -> Freq {
    let mut counters: Freq = [0, 0];
    for n in data {
        counters[(*n >> index & 0x1) as usize] += 1;
    }

    counters
}

#[cfg(test)]
mod tests {
    use helper::Input;
    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part1(test_input), 198);

        let input = Input::new("inputs/input.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part1(input), 1025636);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part2(test_input), 230);

        let input = Input::new("inputs/input.txt".to_string(), 3, 2021).unwrap();
        assert_eq!(super::part2(input), 793873);
    }
}
