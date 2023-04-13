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
	if os.IsNotExist(err) {
		fmt.Println("version file not found", stat)
		os.WriteFile(file, []byte(serverVersion), 0660)
	}
	fileVersion, err := os.ReadFile(file)
	if err != nil {
		fmt.Println(err)
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

	var updateType string

	if newMinorVer != oldMinorVer || newMajorVer != oldMajorVer {
		updateType = "Major"
	}

	if newPatchVer != oldPatchVer {
		updateType = "Patch"
	}

	return updateType
}

func parse(serverVersion string, fileVersion string, update string, file string, server string) {
	if serverVersion != fileVersion {
		var template string
		if update == "Major" {
			template = fmt.Sprintf("New %s update: %s on %s\n@here", update, serverVersion, server)
		} else {
			template = fmt.Sprintf("New %s update: %s on %s", update, serverVersion, server)
		}
		reqBody, _ := json.Marshal(map[string]string{
			"content": template,
		})

		webhook := os.Getenv("WEBHOOK")

		_, posterr := http.Post(webhook, "application/json", bytes.NewBuffer(reqBody))

		if posterr != nil {
			fmt.Println(posterr)
		}

		cmd, err := exec.Command("/app/start.sh", strings.ToLower(server)).Output()
		if err != nil {
			fmt.Printf("error %s", err)
		}
		output := string(cmd)
		fmt.Println(output)

		fmt.Printf("%s version: %s -> %s\n", server, fileVersion, serverVersion)
	}

	os.WriteFile(file, []byte(serverVersion), 0660)
}

func main() {
	const live_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder"
	const rc_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder&tag=production%2drc"
	const dev_url = "https://yupmaster.gaijinent.com/yuitem/get_version.php?proj=warthunder&tag=dev"
	const live_file, rc_file, dev_file = "version-live.txt", "version-rc.txt", "version-dev.txt"
	fmt.Println(os.Getenv("PWD"))

	var LiveServerVersion, RCServerVersion, DevServerVersion = getServerVersion(live_url), getServerVersion(rc_url), getServerVersion(dev_url)
	var LiveFileVersion, RCFileVersion, DevFileVersion = getFileVersion(live_file, LiveServerVersion), getFileVersion(rc_file, RCServerVersion), getFileVersion(dev_file, DevServerVersion)
	var LiveUpdate, RCUpdate, DevUpdate = updateType(LiveFileVersion, LiveServerVersion), updateType(RCFileVersion, RCServerVersion), updateType(DevFileVersion, DevServerVersion)

	parse(LiveServerVersion, LiveFileVersion, LiveUpdate, live_file, "Live")
	parse(RCServerVersion, RCFileVersion, RCUpdate, rc_file, "RC")
	parse(DevServerVersion, DevFileVersion, DevUpdate, dev_file, "Dev")
}
