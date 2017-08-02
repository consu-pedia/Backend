package main

import (
	backend "com/consupedia/backend"
	"fmt"
	"io/ioutil"
	"os"
)

// the config file mysql.dsn contains just 1 line with the D.S.N. text,
// e.g. root:@tcp(1.2.3.4:3306)/consuweb?charset=utf8
// (I'm not good at config files)
// the idea is that this information not stored in the program or the repository.
// you can copy example.mysql.dsn to mysql.dsn then just fill in the correct IPv4 address of your MySQL server
func readmysqldsn() (dsn string, err error) {
	mysqldsnbytes, err := ioutil.ReadFile("mysql.dsn")
	if err != nil {
		fmt.Fprintf(os.Stderr, "readmysqldsn(): ERROR reading configuration file mysql.dsn: %v\n", err)
		panic(err)
	}
	dsn = string(mysqldsnbytes)
	return dsn, err
}

func main() {
	fmt.Printf("main program begins\n")

	// TODO put in a config file (security risk)
	mysqldsn, err := readmysqldsn()
	if err != nil {
		panic(err)
	}
	proddb := backend.Initproductsdb(mysqldsn)

	fmt.Printf("webserver starts\n")

	backend.Webserver(proddb) // doesnt return !

	fmt.Printf("main program exits\n")
}
