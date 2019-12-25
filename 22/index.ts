import fs from "fs";

// exit with error if not args is specified
if (process.argv.length != 3) {
  console.error("Santa is not happy some of the arguments are missing");
  process.exit(1);
}

const CARDS = 10007

// read input file
try {
  // parse input
  const input = fs.readFileSync(process.argv[2], "utf8");

  // from input to rounds
  const rounds = input.split("\n").map((e) => {
    // cut
    if (e.startsWith("cut")) {
      return {
        kind: "cut",
        param: Number.parseInt(e.split(" ")[1])
      }
    }

    // deal with
    if (e.startsWith("deal with")) {
      return {
        kind: "dwi",
        param: Number.parseInt(e.split(" ")[3])
      }
    }

    // deal into
    if (e.startsWith("deal into")) {
      return {
        kind: "dns",
      }
    }

  });

  // create deck
  let deck = [...Array(CARDS).keys()]

  rounds.forEach(round => {
    const kind = round!.kind;

    switch (kind) {

      // cut
      case "cut":
        const r = deck.slice(round!.param!)
        const l = deck.slice(0, round!.param!)
        deck = r.concat(l)
        break;

      // deal into new stack
      case "dns":
        deck = deck.reverse()
        break;

      // deal with increment
      case "dwi":
        // init
        let table = new Array(CARDS)
        let origin = 0
        let index = 0

        // while there is cards to shuffle
        while (origin < CARDS) {
          // if card is not in it's position
          if (table[index % CARDS] === undefined) {
            // put it
            table[index % CARDS] = deck[origin]
            // pass to next card
            origin++
          }

          // increment index using parameter
          index += round!.param!
        }

        // table goes into deck
        deck = table
        break;

      default:
        break;
    }

  });

  console.log("Result, part 1 : " + deck.findIndex((x) => x === 2019))

} catch (e) {
  console.error("Error:", e.stack);
  process.exit(1);
}
