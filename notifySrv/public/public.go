/*
 * filename    : public.go
 * author      : wangchunyu
 * description : global variables define, global variables init functions
 *               and struct define which will be used public
 */
package public

import (
	"time"
)


/* map username to mobile number, which will be used for dingtalk */
var MapUsername2Mobile map[string]string = make(map[string]string)

/* map username to mobile number, which will be used for dingtalk */
var MapRxQueue map[int]string = make(map[int]string)

/* list of cluster env exist */
var ArrEnvList = []string{"NEBULAE-DEV-A", "cabinet-dev-a", "cabinet-dev-b", "cabinet-dev-c", "cabinet-dev-d", "cabinet-dev-e", "cabinet-dev-f", "cabinet-dev-g", "cabinet-dev-h", "cabinet-dev-i"}

type NotifyText struct {
	Msgtype string `json:"msgtype"`
	Text  struct {
		Content string `json:"content"`
	}`json:"text"`

	At struct {
		AtMobiles []string `json:"atMobiles"`
		IsAtAll string `json:"isAtAll"`
	} `json:"at"`
}

type NotifyMd struct {
	Msgtype  string `json:"msgtype"`
	Markdown struct {
		Title string `json:"title"`
		Text  string `json:"text"`
	} `json:"markdown"`
}

type EnvInfo struct {
	Msgtype string `json:"msgtype"`
	Text    struct {
		Content struct {
			Cluster string `json:"cluster"`
			PipeLineID int `json:"pipelineid"`
		} `json:"content"`
	} `json:"text"`
	At struct {
		AtMobiles []string `json:"atMobiles"`
		IsAtAll   string   `json:"isAtAll"`
	} `json:"at"`
}

type BodyInfo struct {
	ObjectKind       string `json:"object_kind"`
	ObjectAttributes struct {
		ID             int      `json:"id"`
		Ref            string   `json:"ref"`
		Tag            bool     `json:"tag"`
		Sha            string   `json:"sha"`
		BeforeSha      string   `json:"before_sha"`
		Status         string   `json:"status"`
		DetailedStatus string   `json:"detailed_status"`
		Stages         []string `json:"stages"`
		CreatedAt      string   `json:"created_at"`
		FinishedAt     string   `json:"finished_at"`
		Duration       int      `json:"duration"`
	} `json:"object_attributes"`
	User struct {
		Name      string `json:"name"`
		Username  string `json:"username"`
		AvatarURL string `json:"avatar_url"`
	} `json:"user"`
	Project struct {
		ID                int         `json:"id"`
		Name              string      `json:"name"`
		Description       string      `json:"description"`
		WebURL            string      `json:"web_url"`
		AvatarURL         interface{} `json:"avatar_url"`
		GitSSHURL         string      `json:"git_ssh_url"`
		GitHTTPURL        string      `json:"git_http_url"`
		Namespace         string      `json:"namespace"`
		VisibilityLevel   int         `json:"visibility_level"`
		PathWithNamespace string      `json:"path_with_namespace"`
		DefaultBranch     string      `json:"default_branch"`
		CiConfigPath      interface{} `json:"ci_config_path"`
	} `json:"project"`
	Commit struct {
		ID        string    `json:"id"`
		Message   string    `json:"message"`
		Timestamp time.Time `json:"timestamp"`
		URL       string    `json:"url"`
		Author    struct {
			Name  string `json:"name"`
			Email string `json:"email"`
		} `json:"author"`
	} `json:"commit"`
	Builds []struct {
		ID         int    `json:"id"`
		Stage      string `json:"stage"`
		Name       string `json:"name"`
		Status     string `json:"status"`
		CreatedAt  string `json:"created_at"`
		StartedAt  string `json:"started_at"`
		FinishedAt string `json:"finished_at"`
		When       string `json:"when"`
		Manual     bool   `json:"manual"`
		User       struct {
			Name      string `json:"name"`
			Username  string `json:"username"`
			AvatarURL string `json:"avatar_url"`
		} `json:"user"`
		Runner struct {
			ID          int    `json:"id"`
			Description string `json:"description"`
			Active      bool   `json:"active"`
			IsShared    bool   `json:"is_shared"`
		} `json:"runner"`
		ArtifactsFile struct {
			Filename interface{} `json:"filename"`
			Size     int         `json:"size"`
		} `json:"artifacts_file"`
	} `json:"builds"`
}

/******************************************************************
 * Function    : Username2Mobile_Init
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       : none
 * Output      : none
 * Return      : none
 ******************************************************************
 * Description : initization the global map of username to mobile
 *              
 ******************************************************************/
func Username2Mobile_Init() {
	MapUsername2Mobile["guce"]        = "15910536109"
	MapUsername2Mobile["wangchunyu"]  = "13718586773"
	MapUsername2Mobile["lisa"]        = "13671257620"
	MapUsername2Mobile["shixianfeng"] = "13520417800"
	MapUsername2Mobile["fanxiaolei"]  = "15901240246"
	MapUsername2Mobile["shichao"]     = "15195986975"
	MapUsername2Mobile["lixiaoling"]  = "13261904513"
	MapUsername2Mobile["hujian"]      = "18331588958"
	MapUsername2Mobile["xuting"]      = "15811297014"

	return
}
/******************************************************************
 * Function    : DeleteMapRxQueueById
 * Author      : wangchunyu
 * Date        : 2018.09.13
 * Input       : none
 * Output      : none
 * Return      : none
 ******************************************************************
 * Description : delete RxQueue map member which is useless
 *              
 ******************************************************************/
func DeleteMapRxQueueById(id int) {
	delete(MapRxQueue, id)
	return
}
/******************************************************************
 * Function    : ReQueue_Init
 * Author      : wangchunyu
 * Date        : 2018.09.11
 * Input       : none
 * Output      : none
 ******************************************************************
 * Description : initization the global map of username to mobile
 *              
 ******************************************************************/
//func RxQueue_Init() {
//	return
//}








