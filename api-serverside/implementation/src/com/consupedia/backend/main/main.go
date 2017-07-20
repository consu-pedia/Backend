package main

import (
	backend "com/consupedia/backend"
	"fmt"
)

func main() {
	fmt.Printf("main program begins\n")

	proddb := backend.Initproductsdb()

	fmt.Printf("webserver starts\n")

	backend.Webserver(proddb) // doesnt return !

	fmt.Printf("main program exits\n")
}
