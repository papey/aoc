use helper::Input;
use std::collections::HashMap;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    solve(input, 10)
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    solve(input, 40)
}

fn solve(input: Input, rounds: usize) -> usize {
    let (polymer, rules) = parse_input(&input);

    // do not forget it
    let last = polymer.chars().last().unwrap_or_default();

    // compute the intial state
    let init: State =
        polymer
            .chars()
            .collect::<Vec<_>>()
            .windows(2)
            .fold(HashMap::new(), |mut acc, chars| {
                *acc.entry((chars[0], chars[1])).or_insert(0) += 1;
                acc
            });

    // count on all rounds
    let counter = (0..rounds).fold(init, |ct, _| {
        let previous = ct.clone();
        rules.iter().fold(ct, |mut acc, ((a, b), out)| {
            *acc.entry((*a, *b)).or_insert(0) -= previous.get(&(*a, *b)).unwrap_or(&0);
            *acc.entry((*a, *out)).or_insert(0) += previous.get(&(*a, *b)).unwrap_or(&0);
            *acc.entry((*out, *b)).or_insert(0) += previous.get(&(*a, *b)).unwrap_or(&0);
            acc
        })
    });

    // prepare the sum : take the first elem of each key from the counting hashmap
    let mut sums: HashMap<char, usize> =
        counter.iter().fold(HashMap::new(), |mut acc, ((a, _), v)| {
            *acc.entry(*a).or_insert(0) += v;
            acc
        });

    // do not forget the last trailing char
    *sums.entry(last).or_insert(0) += 1;

    let max = sums.iter().max_by(|(_, v1), (_, v2)| v1.cmp(v2)).unwrap();
    let min = sums.iter().min_by(|(_, v1), (_, v2)| v1.cmp(v2)).unwrap();

    max.1 - min.1
}

const RULE_DELIMITER: &str = " -> ";

type State = HashMap<(char, char), usize>;
type Rules = HashMap<(char, char), char>;

fn parse_input(input: &Input) -> (String, Rules) {
    let mut iter = input.lines().into_iter();

    // get the first line it's the polymer
    let polymer = iter.next().unwrap();

    // drop the empty line
    iter.next();

    let rules = iter.fold(HashMap::new(), |mut rules, raw_rule| {
        if let Some((input, output)) = raw_rule.split_once(RULE_DELIMITER) {
            let chars = input.chars().collect::<Vec<_>>();
            rules.insert((chars[0], chars[1]), output.chars().nth(0).unwrap());
        }
        rules
    });

    (polymer, rules)
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 14, 2021).unwrap();
        assert_eq!(super::part1(test_input), 1588);

        let input = Input::new("./inputs/input.txt".to_string(), 14, 2021).unwrap();
        assert_eq!(super::part1(input), 2010);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 14, 2021).unwrap();
        assert_eq!(super::part2(test_input), 2188189693529);

        let input = Input::new("./inputs/input.txt".to_string(), 14, 2021).unwrap();
        assert_eq!(super::part2(input), 2437698971143);
    }
}
