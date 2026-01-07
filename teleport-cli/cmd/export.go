package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/spf13/cobra"
)

var exportCmd = &cobra.Command{
	Use:   "export",
	Short: "Export your Mac settings and packages",
	Long: `Export all detected settings, packages, dotfiles, and configurations
to a .teleport archive file that can be imported on another Mac.`,
	RunE: runExport,
}

var (
	outputPath string
)

func init() {
	exportCmd.Flags().StringVarP(&outputPath, "output", "o", "", "Output path for the .teleport archive (default: teleport-export-YYYY-MM-DD.teleport)")
}

func runExport(cmd *cobra.Command, args []string) error {
	if outputPath == "" {
		timestamp := time.Now().Format("2006-01-02")
		outputPath = fmt.Sprintf("teleport-export-%s.teleport", timestamp)
	}

	// Ensure output path has .teleport extension
	if filepath.Ext(outputPath) != ".teleport" {
		outputPath = outputPath + ".teleport"
	}

	fmt.Printf("Exporting to: %s\n", outputPath)
	
	// Create the archive directory
	if err := os.MkdirAll(outputPath, 0755); err != nil {
		return fmt.Errorf("failed to create export directory: %w", err)
	}

	fmt.Println("Phase 1: Foundation complete. Export functionality will be implemented in subsequent phases.")
	
	return nil
}

