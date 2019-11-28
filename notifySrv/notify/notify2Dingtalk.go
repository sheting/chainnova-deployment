/*
 * filename    : notifyDingtalk.go
 * author      : wangchunyu
 * description : implement of dingtalk notify operation 
 */
package notify

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"strconv"
	//"time"
	"github.com/chainnova/ci/notifySrv/public"
)

/******************************************************************
 * Function    : NotifyTextProcess
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       : 
 *               stBodyInfo, information of http request body
 * Output      : 
 *               pstNotifyText, a pointer to Notify message of text type
 * Return      : none 
 ******************************************************************
 * Description : switch http request body struct to dingtalk notify 
 *               message struct of text type
 ******************************************************************/
func NotifyTextProcess(stBodyInfo public.BodyInfo, pstNotifyText *public.NotifyText) {

	(*pstNotifyText).Msgtype = "text"
	if stBodyInfo.ObjectAttributes.Status == "success" {
		(*pstNotifyText).Text.Content += "恭喜你CI成功了!" + "\n"
	} else {
		(*pstNotifyText).Text.Content += stBodyInfo.User.Name + "的CI失败了!" + "\n"
	}

	fmt.Println("Username : ", stBodyInfo.User.Username)
	fmt.Println("mobile : ", public.MapUsername2Mobile[stBodyInfo.User.Username])
	(*pstNotifyText).At.AtMobiles = append((*pstNotifyText).At.AtMobiles,  public.MapUsername2Mobile[stBodyInfo.User.Username])
	fmt.Println("mobile : ", (*pstNotifyText).At.AtMobiles)

	fmt.Println("ref : ", stBodyInfo.ObjectAttributes.Ref)
	fmt.Println("env : ", public.MapRxQueue[stBodyInfo.ObjectAttributes.ID])
	/* notify to all if master branch */
	if stBodyInfo.ObjectAttributes.Ref == "master" && (public.MapRxQueue[stBodyInfo.ObjectAttributes.ID] == "NEBULAE-DEV-A" || public.MapRxQueue[stBodyInfo.ObjectAttributes.ID] == "") {
			(*pstNotifyText).At.IsAtAll = "true"
	} else {
		/* notify to all if pipeline failed */
		if stBodyInfo.ObjectAttributes.Status == "success" {
			(*pstNotifyText).At.IsAtAll = "false"
		} else {
			(*pstNotifyText).At.IsAtAll = "true"
		}
	}

	fmt.Println("+++++++++NotifyTextProcess++++++++++++++++")
	fmt.Println(*pstNotifyText)
	fmt.Println("++++++++++++++++++++++++++++++++++++++++")
} 

/******************************************************************
 * Function    : NotifyMdProcess
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       : 
 *               stBodyInfo, information of http request body
 * Output      : 
 *               pstNotifyMd, a pointer to Notify message of markdown type 
 * Return      : none
 ******************************************************************
 * Description : switch http request body struct to dingtalk notify 
 *               message struct of markdown type 
 ******************************************************************/
func NotifyMdProcess(stBodyInfo public.BodyInfo, pstNotifyMd *public.NotifyMd) {

	(*pstNotifyMd).Msgtype = "markdown"
	(*pstNotifyMd).Markdown.Title = strconv.Itoa(stBodyInfo.ObjectAttributes.ID) 
	if stBodyInfo.ObjectAttributes.Status == "success" {
		(*pstNotifyMd).Markdown.Text += "## **<font color=#227700 size=24>恭喜CI成功了!</font>**\n >"
	} else {
		(*pstNotifyMd).Markdown.Text += "## **<font color=#FF0000 size=24>很遗憾, CI失败了!</font>**\n >"
	}
	(*pstNotifyMd).Markdown.Text += "**#" + strconv.Itoa(stBodyInfo.ObjectAttributes.ID)
	if public.MapRxQueue[stBodyInfo.ObjectAttributes.ID] != "" {
		(*pstNotifyMd).Markdown.Text += "    " + public.MapRxQueue[stBodyInfo.ObjectAttributes.ID]

		/* delete the map member */
		public.DeleteMapRxQueueById(stBodyInfo.ObjectAttributes.ID)
	}
	(*pstNotifyMd).Markdown.Text += "**\n\n >"
	(*pstNotifyMd).Markdown.Text += "Project: " + "**" + stBodyInfo.Project.Name + "** \n\n >"
	(*pstNotifyMd).Markdown.Text += "Branch: " + "**" + stBodyInfo.ObjectAttributes.Ref + "**\n\n >"
	(*pstNotifyMd).Markdown.Text += "CreatedAt: " + stBodyInfo.ObjectAttributes.CreatedAt + "\n\n >"
	(*pstNotifyMd).Markdown.Text += "FinishedAt: " + stBodyInfo.ObjectAttributes.FinishedAt + "\n\n >"
	(*pstNotifyMd).Markdown.Text += "Duration : " + strconv.Itoa(stBodyInfo.ObjectAttributes.Duration) + " seconds" + "\n\n >"
	(*pstNotifyMd).Markdown.Text += "Name : " + "**" + stBodyInfo.User.Name + "** \n\n >"
	(*pstNotifyMd).Markdown.Text += "Commit : " + "**" + stBodyInfo.Commit.Message + "** \n\n >"

	if stBodyInfo.ObjectAttributes.Status == "success" {
		(*pstNotifyMd).Markdown.Text += "![screenshot](https://picsum.photos/300/150?image=1058)\n\n >"
	} else {
		(*pstNotifyMd).Markdown.Text += "![screenshot](https://picsum.photos/300/150?image=1072)\n\n >"
	}
	(*pstNotifyMd).Markdown.Text += "Triggered by " + "**" + stBodyInfo.ObjectKind + "**,"
	(*pstNotifyMd).Markdown.Text += "**<font size=20>[Link to Gitlab]" + "(" +
									stBodyInfo.Project.WebURL + "/" + "pipelines" + "/" + 
									strconv.Itoa(stBodyInfo.ObjectAttributes.ID) + ")" +"</font>** \n\n"

	fmt.Println("+++++++++NotifyMdProcess++++++++++++++++")
	fmt.Println(*pstNotifyMd)
	fmt.Println("++++++++++++++++++++++++++++++++++++++++")
} 

/******************************************************************
 * Function    : Notify2Dingtalk
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       : 
 *               strSite, string of dingtalk webhook url
 *               strTextContent, string of dingtalk request message
 * Output      : none
 * Return      : none
 ******************************************************************
 * Description : send request message to dingtalk webhook
 *               
 ******************************************************************/
func Notify2Dingtalk(strSite string, strTextContent string) {

	fmt.Println("###### site")
	fmt.Println(strSite)
	fmt.Println("###### text_content")
	fmt.Println(strTextContent)

    client := &http.Client{}
    req, err := http.NewRequest("POST", strSite, strings.NewReader(strTextContent))
    if err != nil {
        fmt.Println("error 1")
        return
    }

    req.Header.Set("Content-Type", "application/json; charset=utf-8")
	resp, err := client.Do(req)
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        fmt.Println("error 2")
        return
    }

    fmt.Println("repone:",body)
	/* for compile check */
	body = body
}

