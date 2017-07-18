package main

import (
	backend "com/consupedia/backend"
	"fmt"
)

func main() {
	fmt.Printf("main program begins\n")

	proddb := backend.Initproductsdb()

	backend.Webserver(proddb) // doesnt return !

	fmt.Printf("main program exits\n")
}
