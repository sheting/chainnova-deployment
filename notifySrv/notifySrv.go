package main

import (
    "fmt"
	"net/http"
	"log"
	"io/ioutil"
    "encoding/json"
	//"os"
	"github.com/chainnova/ci/notifySrv/public"
	"github.com/chainnova/ci/notifySrv/notify"
	"github.com/chainnova/ci/notifySrv/config"
)

func main() {
	/* call function to init map */
	public.Username2Mobile_Init()

    http.HandleFunc("/notify", myHandler)
    log.Fatal(http.ListenAndServe(":30222", nil))
}

func myHandler(w http.ResponseWriter, r *http.Request) {

    /*
    fileName := "ll.log"
    logFile,err  := os.Create(fileName)
    defer logFile.Close()
    if err != nil {
		log.Fatalln("open file error !")
    }
    */

    vars := r.URL.Query();
    notifyEnv := vars.Get("dingtalk")
    if notifyEnv == "" {
      fmt.Printf("param dingtalk does not exist\n");
      return
    } else {
      fmt.Printf("param dingtalk value is [%s]\n", notifyEnv);
    }

    body, err := ioutil.ReadAll(r.Body)
    if err != nil {
        fmt.Println("Read Body of Request failed!")
        return
    }
    fmt.Fprintf(w, "%s", "success!\n")
    fmt.Println("#######################################################")
    fmt.Println("          New Message          ")
    fmt.Println("#######################################################")

    fmt.Println("****************body    **********************")
    fmt.Println(string(body))
    fmt.Println("**********************************************")

    /* Check if is env message */
    var stEnvInfo public.EnvInfo
    json.Unmarshal(body, &stEnvInfo)

    fmt.Println("****************EnvInfo**********************")
    fmt.Println(stEnvInfo)
    fmt.Println("**********************************************")

    /* Save Cluster Env info if right message and return */
    if(IsEnvInfoCheck(stEnvInfo)) {
        public.MapRxQueue[stEnvInfo.Text.Content.PipeLineID] = stEnvInfo.Text.Content.Cluster
        fmt.Println("id : ", stEnvInfo.Text.Content.PipeLineID, "env : ", public.MapRxQueue[stEnvInfo.Text.Content.PipeLineID])
        return
    }

	var stBodyInfo public.BodyInfo
	json.Unmarshal(body, &stBodyInfo)

	fmt.Println("****************BodyInfo**********************")
	fmt.Println(stBodyInfo)
	fmt.Println("**********************************************")

	/* Check if message is needed*/
	if(!BodyInfoCheck(stBodyInfo)) {
		fmt.Println("Status : ", stBodyInfo.ObjectAttributes.Status)
		return
	}

	/* Notify Information Process*/
	var stNotifyText public.NotifyText
	notify.NotifyTextProcess(stBodyInfo, &stNotifyText)

	fmt.Println("*****************NotifyText*******************")
	fmt.Println(stNotifyText)
	fmt.Println("**********************************************")

	textJsonBytes, err := json.Marshal(stNotifyText)
	if err != nil {
		fmt.Println("struct to json failed!")
		return
	}

	fmt.Println("**********************************************")
	fmt.Println(string(textJsonBytes))
	fmt.Println("**********************************************")

	var stNotifyMd public.NotifyMd
	notify.NotifyMdProcess(stBodyInfo, &stNotifyMd)

	fmt.Println("*****************NotifyMd*******************")
	fmt.Println(stNotifyMd)
	fmt.Println("**********************************************")

	mdJsonBytes, err := json.Marshal(stNotifyMd)
	if err != nil {
		fmt.Println("struct to json failed!")
		return
	}

	fmt.Println("**********************************************")
	fmt.Println(string(mdJsonBytes))
	fmt.Println("**********************************************")

    notify.Notify2Dingtalk(config.ConfigRead(notifyEnv) , string(textJsonBytes))
    notify.Notify2Dingtalk(config.ConfigRead(notifyEnv) , string(mdJsonBytes))
}

/******************************************************************
 * Function    : BodyInfoCheck
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       :
 *               stBodyInfo, information of http request body
 * Output      : 
 *               none
 * Return      : true , if status is success or failed
 *               false, other wise
 ******************************************************************
 * Description : check the status of ci pipeline, pending and running
 *               are not needed
 ******************************************************************/
func BodyInfoCheck(stBodyInfo public.BodyInfo) bool {
	var bRet bool = true

	fmt.Println("#BodyInfoCheck# Status :", stBodyInfo.ObjectAttributes.Status)
	if "pending" ==  stBodyInfo.ObjectAttributes.Status || 
       "running" ==  stBodyInfo.ObjectAttributes.Status ||
       "" == stBodyInfo.ObjectAttributes.Status {
		fmt.Println("Status :", stBodyInfo.ObjectAttributes.Status)
		bRet = false
	}

	return bRet
}

/******************************************************************
 * Function    : IsEnvInfoCheck
 * Author      : wangchunyu
 * Date        : 2018.09.13
 * Input       :
 *               stEnvInfo, information of http request body
 * Output      : 
 *               none
 * Return      : true , if message is about cluster env
 *               false, other wise
 ******************************************************************
 * Description : check if the message is about cluster env
 *               
 ******************************************************************/
func IsEnvInfoCheck(stEnvInfo public.EnvInfo) bool {

    if stEnvInfo.Text.Content.Cluster == "" {
        return false
    }

    /*  don't check env
    var bIsEnvExist bool = false
    for i, strCluster := range public.ArrEnvList  {
        fmt.Println(i, " : ", strCluster)
      
        if stEnvInfo.Text.Content.Cluster == strCluster {
            bIsEnvExist = true
        }
    }
    */

    if stEnvInfo.Msgtype == "text" {
        return true
    }

    return false
}



