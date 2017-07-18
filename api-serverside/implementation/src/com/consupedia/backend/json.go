package backend

// implementation is as an array of general container objects,
// each of which contains (to begin with) either an error message
// or a product record.

import (
	"encoding/json"
)

type Errorstruct struct {
	Type    string `json:type`
	Message string `json:errormessage`
}

type Containerstruct struct {
	Type     string       `json:type`
	Errorrec *Errorstruct `json:record,omitempty`
}

func Makejson(c []Containerstruct) (jsonbytes []byte, err error) {
	bytes, err := json.MarshalIndent(c, "", "  ")
	jsonbytes = bytes
	return jsonbytes, err
}
