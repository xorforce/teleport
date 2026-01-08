package manifest

import (
	"encoding/json"
	"time"
)

// Manifest represents the schema for a teleport archive
type Manifest struct {
	Version      string        `json:"version"`
	CreatedAt    time.Time     `json:"created_at"`
	MacOS        MacOSInfo     `json:"macos"`
	Homebrew     *Homebrew     `json:"homebrew,omitempty"`
	NodePackages *NodePackages `json:"node_packages,omitempty"`
	Mise         *Mise         `json:"mise,omitempty"`
	Dotfiles     []string      `json:"dotfiles,omitempty"`
	MacSettings  *MacSettings  `json:"mac_settings,omitempty"`
	IDE          *IDE          `json:"ide,omitempty"`
	Fonts        []string      `json:"fonts,omitempty"`
	ShellHistory *ShellHistory `json:"shell_history,omitempty"`
}

// MacOSInfo contains information about the source Mac
type MacOSInfo struct {
	Version string `json:"version"`
	Arch    string `json:"arch"`
}

// Homebrew contains Homebrew-related data
type Homebrew struct {
	Brewfile string   `json:"brewfile"`
	Packages []string `json:"packages,omitempty"`
}

// NodePackages contains packages from various Node package managers
type NodePackages struct {
	NPM  []PackageInfo `json:"npm,omitempty"`
	Bun  []PackageInfo `json:"bun,omitempty"`
	PNPM []PackageInfo `json:"pnpm,omitempty"`
	Yarn []PackageInfo `json:"yarn,omitempty"`
}

// PackageInfo represents a package with version
type PackageInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

// Mise contains mise tool versions
type Mise struct {
	ConfigFile   string            `json:"config_file,omitempty"`
	ToolVersions string            `json:"tool_versions,omitempty"`
	Tools        map[string]string `json:"tools,omitempty"`
}

// MacSettings contains macOS system preferences
type MacSettings struct {
	Defaults map[string]interface{} `json:"defaults,omitempty"`
}

// IDE contains IDE configurations
type IDE struct {
	VSCode *VSCodeConfig `json:"vscode,omitempty"`
	Cursor *CursorConfig `json:"cursor,omitempty"`
	Xcode  *XcodeConfig  `json:"xcode,omitempty"`
}

// VSCodeConfig contains VS Code settings
type VSCodeConfig struct {
	Settings    string   `json:"settings,omitempty"`
	Keybindings string   `json:"keybindings,omitempty"`
	Extensions  []string `json:"extensions,omitempty"`
}

// CursorConfig contains Cursor settings (same structure as VS Code)
type CursorConfig struct {
	Settings    string   `json:"settings,omitempty"`
	Keybindings string   `json:"keybindings,omitempty"`
	Extensions  []string `json:"extensions,omitempty"`
}

// XcodeConfig contains Xcode preferences
type XcodeConfig struct {
	UserDataPath string `json:"user_data_path,omitempty"`
}

// ShellHistory contains shell history files
type ShellHistory struct {
	ZshHistory  string `json:"zsh_history,omitempty"`
	BashHistory string `json:"bash_history,omitempty"`
}

// NewManifest creates a new manifest with default values
func NewManifest() *Manifest {
	return &Manifest{
		Version:   "1.0",
		CreatedAt: time.Now(),
		MacOS: MacOSInfo{
			Arch: getArch(),
		},
	}
}

// ToJSON converts the manifest to JSON
func (m *Manifest) ToJSON() ([]byte, error) {
	return json.MarshalIndent(m, "", "  ")
}

// FromJSON parses a manifest from JSON
func FromJSON(data []byte) (*Manifest, error) {
	var m Manifest
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, err
	}
	return &m, nil
}

// getArch returns the system architecture
func getArch() string {
	// This will be properly implemented later
	return "arm64"
}
