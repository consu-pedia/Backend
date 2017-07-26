package backend

import (
	"database/sql"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strconv"
	"strings"
)

var Allpathsregexp = regexp.MustCompile("^/api/v1/products")
var productidregexp = regexp.MustCompile("^[0-9]+")

var Productsdb *sql.DB = nil

var PRODUCTSAPI string = "/api/v1/products"

var DEBUG bool = false

// API "endpoint" /api/v1/products
// provides the following x functions:
// TODO GET /products => get list of all products with pagination and Link headers; takes additional parameters with the ? mechanism
// GET /products/<p> => get details of 1 product
// TODO DELETE /products/<p> => remove products table record <p> and all dependencies
// TODO POST /products => create new product and return its id
// TODO PUT /products/<p> => update product record

func singleproductquery(w http.ResponseWriter, productid int) (err error) {
	err = nil
	if Productsdb == nil {
		panic("Productsdb not initialized")
	}

	name, err := Getproductsrecord(Productsdb, productid)
	if err != nil {
		panic(err)
	}
	if DEBUG {
		fmt.Fprintf(w, "<br/>DBG seems to have worked, name = &lt;%s&gt;\n", name)
	}

	// create JSON response

	// ALTERNATIVE 1: just product
	productrec := NewProductstruct(productid, name)
	jsonbytes, err := Makejson(productrec)

	// ALTERNATIVE 2: container
	//		var responsecontainer *Container = nil
	//		responsecontainer = NewJsonContainer().AddProductRecord(productid, name)
	//		jsonbytes, err := Makejson(responsecontainer.Records)

	if err != nil {
		fmt.Fprintf(w, "<br/>something very wrong in json creation: %s\n", err)
	} else {
		jsonstring := string(jsonbytes)
		if DEBUG {
			fmt.Fprintf(w, "<br/>DBG JSON = \"%s\"\n", jsonstring)
		}
		fmt.Fprintf(w, "%s\n", jsonstring)
		if DEBUG {
			fmt.Fprintf(w, "\"\n")
		}
	}
	return err
}

func addnameclause(wherestring string, v []string) (res string) {
	if DEBUG {
		fmt.Printf("\n\n\naddnameclause(%s)\n\n\n", v[0])
	}
	nameWithAsterisks := v[0]
	var squot int = 0x27 // single quote

	if wherestring != "" {
		wherestring += " AND "
	}

	// replace asterisks U+002A with % as wildcard
	nameWithPercent := strings.Replace(nameWithAsterisks, "*", "%", -1)
	var nameclause string = fmt.Sprintf("name LIKE %c%v%c", squot, nameWithPercent, squot)
	wherestring += nameclause
	return wherestring
}

func multiproductconstructwherestring(w http.ResponseWriter, q url.Values) (wherestring string, err error) {

	wherestring = ""

	if DEBUG {
		fmt.Fprintf(w, "<br/>\nmultiproductconstructwherestring() DBG q &lt;%s&gt;\n", q)
	}

	for k, v := range q {
		if DEBUG {
			fmt.Fprintf(w, "<br/>DBG k=\"%v\" v=\"%v\"\n", k, v)
		}

		switch k {
		case "name":
			wherestring = addnameclause(wherestring, v)

		default:
			fmt.Fprintf(w, "<br/>ERROR multiproductconstructwherestring(): UNIMPLEMENTED key %v\n", k)
		}
	} // next k,v pair from q

	if DEBUG {
		fmt.Printf("<br/>DBG wherestring now %c%s%c\n", 0x27, wherestring, 0x27)
	}
	//
	// 	// q is a map like Values
	// 	qid := q["id"]
	// 	if qid != nil {
	// 		if DEBUG {
	// 			fmt.Fprintf(w, "<br/>DBG q has key id value %v\n", qid)
	// 		}
	//
	// 		id64, err := strconv.ParseInt(qid[0], 10, 32)
	// 		if err != nil {
	// 			panic(err)
	// 		}
	// 		var productid int = int(id64)

	// 	}

	//	if (matchthis.len >= 9){
	//          testslice := matchthis.URL[0:8]
	//fmt.Printf("DBG testslice <%s> of <%s>\n", testslice, matchthis)
	//        }
	return wherestring, err
}

// implementation:
// in principle dump the whole table, with a SQL search query limited by the ? attributes
func multiproductquery(w http.ResponseWriter, q url.Values, reststring string) (err error) {
	err = nil
	var wherestring string = ""
	var productslice []Productstruct = nil
	var jsonbytes []byte = nil
	var rc int = 0

	if DEBUG {
		fmt.Fprintf(w, "<br/>ERROR STUB UNFINISHED API FUNCTION: method get + not productidprovided, reststring= \"%s\"\n", reststring)
	}
	fmt.Printf("<br/>ERROR STUB API FUNCTION: method get + not productidprovided, reststring= \"%s\"\n", reststring)

	var rows *sql.Rows = nil

	wherestring, err = multiproductconstructwherestring(w, q)

	if err != nil {
		panic(err)
	}

	rows, err = Getproductsquery(Productsdb, wherestring)
	defer rows.Close()

	if err != nil {
		fmt.Fprintf(w, "<br/>ERROR query with wherestring %s FAILED: %v\n", wherestring, err)
		return
	}

	// grmbl grmbl why nothing faster
	for rows.Next() {

		var productid int
		var name string
		err = rows.Scan(&productid, &name)
		if err != nil {
			rc = -1
			break
		}
		if DEBUG {
			fmt.Fprintf(w, "<br/># %d %d %s\n", rc, productid, name)
		}
		productrec := NewProductstruct(productid, name)

		productslice = append(productslice, *productrec)

		// add to array of Product

		rc++
	}
	if DEBUG {
		fmt.Fprintf(w, "<br/>INFO query with wherestring %s success: %d recs\n", wherestring, rc)
	}

	if rc == 0 {
		fmt.Fprintf(w, "<br/>WARNING empty result\n")
	}
	jsonbytes, err = Makejson(productslice)

	if DEBUG {
		fmt.Fprintf(w, "<br/><br/>HERE IT COMES: %d<br/>\n", rc)
	}
	jsonstring := string(jsonbytes)
	fmt.Fprintf(w, "%s\n", jsonstring)

	// assert(rc>0)

	return err
}

func webserverproductshandler(w http.ResponseWriter, r *http.Request) {
	var productidprovided bool = false
	var productid int
	var reststring string = ""
	fmt.Fprintf(os.Stderr, "starting webserver\n")
	if DEBUG {
		fmt.Fprintf(w, "<html><body>\n")
		fmt.Fprintf(w, "products dispatcher here see if works %s %s", r.URL, r.URL.Path[1:])
	}

	if DEBUG {
		fmt.Fprintf(w, "<html><body><br/>This was a %s request, </body></html>\n", r.Method)
	}

	matchthis := r.URL.String()
	if DEBUG {
		fmt.Fprintf(w, "<br/>DBG matchthis &lt;%s&gt;\n", matchthis)
	}

	// first parse if productid is provided
	// TODO
	if matchthis[0:len(PRODUCTSAPI)] != PRODUCTSAPI {
		fmt.Fprintf(w, "<br/>ERROR matchthis &lt;%s&gt; SHOULD NEVER GET HERE\n", matchthis)
		return
	} else {
		reststring = matchthis[len(PRODUCTSAPI)+1:]

		productidstring := productidregexp.FindString(reststring)
		productidprovided = (productidstring != "")

		if productidprovided {
			if DEBUG {
				fmt.Fprintf(w, "<br/>OK matchthis &lt;%s&gt;<br/>rest &lt;%s&gt;, productidProvided = %v\n", matchthis, reststring, productidprovided)
				fmt.Fprintf(w, "<br/>productid to parse from &lt;%v&gt;\n", productidstring)
			}
			var err error
			productid, err = strconv.Atoi(productidstring)
			if err != nil {
				fmt.Fprintf(w, "<br/>ERROR malformed productid &lt;%v&gt; : %v\n", productidstring, err)
				return
			}

			if DEBUG {
				fmt.Fprintf(w, "<br/>success, productid = %d\n", productid)
			}

		}
	}

	// we now have all the info to parse:
	// r.Method and productidprovided

	if (r.Method == "GET") && (productidprovided) { // single product query
		err := singleproductquery(w, productid)
		if err != nil {
			fmt.Fprintf(w, "<br/>TODO error from singleproductquery()\n")
		}
		return

	} // endif (GET and productidprovided)

	if (r.Method == "GET") && (!productidprovided) { // multi product query
		err := multiproductquery(w, r.URL.Query(), reststring)
		if err != nil {
			fmt.Fprintf(w, "<br/>TODO error from multiproductquery()\n")
		}
		return

	} // endif (GET and not productidprovided)

	fmt.Fprintf(w, "<br/>ERROR UNIMPLEMENTED API FUNCTION: method %s + productidprovided? %v\n", r.Method, productidprovided)

	if DEBUG {
		fmt.Fprintf(w, "</body></html>\n")
	}

	return
}

func webserverresthandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "general dispatcher here see if works %s %s", r.URL, r.URL.Path[1:])

	// must match allpathsregexp
	m := Allpathsregexp.FindStringSubmatch(r.URL.Path)
	if m == nil {
		http.NotFound(w, r)
		return
	}
	// need to dispatch depending on the right side of the URL

	fmt.Fprintf(w, "<html><body><h1>WTF %s</h1></body></html>", r.URL)
	return
}

func Webserver(proddb *sql.DB) {
	Productsdb = proddb
	http.HandleFunc("/api/v1/products/", webserverproductshandler)
	http.HandleFunc("/", webserverresthandler)
	http.ListenAndServe(":1752", nil)
}
