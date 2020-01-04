# Day 8: Space Image Format

## Subject

For example, given an image 3 pixels wide and 2 pixels tall, the image data
123456789012 corresponds to the following image layers:

    Layer 1: 123
             456

    Layer 2: 789
             012

The image you received is 25 pixels wide and 6 pixels tall.

To make sure the image wasn't corrupted during transmission, the Elves would
like you to find the layer that contains the fewest 0 digits. On that layer,
what is the number of 1 digits multiplied by the number of 2 digits?

## Solution

Language used : [TypeScript](https://www.typescriptlang.org/)

### Run

    yarn build && yarn start input/in
