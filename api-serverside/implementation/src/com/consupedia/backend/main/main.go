package main

import (
	backend "com/consupedia/backend"
	"fmt"
)

func main() {
	fmt.Printf("main program begins\n")

	backend.Webserver() // doesnt return !

	fmt.Printf("main program exits\n")
}
