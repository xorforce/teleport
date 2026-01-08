package cmd

import (
	"fmt"
	"path/filepath"
	"strings"
	"time"

	"github.com/spf13/cobra"
	"github.com/teleport/teleport-cli/internal/exporter"
)

var exportCmd = &cobra.Command{
	Use:   "export",
	Short: "Export your Mac settings and packages",
	Long: `Export all detected settings, packages, dotfiles, and configurations
to a .teleport archive file that can be imported on another Mac.

By default, all available categories are exported. Use flags to select specific
categories or use --only to export only specified categories.

Examples:
  teleport export                          # Export all categories
  teleport export --no-homebrew            # Export all except Homebrew
  teleport export --only homebrew,node     # Export only Homebrew and Node packages
  teleport export --homebrew --node        # Export only Homebrew and Node packages`,
	RunE: runExport,
}

var (
	outputPath string

	// Category flags (include by default)
	includeHomebrew bool
	includeNode     bool
	includeMise     bool

	// Only flag for explicit selection
	onlyCategories string
)

func init() {
	exportCmd.Flags().StringVarP(&outputPath, "output", "o", "", "Output path for the .teleport archive")

	// Category include flags (default true)
	exportCmd.Flags().BoolVar(&includeHomebrew, "homebrew", true, "Include Homebrew packages and casks")
	exportCmd.Flags().BoolVar(&includeNode, "node", true, "Include Node packages (npm, bun, pnpm, yarn)")
	exportCmd.Flags().BoolVar(&includeMise, "mise", true, "Include Mise tool versions")

	// Exclusion flags (shortcuts)
	exportCmd.Flags().Bool("no-homebrew", false, "Exclude Homebrew packages")
	exportCmd.Flags().Bool("no-node", false, "Exclude Node packages")
	exportCmd.Flags().Bool("no-mise", false, "Exclude Mise tools")

	// Only flag for explicit selection
	exportCmd.Flags().StringVar(&onlyCategories, "only", "", "Export only specified categories (comma-separated: homebrew,node,mise)")
}

func runExport(cmd *cobra.Command, args []string) error {
	if outputPath == "" {
		timestamp := time.Now().Format("2006-01-02")
		outputPath = fmt.Sprintf("teleport-export-%s.teleport", timestamp)
	}

	// Ensure output path has .teleport extension
	if filepath.Ext(outputPath) != ".teleport" {
		outputPath += ".teleport"
	}

	// Build category options
	opts := buildCategoryOptions(cmd)

	// Print what will be exported
	fmt.Printf("Exporting to: %s\n", outputPath)
	printSelectedCategories(opts)

	// Use exporter package
	progress := func(percent float64, message string) {
		fmt.Printf("[%.0f%%] %s\n", percent*100, message)
	}

	if err := exporter.ExportArchive(outputPath, opts, progress); err != nil {
		return fmt.Errorf("export failed: %w", err)
	}

	fmt.Println("Export complete!")
	return nil
}

func buildCategoryOptions(cmd *cobra.Command) *exporter.CategoryOptions {
	opts := &exporter.CategoryOptions{
		Homebrew: true,
		Node:     true,
		Mise:     true,
	}

	// Handle --only flag (explicit selection)
	if onlyCategories != "" {
		// Start with all false
		opts.Homebrew = false
		opts.Node = false
		opts.Mise = false

		// Enable only specified categories
		categories := strings.Split(strings.ToLower(onlyCategories), ",")
		for _, cat := range categories {
			cat = strings.TrimSpace(cat)
			switch cat {
			case "homebrew", "brew":
				opts.Homebrew = true
			case "node", "npm":
				opts.Node = true
			case "mise":
				opts.Mise = true
			}
		}
		return opts
	}

	// Handle exclusion flags
	if noHomebrew, _ := cmd.Flags().GetBool("no-homebrew"); noHomebrew {
		opts.Homebrew = false
	}
	if noNode, _ := cmd.Flags().GetBool("no-node"); noNode {
		opts.Node = false
	}
	if noMise, _ := cmd.Flags().GetBool("no-mise"); noMise {
		opts.Mise = false
	}

	// Handle explicit include flags (if user explicitly set them to false)
	if cmd.Flags().Changed("homebrew") {
		opts.Homebrew = includeHomebrew
	}
	if cmd.Flags().Changed("node") {
		opts.Node = includeNode
	}
	if cmd.Flags().Changed("mise") {
		opts.Mise = includeMise
	}

	return opts
}

func printSelectedCategories(opts *exporter.CategoryOptions) {
	var selected []string
	if opts.Homebrew {
		selected = append(selected, "Homebrew")
	}
	if opts.Node {
		selected = append(selected, "Node Packages")
	}
	if opts.Mise {
		selected = append(selected, "Mise")
	}

	if len(selected) == 0 {
		fmt.Println("Warning: No categories selected!")
	} else {
		fmt.Printf("Categories: %s\n", strings.Join(selected, ", "))
	}
}
