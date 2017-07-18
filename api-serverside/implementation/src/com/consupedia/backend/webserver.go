package backend

import (
	"database/sql"
	"fmt"
	"net/http"
	"regexp"
)

var Allpathsregexp = regexp.MustCompile("^/products")

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

func Webserver(dummyproddb *sql.DB) {
	_ = dummyproddb
	http.HandleFunc("/products", webserverproductshandler)
	http.HandleFunc("/", webserverresthandler)
	http.ListenAndServe(":1752", nil)
}
