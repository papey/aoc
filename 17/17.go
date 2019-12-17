package main

import (
	"fmt"
	"image"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

var (
	up    = image.Point{0, -1}
	down  = image.Point{0, 1}
	left  = image.Point{-1, 0}
	right = image.Point{1, 0}
)

var (
	tr = map[image.Point]image.Point{up: right, right: down, down: left, left: up}
	tl = map[image.Point]image.Point{up: left, left: down, down: right, right: up}
)

func main() {
	// check args
	if len(os.Args) < 2 {
		fmt.Println("Santa is not happy, some of the arguments are missing")
		os.Exit(1)
	}

	// read data
	input, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// get all codes from input
	codes := strings.Split(strings.TrimSpace(string(input)), ",")

	// intcode computer memory
	mem := map[int]int64{}

	// use a map since memory can be discontinue
	for i, c := range codes {
		// into map
		mem[i], _ = strconv.ParseInt(c, 10, 0)
	}

	// input and output channels
	in := make(chan int64, 1)
	out := make(chan int64)

	// run the incode computer
	go run(mem, in, out)

	// init output builder
	var builder strings.Builder

	// while intcode computer is working
	for {
		// get output
		c, ok := <-out
		if !ok {
			break
		}

		// append output to builder
		builder.WriteRune(rune(c))
	}

	// create view
	view := strings.Split(strings.TrimSpace(builder.String()), "\n")
	w, h := len(view[0]), len(view)

	// Part 1
	res := 0

	for i := 1; i+1 < h; i++ {
		for j := 1; j+1 < w; j++ {
			if view[i][j] == '#' && view[i+1][j] == '#' && view[i][j+1] == '#' && view[i-1][j] == '#' && view[i][j-1] == '#' {
				res += i * j
			}
		}
	}

	fmt.Println(fmt.Sprintf("Result, part 1 : %d", res))

	// Part 2
	// Find uncompressed path
	var robot image.Point
	var dir image.Point

	// find robot x and y and direction
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			switch view[y][x] {
			case 'v':
				robot.X = x
				robot.Y = y
				dir = down
			case '^':
				robot.X = x
				robot.Y = y
				dir = up
			case '<':
				robot.X = x
				robot.Y = y
				dir = left
			case '>':
				robot.X = x
				robot.Y = y
				dir = right
			default:
			}

		}
	}

	var times []string
	var moves []string
	var concat []string
	var turn string

	// find the all path
	for {
		l := 0

		for isValid(view, w, h, robot.Add(dir)) {
			robot = robot.Add(dir)
			l++
		}

		if l != 0 {
			times = append(times, strconv.Itoa(l))
			l = 0
			moves = append(moves, turn)
		}

		if isValid(view, w, h, robot.Add(tl[dir])) {
			turn = "L"
			dir = tl[dir]
		} else if isValid(view, w, h, robot.Add(tr[dir])) {
			turn = "R"
			dir = tr[dir]
		} else {
			break
		}
	}

	for i := 0; i < len(moves); i++ {
		cat := fmt.Sprintf("%s%s", moves[i], times[i])
		concat = append(concat, cat)
	}

	fmt.Println("\nPartial result for part 2 (uncompressed path) :")
	fmt.Println(fmt.Sprintf("\n%s\n", strings.Join(concat, ",")))

	// check args
	if len(os.Args) < 3 {
		fmt.Println("\nPlease, compress path by hand and pass instructions as list in a text file as second program argument (check README.md and ./misc/COMPRESS.md if needed)")
		os.Exit(0)
	}

	{

		var output []int64

		// Run for part 2
		// get all codes from input
		codes := strings.Split(strings.TrimSpace(string(input)), ",")

		// read instruction data
		instructions, err := ioutil.ReadFile(os.Args[2])
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		instructions = []byte(fmt.Sprintf("%s\nn\n", instructions))

		// intcode computer memory
		mem := map[int]int64{}

		// use a map since memory can be discontinue
		for i, c := range codes {
			// into map
			mem[i], _ = strconv.ParseInt(c, 10, 0)
		}

		// put robot on
		mem[0] = 2

		// input and output channels
		in := make(chan int64, len(instructions))
		out := make(chan int64)

		// run the incode computer
		go run(mem, in, out)

		// push instructions
		for _, c := range instructions {
			in <- int64(c)
		}

		for {
			value, ok := <-out
			output = append(output, value)
			if !ok {
				break
			}
		}

		fmt.Println(fmt.Sprintf("Result, part 2 : %d", maximum(output)))

	}

}

// maximum will return maximum value found in an array
func maximum(data []int64) int64 {
	var max int64 = data[0]

	for i := range data {
		if data[i] >= max {
			max = data[i]
		}
	}

	return max
}

// isValid return true if "#" false otherwise
func isValid(view []string, w int, h int, next image.Point) bool {
	return next.X >= 0 && next.Y >= 0 && next.X < w && next.Y < h && view[next.Y][next.X] == '#'
}

// getAddr will get address using mod parameter and relative base
func getAddr(mem map[int]int64, offset int, padded string, index int, rb int) int {

	// Get mode for current parameter
	switch padded[3-offset] {
	case '1': // direct
		return index + offset
	case '2': // relative
		return rb + int(mem[index+offset])
	default: // memory
		return int(mem[index+offset])
	}
}

func run(mem map[int]int64, in <-chan int64, out chan<- int64) {

	// index pointer
	ip := 0
	// relative base
	rb := 0

	// translate index jump for each op
	jumps := []int{0, 4, 4, 2, 2, 3, 3, 4, 4, 2}

	for {
		// ensure opcode is padded
		padded := fmt.Sprintf("%05d", mem[ip])
		// convert to int for switch, remove useless 0
		code, _ := strconv.Atoi(padded[3:])

		switch code {
		case 1: // +
			mem[getAddr(mem, 3, padded, ip, rb)] = mem[getAddr(mem, 1, padded, ip, rb)] + mem[getAddr(mem, 2, padded, ip, rb)]
		case 2: // *
			mem[getAddr(mem, 3, padded, ip, rb)] = mem[getAddr(mem, 1, padded, ip, rb)] * mem[getAddr(mem, 2, padded, ip, rb)]
		case 3: // input
			mem[getAddr(mem, 1, padded, ip, rb)] = <-in
		case 4: // output
			out <- mem[getAddr(mem, 1, padded, ip, rb)]
		case 5: // jump-if
			if mem[getAddr(mem, 1, padded, ip, rb)] != 0 {
				ip = int(mem[getAddr(mem, 2, padded, ip, rb)])
				continue
			}
		case 6: // jump-if
			if mem[getAddr(mem, 1, padded, ip, rb)] == 0 {
				ip = int(mem[getAddr(mem, 2, padded, ip, rb)])
				continue
			}
		case 7: // less
			if mem[getAddr(mem, 1, padded, ip, rb)] < mem[getAddr(mem, 2, padded, ip, rb)] {
				mem[getAddr(mem, 3, padded, ip, rb)] = 1
			} else {
				mem[getAddr(mem, 3, padded, ip, rb)] = 0
			}
		case 8: // equal
			if mem[getAddr(mem, 1, padded, ip, rb)] == mem[getAddr(mem, 2, padded, ip, rb)] {
				mem[getAddr(mem, 3, padded, ip, rb)] = 1
			} else {
				mem[getAddr(mem, 3, padded, ip, rb)] = 0
			}
		case 9: // relative base update
			rb += int(mem[getAddr(mem, 1, padded, ip, rb)])
		case 99: // exit
			close(out)
			return
		}

		ip += jumps[code]
	}
}
