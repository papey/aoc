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
    let res = match compute_orbits(&orbs, "COM", 0) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{}", e);
            process::exit(1);
        }
    };

    // Print
    println!("{}", res);
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
