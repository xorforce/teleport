package detector

import (
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

// HomebrewInfo contains detected Homebrew information
type HomebrewInfo struct {
	Installed bool
	Path      string
	Brewfile  string
	Packages  []string // Formulae (CLI tools)
	Casks     []string // Casks (GUI applications)
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

	// Generate Brewfile (use --file=- to output to stdout)
	brewfileCmd := exec.Command("brew", "bundle", "dump", "--file=-", "--force")
	brewfileCmd.Env = append(os.Environ(), "HOMEBREW_NO_AUTO_UPDATE=1")
	brewfileOutput, err := brewfileCmd.Output()
	if err == nil {
		info.Brewfile = string(brewfileOutput)
	}

	// List installed formulae
	listCmd := exec.Command("brew", "list", "--formula")
	listCmd.Env = append(os.Environ(), "HOMEBREW_NO_AUTO_UPDATE=1")
	listOutput, err := listCmd.Output()
	if err == nil {
		packages := strings.Split(strings.TrimSpace(string(listOutput)), "\n")
		// Filter empty strings and sort
		info.Packages = filterAndSort(packages)
	}

	// List installed casks
	caskCmd := exec.Command("brew", "list", "--cask")
	caskCmd.Env = append(os.Environ(), "HOMEBREW_NO_AUTO_UPDATE=1")
	caskOutput, err := caskCmd.Output()
	if err == nil {
		casks := strings.Split(strings.TrimSpace(string(caskOutput)), "\n")
		// Filter empty strings and sort
		info.Casks = filterAndSort(casks)
	}

	return info, nil
}

// filterAndSort filters empty strings and sorts the slice
func filterAndSort(items []string) []string {
	var result []string
	for _, item := range items {
		item = strings.TrimSpace(item)
		if item != "" {
			result = append(result, item)
		}
	}
	sort.Strings(result)
	return result
}

// GetBrewfilePath returns the default path for Brewfile
func GetBrewfilePath() string {
	homeDir, _ := os.UserHomeDir()
	return filepath.Join(homeDir, "Brewfile")
}
