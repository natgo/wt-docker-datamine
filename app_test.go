package main

import (
	"os"
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

func TestGetLock(t *testing.T) {
	os.Create("datamine.lock")
	lock := getLock()

	if !lock {
		t.Fatalf("lock not detected")
	}
	os.Remove("datamine.lock")

	lock2 := getLock()

	if lock2 {
		t.Fatalf("lock detected without lockfile")
	}

	//tear-down
	os.Remove("datamine.lock")
}

func TestGetFileVersion(t *testing.T) {
	fileversion := getFileVersion("version-live.txt", "2.1.0.34")
	if fileversion != "2.1.0.34" {
		t.Fatalf(`getFileVersion = %q, %v`, fileversion, "2.1.0.34")
	}
	os.Remove("version-live.txt")

	os.WriteFile("version-live.txt", []byte("2.1.0.34"), 0660)
	fileversion2 := getFileVersion("version-live.txt", "2.1.0.34")
	if fileversion2 != "2.1.0.34" {
		t.Fatalf(`getFileVersion = %q, %v`, fileversion2, "2.1.0.34")
	}

	//tear-down
	os.Remove("version-live.txt")
}

func TestUpdateType(t *testing.T) {
	t.Run("No update", func(t *testing.T) {
		update := updateType("2.1.0.34", "2.1.0.34")
		if update != "None" {
			t.Fatalf(`updateType = %q`, update)
		}
	})

	t.Run("Patch update", func(t *testing.T) {
		update := updateType("2.1.0.34", "2.1.0.35")
		if update != "Patch" {
			t.Fatalf(`updateType = %q`, update)
		}
	})

	t.Run("Minor update", func(t *testing.T) {
		update := updateType("2.1.0.34", "2.1.1.1")
		if update != "Major" {
			t.Fatalf(`updateType = %q`, update)
		}
	})

	t.Run("Major update", func(t *testing.T) {
		update := updateType("2.1.0.34", "2.2.0.34")
		if update != "Major" {
			t.Fatalf(`updateType = %q`, update)
		}
	})
}
