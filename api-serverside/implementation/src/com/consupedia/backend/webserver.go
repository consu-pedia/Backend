package backend

import (
	"fmt"
	"net/http"
)

func webserverhandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hi see if works %s", r.URL.Path[1:])
}

func Webserver() {
	http.HandleFunc("/", webserverhandler)
	http.ListenAndServe(":1752", nil)
}
