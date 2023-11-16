package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

const live_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder"
const rc_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder&tag=production%2drc"
const dev_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder&tag=dev"

func getLock() bool {
	_, err := os.Stat("datamine.lock")
	if os.IsNotExist(err) {
		os.Create("datamine.lock")
		return false
	}

	if err != nil {
		fmt.Println(err)
	}

	return true
}

func deleteLock() {
	err := os.Remove("datamine.lock")
	if err != nil {
		fmt.Println(err)
	}
}

func postToWebhook(templatedString string) {
	webhook := os.Getenv("WEBHOOK")

	reqBody, _ := json.Marshal(map[string]string{
		"content": templatedString,
	})

	_, err := http.Post(webhook, "application/json", bytes.NewBuffer(reqBody))

	if err != nil {
		fmt.Println(err)
	}
}

func getServerVersion(url string) string {
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println(err)
	}

	resBody, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err)
	}

	return string(resBody)
}

func getFileVersion(file string, serverVersion string) string {
	stat, err := os.Stat(file)
	if err != nil {
		fmt.Println(err)
	}

	if os.IsNotExist(err) {
		fmt.Println("version file not found", stat)
		os.WriteFile(file, []byte(serverVersion), 0660)
	}
	fileVersion, readErr := os.ReadFile(file)
	if readErr != nil {
		fmt.Println(readErr)
	}

	return string(fileVersion)
}

func updateType(fileVersion string, serverVersion string) string {
	oldMajorVer := strings.Split(string(fileVersion), ".")[1]
	oldMinorVer := strings.Split(string(fileVersion), ".")[2]
	oldPatchVer := strings.Split(string(fileVersion), ".")[3]

	newMajorVer := strings.Split(serverVersion, ".")[1]
	newMinorVer := strings.Split(serverVersion, ".")[2]
	newPatchVer := strings.Split(serverVersion, ".")[3]

	if newMinorVer != oldMinorVer || newMajorVer != oldMajorVer {
		return "Major"
	}

	if newPatchVer != oldPatchVer {
		return "Patch"
	}

	return "None"
}

func parse(serverVersion string, fileVersion string, update string, file string, serverType string) {
	if serverVersion != fileVersion {
		postToWebhook(fmt.Sprintf("Starting datamine for update: %s on %s", serverVersion, serverType))

		cmd, err := exec.Command("/app/start.sh", strings.ToLower(serverType)).Output()
		if err != nil {
			fmt.Printf("error %s", err)
		}
		output := string(cmd)
		fmt.Println(output)

		var template string
		if update == "Major" {
			template = fmt.Sprintf("New %s update: %s on %s\n@here", update, serverVersion, serverType)
		} else {
			template = fmt.Sprintf("New %s update: %s on %s", update, serverVersion, serverType)
		}

		postToWebhook(template)

		fmt.Printf("%s version: %s -> %s\n", serverType, fileVersion, serverVersion)
		os.WriteFile(file, []byte(serverVersion), 0660)
	}
}

func main() {
	const live_file, rc_file, dev_file = "version-live.txt", "version-rc.txt", "version-dev.txt"

	var LiveServerVersion, RCServerVersion, DevServerVersion = getServerVersion(live_url), getServerVersion(rc_url), getServerVersion(dev_url)
	var LiveFileVersion, RCFileVersion, DevFileVersion = getFileVersion(live_file, LiveServerVersion), getFileVersion(rc_file, RCServerVersion), getFileVersion(dev_file, DevServerVersion)
	var LiveUpdate, RCUpdate, DevUpdate = updateType(LiveFileVersion, LiveServerVersion), updateType(RCFileVersion, RCServerVersion), updateType(DevFileVersion, DevServerVersion)

	if !getLock() {
		parse(LiveServerVersion, LiveFileVersion, LiveUpdate, live_file, "Live")
		parse(RCServerVersion, RCFileVersion, RCUpdate, rc_file, "RC")
		parse(DevServerVersion, DevFileVersion, DevUpdate, dev_file, "Dev")
		deleteLock()
	} else {
		fmt.Println("lock file found, not starting datamine")
	}

}
