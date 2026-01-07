package detector

import (
	"os"
	"path/filepath"
	"strings"
)

// MiseInfo contains detected mise information
type MiseInfo struct {
	Installed    bool
	ConfigFile   string
	ToolVersions string
	Tools        map[string]string
}

// DetectMise detects mise installation and tool versions
func DetectMise() (*MiseInfo, error) {
	info := &MiseInfo{
		Tools: make(map[string]string),
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return info, nil
	}

	// Check for mise config file
	configPath := filepath.Join(homeDir, ".config", "mise", "config.toml")
	if _, err := os.Stat(configPath); err == nil {
		info.Installed = true
		info.ConfigFile = configPath
	}

	// Check for .tool-versions file
	toolVersionsPath := filepath.Join(homeDir, ".tool-versions")
	if _, err := os.Stat(toolVersionsPath); err == nil {
		info.ToolVersions = toolVersionsPath
		// Parse tool versions
		if content, err := os.ReadFile(toolVersionsPath); err == nil {
			parseToolVersions(string(content), info.Tools)
		}
	}

	return info, nil
}

// parseToolVersions parses .tool-versions file content
func parseToolVersions(content string, tools map[string]string) {
	lines := strings.Split(content, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Format: tool version
		parts := strings.Fields(line)
		if len(parts) >= 2 {
			tool := parts[0]
			version := parts[1]
			tools[tool] = version
		}
	}
}

