package main

import (
	"io"
	"os"
	"path/filepath"
	"strings"
)

func copyFiles(srcDir, destDir string) error {
	// Create the destination directory if it doesn't exist
	if err := os.MkdirAll(destDir, os.ModePerm); err != nil {
		return err
	}

	// Walk through the source directory
	err := filepath.WalkDir(srcDir, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Skip directories
		if entry.IsDir() {
			return nil
		}

		if !strings.HasSuffix(entry.Name(), ".vromfs.bin") {
			return nil
		}

		// Open the source file
		srcFile, err := os.Open(path)
		if err != nil {
			return err
		}
		defer srcFile.Close()

		// Create the destination file
		destFile, err := os.Create(filepath.Join(destDir, entry.Name()))
		if err != nil {
			return err
		}
		defer destFile.Close()

		// Copy the contents of the source file to the destination file
		_, err = io.Copy(destFile, srcFile)
		if err != nil {
			return err
		}

		return nil
	})

	return err
}
