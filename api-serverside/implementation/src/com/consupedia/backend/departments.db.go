package backend

import (
	"com/consupedia/backend/sqlhelper"
	// "encoding/json"
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"time"
)

// Generated boilerplate code for MySQL DB consuweb table departments
func Scan_consuweb_departments(rows *sql.Rows) (c departmentsstruct, err error) {
	var consuweb_departments_id int
	var consuweb_departments_name string
	var consuweb_departments_icon_image string
	var consuweb_departments_created_at_Holder interface{} = nil
	var consuweb_departments_created_at *time.Time
	var consuweb_departments_updated_at_Holder interface{} = nil
	var consuweb_departments_updated_at *time.Time

	err = rows.Scan(&consuweb_departments_id, &consuweb_departments_name, &consuweb_departments_icon_image, &consuweb_departments_created_at_Holder, &consuweb_departments_updated_at_Holder)
	if err != nil {
		return c, err
	}

	// special handling for some fields

	consuweb_departments_created_at, err = sqlhelper.Sqltime2Gotime(consuweb_departments_created_at_Holder)

	consuweb_departments_updated_at, err = sqlhelper.Sqltime2Gotime(consuweb_departments_updated_at_Holder)

	// now assemble
	c = departmentsstruct{
		Type: "departments",
		id:   consuweb_departments_id, name: consuweb_departments_name, icon_image: consuweb_departments_icon_image, created_at: consuweb_departments_created_at, updated_at: consuweb_departments_updated_at}

	return c, nil
}
