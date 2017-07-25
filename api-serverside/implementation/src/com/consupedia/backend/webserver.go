package backend

import (
	"database/sql"
	"fmt"
	"net/http"
	"regexp"
	"strconv"
)

var Allpathsregexp = regexp.MustCompile("^/api/v1/products")
var productidregexp = regexp.MustCompile("^[0-9][0-9]+")

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

func webserverproductshandler(w http.ResponseWriter, r *http.Request) {
	var productidprovided bool = false
	var productid int
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
		reststring := matchthis[len(PRODUCTSAPI)+1:]

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
		name, err := Getproductsrecord(Productsdb, productid)
		if err != nil {
			panic(err)
		}
		if DEBUG {
			fmt.Fprintf(w, "<br/>DBG seems to have worked, name = &lt;%s&gt;\n", name)
		}

		// create JSON response
		var responsecontainer *Container = nil
		responsecontainer = NewJsonContainer().AddProductRecord(productid, name)

		jsonbytes, err := Makejson(responsecontainer.Records)
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

	} // endif (GET and productidprovided)

	// obsolete for now
	// 	q := r.URL.Query()
	// 	if DEBUG {
	// 		fmt.Fprintf(w, "<br/>\nDBG q &lt;%s&gt;\n", q)
	// 	}
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
