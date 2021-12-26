use helper::Input;
use itertools::Itertools;

#[derive(Debug, Copy, Clone)]
enum Cucumber {
    South,
    East,
}

type Size = (usize, usize);

type Sea = Vec<Vec<Option<Cucumber>>>;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let (mut sea, size) = parse(&input);

    let res = std::iter::from_fn(|| {
        let east_changed = step(&mut sea, size, Cucumber::East);
        let south_changed = step(&mut sea, size, Cucumber::South);
        Some((east_changed, south_changed))
    })
    .enumerate()
    .skip_while(|(_, (ec, sc))| *ec || *sc)
    .take(1)
    .nth(0)
    .unwrap();

    res.0 + 1
}

fn parse(input: &Input) -> (Sea, Size) {
    let sea = input
        .transform(|line| {
            line.chars()
                .map(|ch| match ch {
                    '>' => Some(Cucumber::East),
                    'v' => Some(Cucumber::South),
                    '.' => None,
                    _ => unreachable!(),
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    let len = sea[0].len();
    let width = sea.len();

    (sea, (width, len))
}

fn step(map: &mut Sea, (w, l): Size, dir: Cucumber) -> bool {
    let mut changed = false;

    *map = (0..w)
        .cartesian_product(0..l)
        .fold(vec![vec![None; l]; w], |mut next, (y, x)| {
            match (map[y][x], dir) {
                (Some(Cucumber::East), Cucumber::East) if map[y][(x + 1) % l].is_none() => {
                    next[y][(x + 1) % l] = Some(Cucumber::East);
                    changed = true;
                }
                (Some(Cucumber::South), Cucumber::South) if map[(y + 1) % w][x].is_none() => {
                    next[(y + 1) % w][x] = Some(Cucumber::South);
                    changed = true;
                }
                (Some(old), _) => next[y][x] = Some(old),
                _ => {}
            };
            next
        });

    changed
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/input.txt".to_string(), 25, 2021).unwrap();
        assert_eq!(super::part1(test_input), 400);
    }
}
