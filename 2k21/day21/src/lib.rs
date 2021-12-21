use helper::Input;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;

const TARGET_SCORE: usize = 1000;
const ROLLS_PER_TURN: usize = 3;

lazy_static! {
    static ref REGEX: Regex = Regex::new(r"Player \d starting position: (\d+)").unwrap();
}

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let mut pos = input
        .transform(|line| {
            let captures = REGEX.captures(&line).unwrap();
            captures[1].parse::<usize>().unwrap()
        })
        .collect::<Vec<_>>();

    let mut dice = (1..=100).cycle();
    let mut player = 0;
    let mut scores = [0, 0];
    let mut rolls = 0;

    loop {
        pos[player] = to_case(
            pos[player],
            (0..ROLLS_PER_TURN).filter_map(|_| dice.next()).sum(),
        );
        scores[player] += pos[player];
        rolls += ROLLS_PER_TURN;

        if scores[player] >= TARGET_SCORE {
            player = (player + 1) % 2;
            break;
        }

        player = (player + 1) % 2;
    }

    rolls * scores[player]
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let pos = input
        .transform(|line| {
            let captures = REGEX.captures(&line).unwrap();
            captures[1].parse::<usize>().unwrap()
        })
        .collect::<Vec<_>>();

    let res = quantum(&mut HashMap::new(), (pos[0], 0), (pos[1], 0), 21);

    res.0.max(res.1)
}

fn to_case(pos: usize, steps: usize) -> usize {
    (pos - 1 + steps) % 10 + 1
}

type Player = (usize, usize);
type Scoring = (usize, usize);

static STEPS_TO_FREQ: &'static [(usize, usize)] =
    &[(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)];

fn quantum(
    cache: &mut HashMap<(Player, Player), Scoring>,
    (playing_pos, palying_score): Player,
    (other_pos, other_score): Player,
    win: usize,
) -> Scoring {
    let key = ((playing_pos, palying_score), (other_pos, other_score));

    if cache.contains_key(&key) {
        return *cache.get(&key).unwrap();
    }

    if other_score >= win {
        return (0, 1);
    }

    let mut playing_wins = 0;
    let mut other_wins = 0;

    for (steps, freq) in STEPS_TO_FREQ {
        let next_pos = to_case(playing_pos, *steps);
        let next_player = (next_pos, palying_score + next_pos);

        let (quantum_other_wins, quantum_playing_wins) =
            quantum(cache, (other_pos, other_score), next_player, win);

        playing_wins += quantum_playing_wins * freq;
        other_wins += quantum_other_wins * freq;
    }

    cache.insert(key, (playing_wins, other_wins));

    (playing_wins, other_wins)
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 21, 2021).unwrap();
        assert_eq!(super::part1(test_input), 739785);

        let input = Input::new("inputs/input.txt".to_string(), 21, 2021).unwrap();
        assert_eq!(super::part1(input), 752745)
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 21, 2021).unwrap();
        assert_eq!(super::part2(test_input), 444356092776315);

        let input = Input::new("inputs/input.txt".to_string(), 21, 2021).unwrap();
        assert_eq!(super::part2(input), 309196008717909);
    }
}
