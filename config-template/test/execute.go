package main

import (
	"bytes"
	"fmt"
	"text/template"
)

type TmplData struct {
	CCImagePrefix string
}

func main() {
	// get template
	tmpl := template.Must(template.ParseFiles("peer0-deployment.yaml"))

	// get data
	data := TmplData{CCImagePrefix: "SERVICE-NAMESPACE"}

	// execute
	var b bytes.Buffer
	err := tmpl.Execute(&b, &data)
	if err == nil {
		str := b.String()
		fmt.Println(str)
	}

	return
}
