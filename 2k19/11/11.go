// oh ohohoh
package main

// some imports
import (
	"fmt"
	"image"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

// main entry poing
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

	// run in concurrency
	go run(mem, in, out)

	// x and y position, use image point structure
	pos := image.Point{}

	// direction
	dir := 0

	// map of point on ship hull and associated color, each color will be counted one time (overwrite if multiple colors applied)
	// init the map with using a white color
	h := map[image.Point]int64{{0, 0}: 1}

	// delta x and y for each direction
	delta := []image.Point{{0, -1}, {-1, 0}, {0, 1}, {1, 0}}

	// run until the end
	for {
		// give last output as input to robot
		in <- h[pos]
		// add last color to ship hull
		h[pos] = <-out
		//
		t, ok := <-out
		// if channel is closed, robot reach the end
		if !ok {
			break
		}
		// ensure dir will always be >
		// do not forget previous direction
		dir = (dir + 1 + 2*int(t)) % 4
		// update position
		pos = pos.Add(delta[dir])
	}

	// variables goes from
	// a little bit of experiment driven debug
	for y := 0; y < 6; y++ {
		for x := 0; x < 45; x++ {
			fmt.Print([]string{"⬛", "🎅"}[h[image.Point{x, y}]])
		}
		fmt.Println()
	}

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
