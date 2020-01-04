import fs from "fs";
import BigInt from "big-integer"

// exit with error if not args is specified
if (process.argv.length < 3) {
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

  // exit with error if not args is specified
  if (process.argv.length < 5) {
    console.error("Santa is not happy some of the arguments are missing");
    process.exit(1);
  }

  // thanks to https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnkaju/
  let mul = BigInt(1)
  let offset = BigInt(0)

  const TIMES = BigInt(process.argv[3])
  const SIZE = BigInt(process.argv[4])
  const POS = 2020

  rounds.forEach(round => {
    const kind = round!.kind

    switch (kind) {

      // cut
      case "cut":
        offset = BigInt(round!.param!).times(mul).add(offset).mod(SIZE)
        break;

      // deal into new stack
      case "dns":
        mul = mul.times(-1).mod(SIZE)
        offset = offset.add(mul).mod(SIZE)
        break;

      // deal with increment
      case "dwi":
        mul = BigInt(round!.param!).modInv(SIZE).times(mul).mod(SIZE)
        break;

      default:
        break;

    }
  });

  const inc = mul.modPow(TIMES, SIZE)

  const off = offset.times(BigInt(1).minus(inc)).times(BigInt(1).minus(mul).mod(SIZE).modInv(SIZE)).mod(SIZE)

  console.log("Result, part 2 :", + inc.times(POS).add(off).mod(SIZE))


} catch (e) {
  console.error("Error:", e.stack);
  process.exit(1);
}
