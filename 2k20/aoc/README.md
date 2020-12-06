# AOC

Advent Of Code solutions for AOC 2k20, in Elixir.

## Running the code

```sh
iex -S mix
iex> AOC.DX.runY()
```

Where X is the day number and Y is the part (1 or 2)

For example, running part 1 of day 1 looks like this `AOC.D1.run1()`

## How do I find a specific solution ?

Solutions are grouped together in an entire week. Each week is a dedicated
file named `wX.ex` in `lib` dir, where X is the week counter

## Running the tests

```sh
mix test
```
