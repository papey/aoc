use helper::Input;
use lazy_static::lazy_static;
use std::collections::{HashMap, HashSet};

const SEPARATOR: &str = "|";
const DIGIT_OUPUT_LEN: usize = 4;

lazy_static! {
    // 2 segments -> 1, 4 segments -> 4, 3 segments -> 7, 7 segments -> 8
    static ref UNIQUE_SEGMENTS_TO_DIGITS: HashMap<usize, usize> =
        HashMap::from([(2, 1), (4, 4), (3, 7), (7, 8)]);
}

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    input
        .transform(|line| {
            line.split(SEPARATOR)
                .nth(1)
                .unwrap()
                .split_whitespace()
                .map(|e| String::from(e))
                .collect::<Vec<_>>()
        })
        .flatten()
        .filter(|digit| {
            UNIQUE_SEGMENTS_TO_DIGITS
                .keys()
                .any(|segments| digit.len() == *segments)
        })
        .count()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    input
        .transform(|line| {
            let (raw_inputs, raw_outputs) = line.split_once(SEPARATOR).unwrap();
            let inputs = raw_inputs
                .split_whitespace()
                .map(|e| String::from(e))
                .collect();
            let mapping = find_segments_mapping(inputs);

            raw_outputs
                .split_whitespace()
                .map(|e| String::from(e))
                .enumerate()
                .fold(0, |acc, (index, letters)| {
                    let shift: usize = (10 as usize).pow((DIGIT_OUPUT_LEN - index - 1) as u32);
                    acc + mapping
                        .get(&SortableString::from(letters).sort())
                        .unwrap_or(&0)
                        * shift
                })
        })
        .sum()
}

fn find_segments_mapping(inputs: Vec<String>) -> HashMap<String, usize> {
    // sets containing segments for obvious digits
    let overlaps = init_overlaps_sets(&inputs);

    // iterates over inputs
    // search for obvious one
    // if found, continue iteration
    // if not, find digit from overlaping rules between current and obvious ones
    // accumulate into a HashMap where key is digit and value is string code
    // reverse previous HashMap : key is code string (sorted), value is digit
    inputs
        .iter()
        .fold(HashMap::new(), |mut mapping, code| {
            let candidate = UNIQUE_SEGMENTS_TO_DIGITS
                .iter()
                .find_map(|(segments, value)| {
                    if *segments != code.len() {
                        return None;
                    }

                    Some(value)
                });

            // simple case, there is no overlap
            if let Some(digit) = candidate {
                mapping.insert(*digit, String::from(code));
                return mapping;
            }

            // get letters for this input
            let letters = code.chars().fold(HashSet::new(), |mut acc, letter| {
                acc.insert(letter);
                acc
            });

            // find value using intersections from known digits
            let value = match code.len() {
                5 => {
                    if letters.intersection(&overlaps[1]).count() == 2 {
                        3
                    } else if letters.intersection(&overlaps[4]).count() == 2 {
                        2
                    } else {
                        5
                    }
                }
                6 => {
                    if letters.intersection(&overlaps[1]).count() == 1 {
                        6
                    } else if letters.intersection(&overlaps[4]).count() == 4 {
                        9
                    } else {
                        0
                    }
                }
                _ => unreachable!(),
            };

            mapping.insert(value, String::from(code));
            mapping
        })
        .into_iter()
        .fold(HashMap::new(), |mut acc, (key, value)| {
            acc.insert(SortableString::from(value).sort(), key);
            acc
        })
}

// init a vector of sets used to indentify overlaps between digits
// this is done by reducing over digits than have a unique number of segments
// vec index in used a key for the digit value
fn init_overlaps_sets(inputs: &Vec<String>) -> Vec<HashSet<char>> {
    UNIQUE_SEGMENTS_TO_DIGITS.iter().fold(
        vec![HashSet::new(); 9],
        |segments_sets, (segment_len, digit_value)| {
            inputs
                .iter()
                .find_map(|input| {
                    if input.len() != *segment_len {
                        return None;
                    }

                    Some(input)
                })
                .unwrap()
                .chars()
                .fold(segments_sets, |mut acc, letter| {
                    acc[*digit_value].insert(letter);
                    acc
                })
        },
    )
}

struct SortableString {
    data: String,
}

impl SortableString {
    pub fn from(data: String) -> Self {
        SortableString { data: data }
    }

    fn sort(&self) -> String {
        let mut result = self.data.chars().collect::<Vec<_>>();
        result.sort_unstable();
        result.into_iter().collect()
    }
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 8, 2021).unwrap();
        assert_eq!(super::part1(test_input), 26);

        let input = Input::new("./inputs/input.txt".to_string(), 8, 2021).unwrap();
        assert_eq!(super::part1(input), 318);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("./inputs/test.txt".to_string(), 8, 2021).unwrap();
        assert_eq!(super::part2(test_input), 61229);

        let input = Input::new("./inputs/input.txt".to_string(), 8, 2021).unwrap();
        assert_eq!(super::part2(input), 996280);
    }
}
