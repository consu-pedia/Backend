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

// N.B. all records must have the same JSON record name "record"
// and be distinguished only by different values of "type"
type Containerstruct struct {
	Type       string         `json:"type"`
	Errorrec   *Errorstruct   `json:"record",omitempty`
	Productrec *Productstruct `json:"record",omitempty`
}

type Container struct {
	Records []Containerstruct
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

func NewJsonContainer() *Container {
	// var c Container = Container{ Records: make([]Containerstruct, 0, 16) };
	//  var newrecords [:]Containerstruct
	// var c Container = Container{ Records: &newrecords };
	rs := new([]Containerstruct)
	var c Container = Container{Records: *rs}

	fmt.Printf("DBG: in NewJsonContainer()\n")

	return &c
}

// N.B. I'm using method declaration here, see https://golang.org/ref/spec#Method_declarations
func (c *Container) AddProductRecord(id int, name string) *Container {
	var pp *Productstruct = newProductstruct(id, name)

	// see paragraph "Appending to and copying slices" in golang language ref doc
	c.Records = append(c.Records, Containerstruct{Type: pp.Type, Productrec: pp})

	fmt.Printf("DBG: after AddProductRecord(%v) c.Records = %v\n", pp, c.Records)

	return c // for chaining
}
