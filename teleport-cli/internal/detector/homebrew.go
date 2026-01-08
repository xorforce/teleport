package detector

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// HomebrewInfo contains detected Homebrew information
type HomebrewInfo struct {
	Installed bool
	Path      string
	Brewfile  string
	Packages  []string
}

// DetectHomebrew detects if Homebrew is installed and gathers information
func DetectHomebrew() (*HomebrewInfo, error) {
	info := &HomebrewInfo{}

	// Check if brew command exists
	brewPath, err := exec.LookPath("brew")
	if err != nil {
		// Homebrew not installed, return empty info (not an error)
		return info, nil //nolint:nilerr // Not finding brew is expected, not an error
	}

	info.Installed = true
	info.Path = brewPath

	// Get Homebrew prefix
	prefixCmd := exec.Command("brew", "--prefix")
	prefixOutput, err := prefixCmd.Output()
	if err == nil {
		info.Path = strings.TrimSpace(string(prefixOutput))
	}

	// Generate Brewfile
	brewfileCmd := exec.Command("brew", "bundle", "dump", "--force")
	brewfileOutput, err := brewfileCmd.Output()
	if err == nil {
		info.Brewfile = string(brewfileOutput)
	}

	// List installed packages
	listCmd := exec.Command("brew", "list", "--formula")
	listOutput, err := listCmd.Output()
	if err == nil {
		packages := strings.Split(strings.TrimSpace(string(listOutput)), "\n")
		info.Packages = packages
	}

	return info, nil
}

// GetBrewfilePath returns the default path for Brewfile
func GetBrewfilePath() string {
	homeDir, _ := os.UserHomeDir()
	return filepath.Join(homeDir, "Brewfile")
}
