import fs from "fs";

// exit with error if not args is specified
if (process.argv.length != 3) {
  console.error("Santa is not happy some of the arguments are missing");
  process.exit(1);
}

// image pixel size
const w = 25;
const t = 6;
const lsize = w * t;

// read input file
try {
  const input = fs.readFileSync(process.argv[2], "utf8");

  // split file into number
  const image = input.split("").map(e => parseInt(e));

  // declare some array
  const layers: number[][] = [];

  // for each layers in the image, feel the layers
  for (let index = 0; index < image.length; index += lsize) {
    layers.push(image.slice(index, index + lsize));
  }

  // create a counter object that handle all the information for next steps
  let counterz = layers.map(l => {
    return {
      z: l.filter(e => e == 0).length,
      o: l.filter(e => e == 1).length,
      t: l.filter(e => e == 2).length
    };
  });

  // sort the array, as specified in the challenge
  counterz.sort((a, b) => {
    return a.z - b.z;
  });

  // compute result
  console.log(counterz[0].o * counterz[0].t);
} catch (e) {
  console.error("Error:", e.stack);
  process.exit(1);
}
