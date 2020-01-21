use itertools::Itertools;
use std::{env, fs, process};

fn main() {
    // Check args
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Santa is not happy, some of the arguments are missing !");
        process::exit(1);
    }

    // read input file
    let input = match fs::read_to_string(&args[1]) {
        Ok(input) => input,
        Err(err) => {
            eprintln!("{}", err);
            process::exit(1);
        }
    };

    // from input to array of ints
    let mut phase = input
        .chars()
        .map(|c| c.to_digit(10).unwrap() as i32)
        .collect_vec();

    // for all phases
    for _ in 0..100 {
        // next phase
        let mut next = Vec::new();
        // for all elements
        for i in 0..phase.len() {
            // compute phase using zip on phase with pattern
            let sum = phase
                .iter()
                .zip(
                    // never ending pattern
                    [0, 1, 0, -1]
                        .iter()
                        .flat_map(|x| std::iter::once(x).cycle().take(i + 1))
                        .cycle()
                        .skip(1),
                )
                // calculate
                .map(|(a, b)| a * b)
                // sum
                .sum::<i32>();
            // take modulo 10
            next.push((sum % 10).abs());
        }
        phase = next;
    }

    // compute result
    let res = phase[0..8]
        .iter()
        .flat_map(|i| vec![(*i + 48) as u8 as char])
        .collect::<String>();

    // print
    println!("Result, part 1 : {}", res);

    // now, part 2
    let mut phase = input
        .chars()
        .map(|c| c.to_digit(10).unwrap() as usize)
        .collect_vec();

    // from index
    let index = phase
        .iter()
        .take(7)
        .fold(0, |acc, &x| acc * 10 + x as usize);

    // repeat 10 000 times
    let len = phase.len();
    phase = phase
        .into_iter()
        .cycle()
        .take(len * 10_000)
        .skip(index)
        .collect();

    // for all phases
    for _ in 0..100 {
        // next phase
        let mut next = Vec::new();
        // sum all
        let mut sum = phase.iter().sum::<usize>();
        // for all elements
        for n in phase.iter() {
            // add new element
            next.push(sum % 10);
            // next element can be computed like this
            sum -= n;
        }
        // replace
        phase = next;
    }

    // compute result
    let res = phase[0..8]
        .iter()
        .flat_map(|i| vec![(*i + 48) as u8 as char])
        .collect::<String>();

    // print
    println!("Result, part 2 : {}", res);
}
