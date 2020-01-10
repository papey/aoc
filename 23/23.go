package main

import (
	"fmt"
	"image"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

// NODES is the number of computers in the networks
const NODES = 50

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
	mem := map[int]int{}

	// use a map since memory can be discontinue
	for i, c := range codes {
		// into map
		val, _ := strconv.ParseInt(c, 10, 0)
		mem[i] = int(val)
	}

	// simulate, part 1
	simulate(mem, false)

	// simulate, part 2
	simulate(mem, true)

}

// simulate will run network packet transaction
func simulate(ini map[int]int, nat bool) {
	// init all computers
	computers := createNetwork(ini)

	// packet
	// current nat packet
	natPkt := image.Point{0, 0}
	// packet in memory used to check for an identical packet
	previousNat := image.Point{-1, -1}

	for {
		// consider network as idling
		idling := true
		// for all computers
		for _, computer := range computers {
			// pkt value
			var pkt image.Point

			// check of current computer queue
			if len(computer.queue) > 0 {
				// get first packet from queue
				pkt = computer.queue[0]
			} else {
				// waiting mode
				pkt = image.Point{-1, -1}
			}

			// select computer pipe input/output
			select {
			case dest := <-computer.pipe: // output
				x := <-computer.pipe
				y := <-computer.pipe

				// if pkt destination is nat
				if dest == 255 {
					// if nat not enabled, part 1 is done
					if !nat {
						fmt.Println(fmt.Sprintf("Result part 1 : %d", y))
						return
					}
					// else, configure nat packet
					natPkt.X, natPkt.Y = x, y
					break
				}
				// if destination is a computer in the network
				// add pkt to queue
				computers[dest].queue = append(computers[dest].queue, image.Point{x, y})
				// network is not idling
				idling = false
			case computer.pipe <- pkt.X: // input
				// if packet data is not -1 (waiting mode)
				if pkt.X != -1 {
					// send Y value
					computer.pipe <- pkt.Y
					// cut queue
					computer.queue = computer.queue[1:]
					idling = false
				}
			}

		}

		// check is network is idling
		if !idling {
			continue
		}

		// ensure all computers have empty queue
		for _, computer := range computers {
			if len(computer.queue) > 0 {
				idling = false
				break
			}
		}

		// if we are sure everything is idling
		if idling {
			// check nat equality with previous
			if natPkt == previousNat {
				fmt.Println(fmt.Sprintf("Result, part 2 : %d", natPkt.Y))
				return
			}

			// add packet to first computer queue
			computers[0].queue = append(computers[0].queue, natPkt)
			// memorize nat packet value
			previousNat = natPkt

		}
	}

}

// create the all network
func createNetwork(mem map[int]int) []*computer {

	// init
	computers := make([]*computer, NODES)

	// create and run
	for i := 0; i < NODES; i++ {
		computers[i] = createComputer(mem)
		go computers[i].run()
		computers[i].pipe <- i
	}

	// return
	return computers

}

// computer struct
type computer struct {
	mem   map[int]int
	ip    int
	rb    int
	pipe  chan int
	queue []image.Point
}

// create and init computer with input memory
func createComputer(memory map[int]int) *computer {

	// init
	mem := map[int]int{}

	// copy
	for k, v := range memory {
		mem[k] = v
	}

	// create
	return &computer{mem: mem, ip: 0, rb: 0, pipe: make(chan int), queue: make([]image.Point, 0)}
}

func (c *computer) run() {

	// translate index jump for each op
	jumps := []int{0, 4, 4, 2, 2, 3, 3, 4, 4, 2}

	for {
		// ensure opcode is padded
		padded := fmt.Sprintf("%05d", c.mem[c.ip])
		// convert to int for switch, remove useless 0
		code, _ := strconv.Atoi(padded[3:])

		switch code {
		case 1: // +
			c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] + c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)]
		case 2: // *
			c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] * c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)]
		case 3: // input
			c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] = <-c.pipe
		case 4: // output
			c.pipe <- c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)]
		case 5: // jump-if
			if c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] != 0 {
				c.ip = int(c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)])
				continue
			}
		case 6: // jump-if
			if c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] == 0 {
				c.ip = int(c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)])
				continue
			}
		case 7: // less
			if c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] < c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)] {
				c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = 1
			} else {
				c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = 0
			}
		case 8: // equal
			if c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)] == c.mem[getAddr(c.mem, 2, padded, c.ip, c.rb)] {
				c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = 1
			} else {
				c.mem[getAddr(c.mem, 3, padded, c.ip, c.rb)] = 0
			}
		case 9: // relative base update
			c.rb += int(c.mem[getAddr(c.mem, 1, padded, c.ip, c.rb)])
		case 99: // exit
			close(c.pipe)
			return
		}

		c.ip += jumps[code]
	}
}

// getAddr will get address using mod parameter and relative base
func getAddr(mem map[int]int, offset int, padded string, index int, rb int) int {

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
