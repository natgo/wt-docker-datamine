package main

import (
	"fmt"
	"io"
	"regexp"
	"strings"
	"time"

	"github.com/anacrolix/torrent"
	"github.com/anacrolix/torrent/metainfo"
)

func checkFileComplete(file *torrent.File) bool {
	return file.BytesCompleted() == file.Length()
}

func downloadTorrent(body io.Reader) (torrentDir *string, err error) {
	startTime := time.Now()

	// Load the .torrent file
	torrentMeta, err := metainfo.Load(body)
	if err != nil {
		return nil, err
	}

	// Create a new Torrent client
	client, err := torrent.NewClient(nil)
	if err != nil {
		return nil, err
	}

	// Add the torrent to the client
	torrent, err := client.AddTorrent(torrentMeta)
	if err != nil {
		return nil, err
	}

	// Get information about the files in the torrent
	files := torrent.Files()
	fpath := strings.Split(files[0].Path(), "/")[0]
	regex := regexp.MustCompile(fmt.Sprintf("(?i)%s/(ui/)?[^(fs)][a-z]+.vromfs.bin", fpath))
	fmt.Println(regex)

	// Download specific files
	for _, file := range files {
		if regex.MatchString(file.Path()) {
			file.Download()
		}
	}

	// Wait for specific files to finish downloading
	for {
		allComplete := true
		for _, file := range files {
			if regex.MatchString(file.Path()) && !checkFileComplete(file) {
				allComplete = false
				break
			}
		}
		if allComplete {
			break
		}
		time.Sleep(time.Second)
	}

	// Close the client
	client.Close()

	fmt.Printf("Download complete! %fs elapsed\n", time.Since(startTime).Seconds())

	return &fpath, err
}
