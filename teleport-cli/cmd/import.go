package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var importCmd = &cobra.Command{
	Use:   "import",
	Short: "Import settings and packages from a .teleport archive",
	Long: `Import a previously exported .teleport archive to restore all
settings, packages, dotfiles, and configurations on this Mac.`,
	Args: cobra.ExactArgs(1),
	RunE: runImport,
}

func runImport(cmd *cobra.Command, args []string) error {
	archivePath := args[0]

	// Check if archive exists
	if _, err := os.Stat(archivePath); os.IsNotExist(err) {
		return fmt.Errorf("archive not found: %s", archivePath)
	}

	fmt.Printf("Importing from: %s\n", archivePath)
	fmt.Println("Phase 1: Foundation complete. Import functionality will be implemented in subsequent phases.")

	return nil
}
