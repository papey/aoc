// uses
use std::collections::HashMap;
use std::{env, fs, process};
use std::{error::Error, fmt};

// Custom AOC error
#[derive(Debug)]
struct AOCError;

impl Error for AOCError {}

impl fmt::Display for AOCError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Oh shit, 💥")
    }
}

// main function
fn main() {
    // Check args
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Santa is not happy, some of the arguments are missing !");
        process::exit(1);
    }

    // Create graph
    let orbs = match create_graph(&args[1]) {
        Ok(o) => o,
        Err(e) => {
            eprintln!("{}", e);
            process::exit(1);
        }
    };

    // Compute from COM
    match compute_orbits(&orbs, "COM", 0) {
        Ok(r) => println!("Result for part 1 : {}", r),
        Err(e) => {
            eprintln!("{}", e);
            process::exit(1);
        }
    };

    // Compute path from YOU to SAN
    match compute_path(&orbs) {
        // Ensure - 2 before print since YOU and SAN does not count in number of orbit jumps
        Ok(r) => println!("Result for part 2 : {}", r - 2),
        Err(e) => {
            eprintln!("{}", e);
            process::exit(1)
        }
    }
}

// create a graph from input using hashmaps
fn create_graph(input: &String) -> Result<HashMap<String, Vec<String>>, Box<dyn Error>> {
    // allocate
    let mut orbs: HashMap<String, Vec<String>> = HashMap::new();

    // read input
    let content = fs::read_to_string(input)?;

    // trim, split on new line, loop
    content.trim().split("\n").for_each(|elem| {
        // trim, split on ), collect all
        let splits: Vec<&str> = elem.trim().split(")").collect();

        // add entry child entry, on parent
        orbs.entry(splits[0].to_string())
            // add a new empty vect if needed
            .or_default()
            // then push child
            .push(splits[1].to_string());
    });

    // Return generated graph
    Ok(orbs)
}

// Inverse graph data
fn flat(input: &HashMap<String, Vec<String>>) -> HashMap<String, String> {
    let mut flatted: HashMap<String, String> = HashMap::new();

    for (k, v) in input {
        for e in v {
            flatted.insert(e.clone(), k.clone());
        }
    }
    flatted
}

// compute orbits
fn compute_orbits(
    orbs: &HashMap<String, Vec<String>>,
    name: &str,
    past: u32,
) -> Result<u32, AOCError> {
    // get all value
    let total = past;

    // count number of child and go into it
    let res = match orbs.get(name) {
        Some(orb) => {
            // child counter number
            let mut count = 0;
            // for each child
            for e in orb {
                // run the same fn with child as name, increment total
                count += match compute_orbits(orbs, e, total + 1) {
                    Ok(r) => r,
                    Err(_) => return Err(AOCError),
                };
            }
            count
        }
        // If there is no child, return 0
        None => 0,
    };

    // Sumup total + result
    Ok(res + total)
}

// compute path from san to me
fn compute_path(orbs: &HashMap<String, Vec<String>>) -> Result<i32, AOCError> {
    // Prepare an inverse
    let flatted = flat(orbs);

    // Compute distance between YOU and SAN orbits
    Ok(distance(&flatted, String::from("YOU"), String::from("SAN")))
}

// Compute distance between to orbits
fn distance(flatmap: &HashMap<String, String>, from: String, to: String) -> i32 {
    // from list
    let f = olist(&flatmap, from);
    // to list
    let t = olist(&flatmap, to);

    // Move back from `from`
    for (i, f) in f.iter().enumerate() {
        // Move back from `to`
        for (j, t) in t.iter().enumerate() {
            // If paths cross
            if f == t {
                // return number of orbits jump from `from` + number of orbits jumps from `to`
                return (i + j) as i32;
            }
        }
    }

    // Dead branch so return something fun
    42
}

// List all orbits that are attach to the from parameter
fn olist(flatmap: &HashMap<String, String>, from: String) -> Vec<String> {
    // init data
    let mut list = vec![from.clone()];
    let mut orbit = from.as_str();

    // While a path exists
    while flatmap.contains_key(orbit) {
        // Get next orbit
        orbit = flatmap
            .get(orbit)
            .expect("Oh oh oh, shit, an expected orbit was not found");
        // push next orbit to list
        list.push(orbit.to_owned());
    }

    // return list
    list
}
