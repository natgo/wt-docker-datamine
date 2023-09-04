package main

import (
	"regexp"
	"testing"
)

func TestGetServerVersion(t *testing.T) {
	want := regexp.MustCompile(`^\d\.\d{2}\.\d\.\d{1,3}$`)

	liveVersion := getServerVersion(live_url)

	if !want.MatchString(liveVersion) {
		t.Fatalf(`getServerVersion = %q, %v`, liveVersion, want)
	}
}
