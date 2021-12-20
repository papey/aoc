use helper::Input;
use std::collections::HashSet;

#[allow(dead_code)]
fn part1(input: Input) -> usize {
    let (algorithm, img) = transform(&input);

    (0..2)
        .fold((&algorithm, img), |(algo, img), i| {
            (algo, img.expanse(algo, i))
        })
        .1
        .lpixels()
}

#[allow(dead_code)]
fn part2(input: Input) -> usize {
    let (algorithm, img) = transform(&input);

    (0..50)
        .fold((&algorithm, img), |(algo, img), i| {
            (algo, img.expanse(algo, i))
        })
        .1
        .lpixels()
}

const DELTAS: [(isize, isize); 9] = [
    (-1, -1),
    (0, -1),
    (1, -1),
    (-1, 0),
    (0, 0),
    (1, 0),
    (-1, 1),
    (0, 1),
    (1, 1),
];

type Algo = Vec<bool>;

type Pixels = HashSet<(isize, isize)>;

#[derive(Debug, Clone)]
struct Image {
    data: Pixels,
    xsize: (isize, isize),
    ysize: (isize, isize),
}

impl Image {
    fn new(input: Vec<Vec<bool>>) -> Image {
        let data = input
            .iter()
            .enumerate()
            .fold(HashSet::new(), |img, (y, line)| {
                line.iter()
                    .enumerate()
                    .filter(|(_, v)| **v)
                    .fold(img, |mut acc, (x, _)| {
                        acc.insert((x as isize, y as isize));
                        acc
                    })
            });

        let (xsize, ysize) = borders(&data);

        Image {
            data: data,
            xsize: xsize,
            ysize: ysize,
        }
    }

    fn borders(&self) -> ((isize, isize), (isize, isize)) {
        (
            (self.xsize.0 - 1, self.xsize.1 + 1),
            (self.ysize.0 - 1, self.ysize.1 + 1),
        )
    }

    fn lpixels(&self) -> usize {
        self.data.len()
    }

    fn expanse(&self, algo: &Algo, iteration: usize) -> Image {
        let default = default_void(algo, iteration);
        let (xborders, yborders) = self.borders();

        let data = (yborders.0..=yborders.1).fold(HashSet::new(), |next, y| {
            (xborders.0..=xborders.1).fold(next, |mut acc, x| {
                if self.is_light((x, y), algo, default) {
                    acc.insert((x, y));
                }
                acc
            })
        });

        Image {
            data: data,
            xsize: xborders,
            ysize: yborders,
        }
    }

    fn is_outside_borders(&self, x: isize, y: isize) -> bool {
        x < self.xsize.0 || x > self.xsize.1 || y < self.ysize.0 || y > self.ysize.1
    }

    fn is_light(&self, (x, y): (isize, isize), algo: &Algo, default_void: bool) -> bool {
        let index = DELTAS
            .map(|(dx, dy)| (x + dx, y + dy))
            .iter()
            .fold(0, |acc, (xx, yy)| {
                if self.is_outside_borders(*xx, *yy) {
                    (acc << 1) | default_void as usize
                } else {
                    (acc << 1) | (self.data.contains(&(*xx, *yy)) as usize)
                }
            });

        algo[index]
    }
}

fn borders(pixels: &Pixels) -> ((isize, isize), (isize, isize)) {
    let (xmin, _) = pixels.iter().min_by(|(x1, _), (x2, _)| x1.cmp(x2)).unwrap();
    let (xmax, _) = pixels.iter().max_by(|(x1, _), (x2, _)| x1.cmp(x2)).unwrap();
    let (_, ymin) = pixels.iter().min_by(|(_, y1), (_, y2)| y1.cmp(y2)).unwrap();
    let (_, ymax) = pixels.iter().max_by(|(_, y1), (_, y2)| y1.cmp(y2)).unwrap();

    ((*xmin, *xmax), (*ymin, *ymax))
}

fn default_void(algo: &Algo, i: usize) -> bool {
    match (algo[0], i % 2) {
        (false, _) => false,
        (true, 0) => algo[algo.len() - 1],
        (true, 1) => true,
        _ => unreachable!(),
    }
}

fn transform(input: &Input) -> (Algo, Image) {
    let mut parsed = input
        .lines()
        .iter()
        .filter(|line| !line.is_empty())
        .map(|line| {
            line.chars()
                .map(|ch| match ch {
                    '.' => false,
                    '#' => true,
                    _ => unreachable!(),
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    (parsed.remove(0), Image::new(parsed))
}

#[cfg(test)]
mod tests {
    use helper::Input;

    #[test]
    fn test_p1() {
        let test_input = Input::new("inputs/test.txt".to_string(), 20, 2021).unwrap();
        assert_eq!(super::part1(test_input), 35);

        let test = Input::new("inputs/input.txt".to_string(), 20, 2021).unwrap();
        assert_eq!(super::part1(test), 5503);
    }

    #[test]
    fn test_p2() {
        let test_input = Input::new("inputs/test.txt".to_string(), 20, 2021).unwrap();
        assert_eq!(super::part2(test_input), 3351);

        let test = Input::new("inputs/input.txt".to_string(), 20, 2021).unwrap();
        assert_eq!(super::part2(test), 19156);
    }
}
