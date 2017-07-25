package backend

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"os"
)

func Initproductsdb() *sql.DB {
	db, err := sql.Open("mysql", "root:@tcp(10.60.218.110:3306)/consuweb?charset=utf8")
	if err != nil {
		panic(err)
	}

	// sql.Open() is lazy so ping
	err = db.Ping()
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: could not connect to Consuweb MySQL DB, quitting.\n")
		panic(err)
	}
	return (db)
}

func Getproductsrecord(db *sql.DB, id int) (name string, err error) {
	// from documentation https://github.com/go-sql-driver/mysql/blob/master/README.md#dsn-data-source-name:
	// DSN (Data Source Name)
	// The Data Source Name has a common format, like e.g. PEAR DB uses it, but without type-prefix (optional parts marked by squared brackets):
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	// A DSN in its fullest form:
	// username:password@protocol(address)/dbname?param=value
	// Except for the databasename, all values are optional. So the minimal DSN is: /dbname
	//	db := Initproductsdb()

	stmt, err := db.Prepare("SELECT id, name FROM products WHERE id = ?")
	// stmt, err := db.Prepare("SELECT id, name FROM products")
	if err != nil {
		panic(err)
	}

	// id_in := 1
	id_in := id

	name = "FUBAR"
	rows, err := stmt.Query(id_in)
	// rows, err := stmt.Query()
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	for rows.Next() {
		var colid int
		err = rows.Scan(&colid, &name)
		if err != nil {
			panic(err)
		}

		fmt.Printf("just read record %v name %v\n", colid, name)
		return name, nil
	}
	err = rows.Err()
	if err != nil {
		panic(err)
	}

	db.Close()

	return "some error", err

}
