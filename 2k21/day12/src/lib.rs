use helper::Input;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(Debug, PartialEq)]
enum Kind {
    START,
    END,
    BIG,
    SMOL,
}

#[derive(Debug)]
struct Cave {
    kind: Kind,
    adj: Vec<String>,
}

type Map = HashMap<String, Cave>;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let map = init_map(&input);
    traverse(&map, &map.get("start").unwrap(), &mut Vec::new(), false)
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let map = init_map(&input);
    traverse(&map, &map.get("start").unwrap(), &mut Vec::new(), true)
}

fn init_map(input: &Input) -> Map {
    input
        .lines()
        .iter()
        .fold(HashMap::from(HashMap::new()), |mut map, line| {
            let (from, to) = line.split_once("-").unwrap();

            map.entry(from.to_string())
                .or_insert_with(|| Cave {
                    kind: match_kind(from),
                    adj: Vec::new(),
                })
                .adj
                .push(to.to_string());

            map.entry(to.to_string())
                .or_insert_with(|| Cave {
                    kind: match_kind(to),
                    adj: Vec::new(),
                })
                .adj
                .push(from.to_string());
            map
        })
}

fn match_kind(kind: &str) -> Kind {
    match kind {
        "start" => Kind::START,
        "end" => Kind::END,
        ch if ch == ch.to_uppercase() => Kind::BIG,
        _ => Kind::SMOL,
    }
}

fn is_visit_allowed(visited: &Vec<String>) -> bool {
    let mut seen: HashSet<String> = HashSet::new();

    for cave in visited {
        if cave.to_lowercase() == *cave {
            if seen.contains(cave) {
                return false;
            }
            seen.insert(cave.clone());
        }
    }

    true
}

fn traverse(map: &Map, visiting: &Cave, visited: &mut Vec<String>, can_extra_visit: bool) -> usize {
    if visiting.kind == Kind::END {
        return 1;
    }

    visiting.adj.iter().fold(0, |mut acc, n| {
        if let Some(neighbor) = map.get(n) {
            if neighbor.kind == Kind::END
                || neighbor.kind == Kind::BIG
                || (neighbor.kind == Kind::SMOL && can_extra_visit && is_visit_allowed(visited))
                || (neighbor.kind == Kind::SMOL && !visited.contains(n))
            {
                let mut tracking = visited.clone();
                tracking.push(n.clone());
                acc += traverse(map, &neighbor, &mut tracking, can_extra_visit);
            }
        }

        acc
    })
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 12, 2021).unwrap();
        assert_eq!(super::part1(test_input), 10);

        let input = Input::new("inputs/input.txt".to_string(), 12, 2021).unwrap();
        assert_eq!(super::part1(input), 3495);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 12, 2021).unwrap();
        assert_eq!(super::part2(test_input), 36);

        let input = Input::new("inputs/input.txt".to_string(), 12, 2021).unwrap();
        assert_eq!(super::part2(input), 94849);
    }
}
