package backend

import (
	"database/sql"
	"fmt"
	"net/http"
	"regexp"
	"strconv"
)

var Allpathsregexp = regexp.MustCompile("^/products")

var Productsdb *sql.DB = nil

func webserverproductshandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>\n")
	fmt.Fprintf(w, "products dispatcher here see if works %s %s", r.URL, r.URL.Path[1:])

	matchthis := r.URL.String()
	fmt.Fprintf(w, "<br/>DBG matchthis &lt;%s&gt;\n", matchthis)

	q := r.URL.Query()
	fmt.Fprintf(w, "<br/>\nDBG q &lt;%s&gt;\n", q)

	// q is a map like Values
	qid := q["id"]
	if qid != nil {
		fmt.Fprintf(w, "<br/>DBG q has key id value %v\n", qid)

		id64, err := strconv.ParseInt(qid[0], 10, 32)
		if err != nil {
			panic(err)
		}
		var id int = int(id64)
		name, err := Getproductsrecord(Productsdb, id)
		if err != nil {
			panic(err)
		}
		fmt.Fprintf(w, "<br/>DBG seems to have worked, name = &lt;%s&gt;\n", name)

		// create JSON response
		var responsecontainer *Container = nil
		responsecontainer = NewJsonContainer().AddProductRecord(id, name)

		jsonbytes, err := Makejson(responsecontainer.Records)
		if err != nil {
			fmt.Fprintf(w, "<br/>something very wrong in json creation: %s\n", err)
		} else {
			jsonstring := string(jsonbytes)
			fmt.Fprintf(w, "<br/>DBG JSON = \"%s\"\n", jsonstring)
		}

	}

	//	if (matchthis.len >= 9){
	//          testslice := matchthis.URL[0:8]
	//fmt.Printf("DBG testslice <%s> of <%s>\n", testslice, matchthis)
	//        }

	fmt.Fprintf(w, "</body></html>\n")

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

	fmt.Fprintf(w, "<html><body><h1>WTF %s</hi></body></html>", r.URL)
	return
}

func Webserver(proddb *sql.DB) {
	Productsdb = proddb
	http.HandleFunc("/products", webserverproductshandler)
	http.HandleFunc("/", webserverresthandler)
	http.ListenAndServe(":1752", nil)
}
