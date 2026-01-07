package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "teleport",
	Short: "Teleport - Migrate your Mac settings and packages",
	Long: `Teleport helps you migrate all your settings, packages, dotfiles,
and configurations from one Mac to another.`,
	Version: "0.1.0",
}

// Execute adds all child commands to the root command and sets flags appropriately.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(exportCmd)
	rootCmd.AddCommand(importCmd)
}

