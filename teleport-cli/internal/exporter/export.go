package exporter

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/teleport/teleport-cli/internal/detector"
	"github.com/teleport/teleport-cli/internal/manifest"
)

// ExportArchive creates a .teleport archive with all detected items
func ExportArchive(outputPath string, progress func(float64, string)) error {
	// Create archive directory
	if err := os.MkdirAll(outputPath, 0755); err != nil {
		return fmt.Errorf("failed to create archive directory: %w", err)
	}

	progress(0.1, "Creating manifest...")
	m := manifest.NewManifest()

	// Detect Homebrew
	progress(0.2, "Detecting Homebrew packages...")
	if homebrew, err := detector.DetectHomebrew(); err == nil && homebrew.Installed {
		m.Homebrew = &manifest.Homebrew{
			Brewfile: homebrew.Brewfile,
			Packages: homebrew.Packages,
		}

		// Save Brewfile
		if homebrew.Brewfile != "" {
			brewfilePath := filepath.Join(outputPath, "homebrew", "Brewfile")
			os.MkdirAll(filepath.Dir(brewfilePath), 0755)
			os.WriteFile(brewfilePath, []byte(homebrew.Brewfile), 0644)
		}
	}

	// Detect Node packages
	progress(0.4, "Detecting Node package managers...")
	if nodePackages, err := detector.DetectNodePackages(); err == nil {
		m.NodePackages = &manifest.NodePackages{}

		if len(nodePackages.NPM) > 0 {
			m.NodePackages.NPM = convertNodePackages(nodePackages.NPM)
			saveNodePackages(outputPath, "npm", nodePackages.NPM)
		}
		if len(nodePackages.Bun) > 0 {
			m.NodePackages.Bun = convertNodePackages(nodePackages.Bun)
			saveNodePackages(outputPath, "bun", nodePackages.Bun)
		}
		if len(nodePackages.PNPM) > 0 {
			m.NodePackages.PNPM = convertNodePackages(nodePackages.PNPM)
			saveNodePackages(outputPath, "pnpm", nodePackages.PNPM)
		}
		if len(nodePackages.Yarn) > 0 {
			m.NodePackages.Yarn = convertNodePackages(nodePackages.Yarn)
			saveNodePackages(outputPath, "yarn", nodePackages.Yarn)
		}
	}

	// Detect Mise
	progress(0.6, "Detecting Mise tools...")
	if mise, err := detector.DetectMise(); err == nil && mise.Installed {
		m.Mise = &manifest.Mise{
			ToolVersions: mise.ToolVersions,
			Tools:        mise.Tools,
		}

		// Copy config file if it exists
		if mise.ConfigFile != "" {
			if content, err := os.ReadFile(mise.ConfigFile); err == nil {
				misePath := filepath.Join(outputPath, "mise", "config.toml")
				os.MkdirAll(filepath.Dir(misePath), 0755)
				os.WriteFile(misePath, content, 0644)
			}
		}

		// Copy .tool-versions if it exists
		if mise.ToolVersions != "" {
			if content, err := os.ReadFile(mise.ToolVersions); err == nil {
				toolVersionsPath := filepath.Join(outputPath, "mise", ".tool-versions")
				os.MkdirAll(filepath.Dir(toolVersionsPath), 0755)
				os.WriteFile(toolVersionsPath, content, 0644)
			}
		}
	}

	// Save manifest
	progress(0.9, "Saving manifest...")
	manifestData, err := m.ToJSON()
	if err != nil {
		return fmt.Errorf("failed to encode manifest: %w", err)
	}

	manifestPath := filepath.Join(outputPath, "manifest.json")
	if err := os.WriteFile(manifestPath, manifestData, 0644); err != nil {
		return fmt.Errorf("failed to write manifest: %w", err)
	}

	progress(1.0, "Export complete!")
	return nil
}

func convertNodePackages(packages []detector.NodePackageInfo) []manifest.PackageInfo {
	result := make([]manifest.PackageInfo, len(packages))
	for i, pkg := range packages {
		result[i] = manifest.PackageInfo{
			Name:    pkg.Name,
			Version: pkg.Version,
		}
	}
	return result
}

func saveNodePackages(outputPath, manager string, packages []detector.NodePackageInfo) {
	packagePath := filepath.Join(outputPath, manager, "global-packages.json")
	os.MkdirAll(filepath.Dir(packagePath), 0755)
	
	data, err := json.MarshalIndent(packages, "", "  ")
	if err == nil {
		os.WriteFile(packagePath, data, 0644)
	}
}

