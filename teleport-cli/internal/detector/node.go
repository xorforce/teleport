package detector

import (
	"encoding/json"
	"os/exec"
	"strings"
)

// NodePackageInfo contains information about a Node package
type NodePackageInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

// NodePackagesInfo contains packages from all Node package managers
type NodePackagesInfo struct {
	NPM  []NodePackageInfo `json:"npm,omitempty"`
	Bun  []NodePackageInfo `json:"bun,omitempty"`
	PNPM []NodePackageInfo `json:"pnpm,omitempty"`
	Yarn []NodePackageInfo `json:"yarn,omitempty"`
}

// DetectNodePackages detects packages from npm, bun, pnpm, and yarn
func DetectNodePackages() (*NodePackagesInfo, error) {
	info := &NodePackagesInfo{}

	// Detect npm packages
	if npmPackages, err := detectNPM(); err == nil {
		info.NPM = npmPackages
	}

	// Detect bun packages
	if bunPackages, err := detectBun(); err == nil {
		info.Bun = bunPackages
	}

	// Detect pnpm packages
	if pnpmPackages, err := detectPNPM(); err == nil {
		info.PNPM = pnpmPackages
	}

	// Detect yarn packages
	if yarnPackages, err := detectYarn(); err == nil {
		info.Yarn = yarnPackages
	}

	return info, nil
}

// detectNPM detects globally installed npm packages
func detectNPM() ([]NodePackageInfo, error) {
	if _, err := exec.LookPath("npm"); err != nil {
		// npm not installed, return empty slice (not an error)
		return nil, nil //nolint:nilerr // Not finding npm is expected
	}

	cmd := exec.Command("npm", "list", "-g", "--depth=0", "--json")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var result struct {
		Dependencies map[string]struct {
			Version string `json:"version"`
		} `json:"dependencies"`
	}

	if err := json.Unmarshal(output, &result); err != nil {
		return nil, err
	}

	packages := make([]NodePackageInfo, 0, len(result.Dependencies))
	for name, pkg := range result.Dependencies {
		packages = append(packages, NodePackageInfo{
			Name:    name,
			Version: pkg.Version,
		})
	}

	return packages, nil
}

// detectBun detects globally installed bun packages
func detectBun() ([]NodePackageInfo, error) {
	if _, err := exec.LookPath("bun"); err != nil {
		// bun not installed, return empty slice (not an error)
		return nil, nil //nolint:nilerr // Not finding bun is expected
	}

	cmd := exec.Command("bun", "pm", "ls", "-g")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	// Parse bun output (format: package@version)
	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	packages := make([]NodePackageInfo, 0, len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		// Parse "package@version" format
		parts := strings.Split(line, "@")
		if len(parts) == 2 {
			packages = append(packages, NodePackageInfo{
				Name:    parts[0],
				Version: parts[1],
			})
		}
	}

	return packages, nil
}

// detectPNPM detects globally installed pnpm packages
func detectPNPM() ([]NodePackageInfo, error) {
	if _, err := exec.LookPath("pnpm"); err != nil {
		// pnpm not installed, return empty slice (not an error)
		return nil, nil //nolint:nilerr // Not finding pnpm is expected
	}

	cmd := exec.Command("pnpm", "list", "-g", "--depth=0", "--json")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var result []struct {
		Name    string `json:"name"`
		Version string `json:"version"`
	}

	if err := json.Unmarshal(output, &result); err != nil {
		return nil, err
	}

	packages := make([]NodePackageInfo, 0, len(result))
	for _, pkg := range result {
		packages = append(packages, NodePackageInfo{
			Name:    pkg.Name,
			Version: pkg.Version,
		})
	}

	return packages, nil
}

// detectYarn detects globally installed yarn packages
func detectYarn() ([]NodePackageInfo, error) {
	if _, err := exec.LookPath("yarn"); err != nil {
		// yarn not installed, return empty slice (not an error)
		return nil, nil //nolint:nilerr // Not finding yarn is expected
	}

	cmd := exec.Command("yarn", "global", "list", "--json")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	// Yarn outputs JSON lines, parse each line
	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	packages := make([]NodePackageInfo, 0, len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		var entry struct {
			Type string `json:"type"`
			Data struct {
				Name    string `json:"name"`
				Version string `json:"version"`
			} `json:"data"`
		}

		if err := json.Unmarshal([]byte(line), &entry); err != nil {
			continue
		}

		if entry.Type == "tree" && entry.Data.Name != "" {
			packages = append(packages, NodePackageInfo{
				Name:    entry.Data.Name,
				Version: entry.Data.Version,
			})
		}
	}

	return packages, nil
}
