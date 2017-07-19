package backend

// implementation is as an array of general container objects,
// each of which contains (to begin with) either an error message
// or a product record.

import (
	"encoding/json"
	"fmt"
)

var TYPE_PRODUCT string = "product"
var TYPE_ERROR string = "error"

type Errorstruct struct {
	Type    string `json:type`
	Message string `json:errormessage`
}

type Productstruct struct {
	Type string `json:type`
	Id   string `json:id`
	Name string `json:name`
}

type Containerstruct struct {
	Type       string         `json:type`
	Errorrec   *Errorstruct   `json:record,omitempty`
	Productrec *Productstruct `json:record,omitempty`
}

func Makejson(c []Containerstruct) (jsonbytes []byte, err error) {
	bytes, err := json.MarshalIndent(c, "", "  ")
	jsonbytes = bytes
	return jsonbytes, err
}

func newProductstruct(id int, name string) (pp *Productstruct) {
	p := Productstruct{Type: TYPE_PRODUCT, Id: fmt.Sprintf("%d", id), Name: name}
	return &p
}

func newErrorstruct(message string) (ep *Errorstruct) {
	e := Errorstruct{Type: TYPE_ERROR, Message: message}
	return &e
}
