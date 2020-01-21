// oh oh ohoh
// oh oh oh oh
package main

import (
	"fmt"
	"image"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

// map data, discovered by the robot
const (
	wall = iota
	path
	oxsystem
)

// directions
const (
	north = iota + 1
	south
	west
	east
)

// direction to vector
var (
	up    = image.Point{0, -1}
	down  = image.Point{0, 1}
	left  = image.Point{-1, 0}
	right = image.Point{1, 0}
)

// some usefull variables
var (
	commands   = []int64{north, south, west, east}
	directions = []image.Point{up, down, left, right}
	reverse    = map[int64]int64{north: south, south: north, west: east, east: west}
	direction  = map[int64]image.Point{north: up, south: down, west: left, east: right}
)

// simple queue system
type job struct {
	Pos  image.Point
	Dist int
	Next *job
}

// queue is a set of jobs
type queue []job

// main function
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

	// robot position
	var robot image.Point

	// grid
	grid := make(map[image.Point]int)
	// init grid with robot position
	grid[robot] = path

	// oxygen system location
	var oxsys image.Point
	// distance from oxygen system
	var dist int

	// complete the map
	{
		// init some queue
		var q queue
		// add init data to queue
		q = append(q, job{Pos: robot, Dist: 0})

		// while len is not empty
		for len(q) != 0 {
			// get first item
			item := q[0]
			// update list
			q = q[1:]

			// move robot to next item in queue
			robot = move(robot, item.Pos, grid, in, out)

			// try all direction
			for _, cmd := range commands {
				// next position
				np := robot.Add(direction[cmd])
				// next distance
				nd := item.Dist + 1

				// check if we know what's in the next position
				if _, ok := grid[np]; !ok {
					// Try command
					in <- cmd
					// Get return from robot
					switch <-out {

					case 0: // it's a wall
						grid[np] = wall

					case 2: // oxygen system
						// store variable
						if dist == 0 {
							dist = nd
							oxsys = np
						}
						// consider it as a path case
						// fact that it's the oxygen system is in the intcode vm
						fallthrough

					case 1: // it's a path
						grid[np] = path
						// go to this path by appending it to the queue
						q = append(q, job{Pos: np, Dist: nd})
						// go backward
						in <- reverse[cmd]
						// wait for intcode to reach previous state
						<-out
					}
				}
			}
		}
	}

	// part 1
	fmt.Println(fmt.Sprintf("Result, part 1 : %d", dist))

	var minutes int

	// go from oxygen system to the rest of the map
	{
		// new queue
		var q queue
		// init queue with oxygen system position
		q = append(q, job{Pos: oxsys, Dist: 0})

		// keep state of checked area
		checked := make(map[image.Point]bool)
		checked[oxsys] = true

		// while queue is not empty
		for len(q) != 0 {
			// get first queue item
			item := q[0]
			q = q[1:]

			minutes = max(minutes, item.Dist)

			for _, dir := range directions {
				next := item.Pos.Add(dir)
				if !checked[next] && grid[next] == path {
					checked[next] = true
					q = append(q, job{Pos: next, Dist: item.Dist + 1})
				}
			}
		}
	}

	// part 2
	fmt.Println(fmt.Sprintf("Result, part 2 : %d", minutes))

}

// goto will try to go
func move(current, dest image.Point, grid map[image.Point]int, in chan int64, out chan int64) image.Point {

	// link between each jobs
	var link *job

	// create a new queue
	var q queue
	q = append(q, job{Pos: dest, Dist: 0})

	visited := make(map[image.Point]bool)
	visited[dest] = true

	// while there is things inside the queue
	for len(q) != 0 {
		// get first element in queue
		item := q[0]
		q = q[1:]

		// if we reach the destination
		if item.Pos == current {
			link = &item
			break
		}

		// check all the directions
		for _, dir := range directions {
			// compute next position
			next := item.Pos.Add(dir)
			// if not visited
			if !visited[next] && grid[next] == path {
				// visite
				visited[next] = true
				// append to queue
				q = append(q, job{Pos: next, Dist: item.Dist + 1, Next: &item})
			}
		}
	}

	// send commmands to get to destination
	for link.Next != nil {
		for cmd, dir := range direction {
			if link.Pos.Add(dir) == link.Next.Pos {
				in <- cmd
				<-out
				break
			}
		}

		// go to next element
		link = link.Next
	}

	// return destination
	return dest
}

func minimum(v1 image.Point, v2 image.Point) image.Point {
	return image.Point{
		X: min(v1.X, v2.X),
		Y: min(v1.Y, v2.Y),
	}
}

func maximum(v1 image.Point, v2 image.Point) image.Point {
	return image.Point{
		X: max(v1.X, v2.X),
		Y: max(v1.Y, v2.Y),
	}
}

func min(x, y int) int {
	if y < x {
		return y
	}
	return x
}

func max(x, y int) int {
	if y > x {
		return y
	}
	return x
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
