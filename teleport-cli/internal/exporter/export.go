package exporter

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/teleport/teleport-cli/internal/detector"
	"github.com/teleport/teleport-cli/internal/manifest"
)

// CategoryOptions specifies which categories to export
type CategoryOptions struct {
	Homebrew bool
	Node     bool
	Mise     bool
}

// ExportArchive creates a .teleport archive with selected categories
func ExportArchive(outputPath string, opts *CategoryOptions, progress func(float64, string)) error {
	// Create archive directory
	if err := os.MkdirAll(outputPath, 0o750); err != nil {
		return fmt.Errorf("failed to create archive directory: %w", err)
	}

	progress(0.1, "Creating manifest...")
	m := manifest.NewManifest()

	// Detect Homebrew
	if opts.Homebrew {
		progress(0.2, "Detecting Homebrew packages...")
		if err := exportHomebrew(outputPath, m); err != nil {
			return err
		}
	}

	// Detect Node packages
	if opts.Node {
		progress(0.4, "Detecting Node package managers...")
		if err := exportNodePackages(outputPath, m); err != nil {
			return err
		}
	}

	// Detect Mise
	if opts.Mise {
		progress(0.6, "Detecting Mise tools...")
		if err := exportMise(outputPath, m); err != nil {
			return err
		}
	}

	// Save manifest
	progress(0.9, "Saving manifest...")
	if err := saveManifest(outputPath, m); err != nil {
		return err
	}

	progress(1.0, "Export complete!")
	return nil
}

func exportHomebrew(outputPath string, m *manifest.Manifest) error {
	homebrew, err := detector.DetectHomebrew()
	if err != nil {
		return nil //nolint:nilerr // Homebrew detection failure is not fatal
	}

	if !homebrew.Installed {
		return nil
	}

	m.Homebrew = &manifest.Homebrew{
		Brewfile: homebrew.Brewfile,
		Packages: homebrew.Packages,
		Casks:    homebrew.Casks,
	}

	// Save Brewfile
	if homebrew.Brewfile != "" {
		brewfilePath := filepath.Join(outputPath, "homebrew", "Brewfile")
		if err := os.MkdirAll(filepath.Dir(brewfilePath), 0o750); err != nil {
			return fmt.Errorf("failed to create homebrew directory: %w", err)
		}
		if err := os.WriteFile(brewfilePath, []byte(homebrew.Brewfile), 0o600); err != nil {
			return fmt.Errorf("failed to write Brewfile: %w", err)
		}
	}

	return nil
}

func exportNodePackages(outputPath string, m *manifest.Manifest) error {
	nodePackages, err := detector.DetectNodePackages()
	if err != nil {
		return nil //nolint:nilerr // Node detection failure is not fatal
	}

	m.NodePackages = &manifest.NodePackages{}

	if len(nodePackages.NPM) > 0 {
		m.NodePackages.NPM = convertNodePackages(nodePackages.NPM)
		if err := saveNodePackages(outputPath, "npm", nodePackages.NPM); err != nil {
			return err
		}
	}
	if len(nodePackages.Bun) > 0 {
		m.NodePackages.Bun = convertNodePackages(nodePackages.Bun)
		if err := saveNodePackages(outputPath, "bun", nodePackages.Bun); err != nil {
			return err
		}
	}
	if len(nodePackages.PNPM) > 0 {
		m.NodePackages.PNPM = convertNodePackages(nodePackages.PNPM)
		if err := saveNodePackages(outputPath, "pnpm", nodePackages.PNPM); err != nil {
			return err
		}
	}
	if len(nodePackages.Yarn) > 0 {
		m.NodePackages.Yarn = convertNodePackages(nodePackages.Yarn)
		if err := saveNodePackages(outputPath, "yarn", nodePackages.Yarn); err != nil {
			return err
		}
	}

	return nil
}

func exportMise(outputPath string, m *manifest.Manifest) error {
	mise, err := detector.DetectMise()
	if err != nil {
		return nil //nolint:nilerr // Mise detection failure is not fatal
	}

	if !mise.Installed {
		return nil
	}

	m.Mise = &manifest.Mise{
		ToolVersions: mise.ToolVersions,
		Tools:        mise.Tools,
	}

	// Copy config file if it exists
	if mise.ConfigFile != "" {
		content, err := os.ReadFile(mise.ConfigFile) //nolint:gosec // Config file path is from system detection
		if err == nil {
			misePath := filepath.Join(outputPath, "mise", "config.toml")
			if err := os.MkdirAll(filepath.Dir(misePath), 0o750); err != nil {
				return fmt.Errorf("failed to create mise directory: %w", err)
			}
			if err := os.WriteFile(misePath, content, 0o600); err != nil {
				return fmt.Errorf("failed to write mise config: %w", err)
			}
		}
	}

	// Copy .tool-versions if it exists
	if mise.ToolVersions != "" {
		content, err := os.ReadFile(mise.ToolVersions) //nolint:gosec // Tool versions path is from system detection
		if err == nil {
			toolVersionsPath := filepath.Join(outputPath, "mise", ".tool-versions")
			if err := os.MkdirAll(filepath.Dir(toolVersionsPath), 0o750); err != nil {
				return fmt.Errorf("failed to create mise directory: %w", err)
			}
			if err := os.WriteFile(toolVersionsPath, content, 0o600); err != nil {
				return fmt.Errorf("failed to write tool-versions: %w", err)
			}
		}
	}

	return nil
}

func saveManifest(outputPath string, m *manifest.Manifest) error {
	manifestData, err := m.ToJSON()
	if err != nil {
		return fmt.Errorf("failed to encode manifest: %w", err)
	}

	manifestPath := filepath.Join(outputPath, "manifest.json")
	if err := os.WriteFile(manifestPath, manifestData, 0o600); err != nil {
		return fmt.Errorf("failed to write manifest: %w", err)
	}

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

func saveNodePackages(outputPath, manager string, packages []detector.NodePackageInfo) error {
	packagePath := filepath.Join(outputPath, manager, "global-packages.json")
	if err := os.MkdirAll(filepath.Dir(packagePath), 0o750); err != nil {
		return fmt.Errorf("failed to create %s directory: %w", manager, err)
	}

	data, err := json.MarshalIndent(packages, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal %s packages: %w", manager, err)
	}

	if err := os.WriteFile(packagePath, data, 0o600); err != nil {
		return fmt.Errorf("failed to write %s packages: %w", manager, err)
	}

	return nil
}
