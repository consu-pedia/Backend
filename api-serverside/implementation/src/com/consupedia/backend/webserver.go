package backend

import (
	"fmt"
	"net/http"
	"regexp"
)

var Allpathsregexp = regexp.MustCompile("^/products")

func webserverhandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hi dispatcher here see if works %s %s", r.URL, r.URL.Path[1:])

	// must match allpathsregexp
	m := Allpathsregexp.FindStringSubmatch(r.URL.Path)
	if m == nil {
		http.NotFound(w, r)
		return
	}
	// need to dispatch depending on the right side of the URL

	return
}

func Webserver() {
	http.HandleFunc("/", webserverhandler)
	http.ListenAndServe(":1752", nil)
}
