package config

import (
	"encoding/json"
    "fmt"
	"io/ioutil"
)

type ConfigInfo struct {
	Site string
}

var configFileName string = "config/config.json"

func ConfigRead(project string) string {
	
    JsonParse := NewJsonStruct()
    value := make(map[string]string)
    JsonParse.ReadFile(configFileName, &value)
    fmt.Printf("config:%+v",value)

	return value[project]
}


type JsonStruct struct {
}

func NewJsonStruct() *JsonStruct {
    return &JsonStruct{}
}

func (jst *JsonStruct) ReadFile(filename string, v interface{}) {

	/* read the file's whole content, and return as []byte */
    data, err := ioutil.ReadFile(filename)
    if err != nil {
        return
    }

	/* decode json */
    err = json.Unmarshal(data, v)
    if err != nil {
        return
    }
}
