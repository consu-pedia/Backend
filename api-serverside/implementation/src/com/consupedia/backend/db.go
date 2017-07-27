package backend

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"os"
	"strconv"
	"strings"
	"time"
)

// N.B. variable DEBUG is declared in webserver.go

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

// Conversion function from date/time values in the returned fields
// of a sql.Rows struct, to the time.Time struct that Golang works with.
// The format turned out to be: either nil, or "almost" ISO 8601
// but with the T replaced by a space and no timezone info at the end.
// TODO: return epoch when input is NULL, now it's something like year 0
// which doesn't exist
// It was maybe a bit silly for me to write this but I couldn't find an
// existing implementation. Frits.
func Sqltime2Gotime(sqltime interface{}) (gotime time.Time, err error) {
	var tmptimebytes []byte
	var ttime string

	if sqltime != nil {
		tmptimebytes = sqltime.([]byte)
		//DBG		fmt.Printf("DBG Sqltime2Gotime parsing: %d %02x %02x \"%s\"\n", len(tmptimebytes), tmptimebytes[0], tmptimebytes[1], string(tmptimebytes))
		// it's like ISO 8601 except the letter T is missing
		ttime = strings.Replace(string(tmptimebytes), " ", "T", 1) + "Z"
		gotime = time.Unix(0, 0)
		err = gotime.UnmarshalText([]byte(ttime))
		if err != nil {
			fmt.Printf("DBG aww time conversion FAILED: %v\n", err)
		}
	} else {
		gotime = time.Unix(0, 0)
	}
	return gotime, err
}

func ScanProduct(rows *sql.Rows) (prod Productstruct, err error) {
	var colid int
	var gtin string = ""
	var name string
	var fullname string = ""
	var size int
	var sizeHolder interface{} = nil
	var sizeunitId int
	var sizeunitIdHolder interface{} = nil
	var image string
	var imageHolder interface{} = nil
	var bulk int8          // tinyint(1)
	var description string // text
	var descriptionHolder interface{} = nil
	var category_id int
	var brand_id int
	var brandIdHolder interface{} = nil
	var manufacturer_id int
	var manufacturerIdHolder interface{} = nil

	// sql: Scan error on column index 12: unsupported Scan, storing driver.Value type []uint8 into type *time.Time
	var created_at time.Time
	var createdAtHolder interface{} = nil
	var updated_at time.Time
	var updatedAtHolder interface{} = nil
	err = rows.Scan(&colid, &gtin, &name, &fullname, &sizeHolder, &sizeunitIdHolder, &imageHolder, &bulk, &descriptionHolder, &category_id, &brandIdHolder, &manufacturerIdHolder, &createdAtHolder, &updatedAtHolder)
	if err != nil {
		panic(err)
	}
	if sizeHolder != nil {
		size, err = strconv.Atoi(sizeHolder.(string))
	} else {
		size = 0
	}

	if sizeunitIdHolder != nil {
		sizeunitId, err = strconv.Atoi(sizeunitIdHolder.(string))
	} else {
		sizeunitId = 0
	}

	if imageHolder != nil {
		image = imageHolder.(string)
	} else {
		image = ""
	}

	if descriptionHolder != nil {
		description = descriptionHolder.(string)
	} else {
		description = ""
	}

	if brandIdHolder != nil {
		brand_id, err = strconv.Atoi(brandIdHolder.(string))
	} else {
		brand_id = 0
	}

	if manufacturerIdHolder != nil {
		manufacturer_id, err = strconv.Atoi(manufacturerIdHolder.(string))
	} else {
		manufacturer_id = 0
	}

	// haven't the foggiest idea how to convert raw []int8 to time_t
	// 19 bytes (too long for all time_t like formats), it's just a bloody string!
	created_at, err = Sqltime2Gotime(createdAtHolder)

	updated_at, err = Sqltime2Gotime(updatedAtHolder)

	fmt.Printf("ScanProduct(): just read record %v name %v\n", colid, name)
	prod = Productstruct{Type: TYPE_PRODUCT, Id: colid, Gtin: gtin, Name: name, Fullname: fullname, Size: size, SizeunitId: sizeunitId, Image: image, Bulk: bulk, Description: description, CategoryId: category_id, BrandId: brand_id, ManufacturerId: manufacturer_id, CreatedAt: &created_at, UpdatedAt: &updated_at}
	return prod, nil
}

func Getproductsrecord(db *sql.DB, id int) (prod Productstruct, err error) {
	// from documentation https://github.com/go-sql-driver/mysql/blob/master/README.md#dsn-data-source-name:
	// DSN (Data Source Name)
	// The Data Source Name has a common format, like e.g. PEAR DB uses it, but without type-prefix (optional parts marked by squared brackets):
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	// A DSN in its fullest form:
	// username:password@protocol(address)/dbname?param=value
	// Except for the databasename, all values are optional. So the minimal DSN is: /dbname
	//	db := Initproductsdb()

	stmt, err := db.Prepare("SELECT * FROM products WHERE id = ?")
	// stmt, err := db.Prepare("SELECT id, name FROM products")
	if err != nil {
		panic(err)
	}

	// id_in := 1
	id_in := id

	rows, err := stmt.Query(id_in)
	// rows, err := stmt.Query()
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	// N.B. this must correspond with the values in json.go
	for rows.Next() {

		prod, err = ScanProduct(rows)
		return prod, err
	}
	err = rows.Err()
	if err != nil {
		panic(err)
	}

	db.Close()

	return Productstruct{Name: "some error"}, err

}

func Getproductsquery(db *sql.DB, wherestring string) (rows *sql.Rows, err error) {
	// from documentation https://github.com/go-sql-driver/mysql/blob/master/README.md#dsn-data-source-name:
	// DSN (Data Source Name)
	// The Data Source Name has a common format, like e.g. PEAR DB uses it, but without type-prefix (optional parts marked by squared brackets):
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	// A DSN in its fullest form:
	// username:password@protocol(address)/dbname?param=value
	// Except for the databasename, all values are optional. So the minimal DSN is: /dbname
	//	db := Initproductsdb()

	var querystring string = "SELECT * FROM products"
	if wherestring != "" {
		var sanitized_wherestring string = wherestring // TODO
		querystring = querystring + " WHERE " + sanitized_wherestring
	}

	querystring += ";"

	//	stmt, err := db.Prepare(querystring)
	// stmt, err := db.Prepare("SELECT id, name FROM products")
	//	if err != nil {
	//		panic(err)
	//	}

	if DEBUG {
		fmt.Printf("<br/>DBG executing DB query \"%s\"\n", querystring)
	}
	// the form of the query depends on "utökad sökning" and can
	// therefore not be prepared beforehand. Then we might as well
	// call it directly from the db, as well.
	rows, err = db.Query(querystring)
	// rows, err := stmt.Query()
	if err != nil {
		panic(err)
	}
	//	defer rows.Close()

	//	stmt.Close()
	//	db.Close()
	return rows, err

}
