package backend

import (
	// "encoding/json"
	"time"
)

// Generated boilerplate code for MySQL DB consuweb table departments
type departmentsstruct struct {
	Type string `json:"type"`
	// id	int(10) unsigned	NO	PRI	NULL	auto_increment
	id int `json:"id"` // type = int(10) unsigned
	// name	varchar(255)	NO		NULL
	name string `json:"name"` // type = varchar(255)
	// icon_image	varchar(255)	NO
	icon_image string `json:"icon_image"` // type = varchar(255)
	// created_at	timestamp	YES		NULL
	created_at *time.Time `json:"created_at,omitempty"` // type = timestamp
	// updated_at	timestamp	YES		NULL
	updated_at *time.Time `json:"updated_at,omitempty"` // type = timestamp
}

// End of generated boilerplate code for MySQL DB consuweb table departments
