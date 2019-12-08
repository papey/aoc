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

  // Part 1
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
  console.log("Result, part 1 : " + counterz[0].o * counterz[0].t);

  // Part 2
  // use first layer as base
  let base = layers[0];

  // Copute final layer
  let final = base
    // find up color element in layers
    .map((e, i) => {
      // if the element is `transparent` go into deeper layers
      if (e == 2) {
        // Go into other layers to find current value (start at 1 since base array is init with layer 0)
        for (let index = 1; index < layers.length; index++) {
          // if a color is found, return the value
          if (layers[index][i] != 2) {
            // apply layer color value
            return layers[index][i];
          }
        }
        // Should not reach this part
        return undefined;
      }
      // if the element of the first layer is a color, return it
      return e;
    })
    // just for fun
    .map(e => {
      if (e == 0) {
        // empty
        return "⬛";
      } else {
        // oh oh oh
        return "🎅";
      }
    });

  // final image
  let img = [];
  // some index
  let idx = 0;

  // build image
  while (idx < final.length) {
    // push part of the image to final image slice
    img.push(final.slice(idx, idx + w));
    idx += w;
  }

  // nice print
  console.log("Result, part 2\n" + img.join("\n"));
} catch (e) {
  console.error("Error:", e.stack);
  process.exit(1);
}
