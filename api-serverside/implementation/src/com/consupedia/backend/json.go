package backend

// implementation is as an array of general container objects,
// each of which contains (to begin with) either an error message
// or a product record.

import (
	"encoding/json"
	"fmt"
	"time"
)

var TYPE_PRODUCT string = "product"
var TYPE_ERROR string = "error"

type Errorstruct struct {
	Type    string `json:"type"`
	Message string `json:"errormessage"`
}

// N.B. this must correspond with the values in db.go
type Productstruct struct {
	Type           string `json:"type"`
	Id             int    `json:"id"`
	Gtin           string `json:"gtin,omitempty"`
	Name           string `json:"name"`
	Fullname       string `json:"fullname,omitempty"`
	Size           int
	SizeunitId     int
	Image          string
	Bulk           int8   // tinyint(1)
	Description    string `json:"description,omitempty"` // text
	CategoryId     int
	BrandId        int
	ManufacturerId int
	CreatedAt      *time.Time
	UpdatedAt      *time.Time
}

type Productstructp *Productstruct

// N.B. all records must have the same JSON record name "record"
// and be distinguished only by different values of "type"
type Containerstruct struct {
	Type       string         `json:"type"`
	Errorrec   *Errorstruct   `json:"error,omitempty"`
	Productrec Productstructp `json:"entity,omitempty"`
}

type Container struct {
	Records []Containerstruct
}

// func Makejson(c []Containerstruct) (jsonbytes []byte, err error) { }
func Makejson(c interface{}) (jsonbytes []byte, err error) {
	bytes, err := json.MarshalIndent(c, "", "  ")
	jsonbytes = bytes
	return jsonbytes, err
}

func NewProductstruct(id int, name string, fullname string) (pp Productstructp) {
	p := Productstruct{Type: TYPE_PRODUCT, Id: id, Name: name, Fullname: fullname}
	pp = &p
	return pp
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
func (c *Container) AddProductRecord(id int, name string, fullname string) *Container {
	var pp Productstructp = NewProductstruct(id, name, fullname)

	// see paragraph "Appending to and copying slices" in golang language ref doc
	c.Records = append(c.Records, Containerstruct{Type: pp.Type, Productrec: pp})

	fmt.Printf("DBG: after AddProductRecord(%v) c.Records = %v\n", pp, c.Records)

	return c // for chaining
}
