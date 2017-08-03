package sqlhelper

import (
	"fmt"
	"strings"
	"time"
)

// Copyright © 2017 Consupedia AB
// Author: Frits Daalmans <frits@consupedia.com>

// Conversion function from date/time values in the returned fields
// of a sql.Rows struct, to the time.Time struct that Golang works with.
// The format turned out to be: either nil, or "almost" ISO 8601
// but with the T replaced by a space and no timezone info at the end.
// TODO: return epoch when input is NULL, now it's something like year 0
// which doesn't exist
// It was maybe a bit silly for me to write this but I couldn't find an
// existing implementation. Frits.
func Sqltime2Gotime(sqltime interface{}) (gotimep *time.Time, err error) {
	var tmptimebytes []byte
	var ttime string
	var gotime time.Time

	if sqltime != nil {
		tmptimebytes = sqltime.([]byte)
		//DBG		fmt.Printf("DBG Sqltime2Gotime parsing: %d %02x %02x \"%s\"\n", len(tmptimebytes), tmptimebytes[0], tmptimebytes[1], string(tmptimebytes))
		// it's like ISO 8601 except the letter T is missing
		ttime = strings.Replace(string(tmptimebytes), " ", "T", 1) + "Z"
		gotime = time.Unix(0, 0)
		err = gotime.UnmarshalText([]byte(ttime))
		if err != nil {
			fmt.Printf("DBG aww time conversion FAILED: %v\n", err)
		}
	} else {
		gotime = time.Unix(0, 0)
	}
	gotimep = &gotime
	return gotimep, err
}
