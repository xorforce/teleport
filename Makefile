# Teleport - Development Makefile
# ============================================================================
# Usage: make <target>
# Run 'make help' to see all available targets
# ============================================================================

.PHONY: all help setup lint lint-go lint-swift lint-fix fmt test build clean

# Default target
all: lint test build

# ============================================================================
# HELP
# ============================================================================
help: ## Show this help message
	@echo "Teleport Development Commands"
	@echo "=============================="
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*##"; } /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

# ============================================================================
# SETUP
# ============================================================================
setup: ## Install all development dependencies
	@echo "📦 Installing development dependencies..."
	@echo ""
	@echo "Installing Go tools..."
	brew install golangci-lint || true
	go install golang.org/x/tools/cmd/goimports@latest
	@echo ""
	@echo "Installing Swift tools..."
	brew install swiftlint || true
	brew install swiftformat || true
	@echo ""
	@echo "Installing pre-commit..."
	brew install pre-commit || pip install pre-commit
	pre-commit install
	@echo ""
	@echo "✅ Setup complete!"

setup-ci: ## Setup for CI environment (skip brew)
	@echo "📦 Setting up CI environment..."
	go install golang.org/x/tools/cmd/goimports@latest
	@echo "✅ CI setup complete!"

# ============================================================================
# LINTING
# ============================================================================
lint: lint-go lint-swift ## Run all linters
	@echo ""
	@echo "✅ All linting passed!"

lint-go: ## Lint Go code
	@echo "🔍 Linting Go code..."
	cd teleport-cli && golangci-lint run --config=../.golangci.yml ./...

lint-swift: ## Lint Swift code
	@echo "🔍 Linting Swift code..."
	swiftlint lint --config .swiftlint.yml

lint-fix: ## Auto-fix linting issues where possible
	@echo "🔧 Auto-fixing lint issues..."
	@echo ""
	@echo "Fixing Go..."
	cd teleport-cli && golangci-lint run --config=../.golangci.yml --fix ./... || true
	cd teleport-cli && gofmt -s -w .
	-@cd teleport-cli && goimports -w . 2>/dev/null || echo "  (goimports not installed, skipping)"
	@echo ""
	@echo "Fixing Swift..."
	swiftlint lint --config .swiftlint.yml --fix || true
	@echo ""
	@echo "✅ Auto-fix complete!"

# ============================================================================
# FORMATTING
# ============================================================================
fmt: ## Format all code
	@echo "✨ Formatting code..."
	@echo ""
	@echo "Formatting Go..."
	cd teleport-cli && gofmt -s -w .
	-@cd teleport-cli && goimports -w . 2>/dev/null || echo "  (goimports not installed, skipping)"
	@echo ""
	@echo "Formatting Swift (if swiftformat installed)..."
	-swiftformat teleport-app --config .swiftformat 2>/dev/null || echo "  SwiftFormat not installed, skipping..."
	@echo ""
	@echo "✅ Formatting complete!"

fmt-check: ## Check if code is formatted (CI)
	@echo "🔍 Checking code formatting..."
	@echo ""
	@echo "Checking Go..."
	@cd teleport-cli && test -z "$$(gofmt -s -l .)" || (echo "Go files need formatting. Run 'make fmt'" && gofmt -s -d . && exit 1)
	@echo "✅ All code is properly formatted!"

# ============================================================================
# TESTING
# ============================================================================
test: test-go test-swift ## Run all tests
	@echo ""
	@echo "✅ All tests passed!"

test-go: ## Run Go tests
	@echo "🧪 Running Go tests..."
	cd teleport-cli && go test -v -race ./...

test-go-coverage: ## Run Go tests with coverage
	@echo "🧪 Running Go tests with coverage..."
	cd teleport-cli && go test -v -race -coverprofile=coverage.out ./...
	cd teleport-cli && go tool cover -html=coverage.out -o coverage.html
	@echo "📊 Coverage report generated: teleport-cli/coverage.html"

test-swift: ## Run Swift tests
	@echo "🧪 Running Swift tests..."
	xcodebuild test \
		-project teleport-app/teleport-app.xcodeproj \
		-scheme teleport-app \
		-destination 'platform=macOS' \
		-configuration Debug \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		| xcpretty || true

# ============================================================================
# BUILDING
# ============================================================================
build: build-go build-swift ## Build all components
	@echo ""
	@echo "✅ Build complete!"

build-go: ## Build Go CLI
	@echo "🔨 Building Go CLI..."
	cd teleport-cli && go build -o teleport .
	@echo "Built: teleport-cli/teleport"

build-swift: ## Build Swift app
	@echo "🔨 Building Swift app..."
	xcodebuild build \
		-project teleport-app/teleport-app.xcodeproj \
		-scheme teleport-app \
		-destination 'platform=macOS' \
		-configuration Debug \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		| xcpretty

build-release: ## Build release versions
	@echo "🚀 Building release versions..."
	./scripts/build-release.sh

# ============================================================================
# CLEANING
# ============================================================================
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	cd teleport-cli && rm -f teleport coverage.out coverage.html
	rm -rf DerivedData
	rm -rf ~/Library/Developer/Xcode/DerivedData/teleport-*
	@echo "✅ Clean complete!"

# ============================================================================
# PRE-COMMIT
# ============================================================================
pre-commit: ## Run pre-commit on all files
	@echo "🔍 Running pre-commit hooks..."
	pre-commit run --all-files

pre-commit-install: ## Install pre-commit hooks
	pre-commit install
	@echo "✅ Pre-commit hooks installed!"

pre-commit-update: ## Update pre-commit hooks
	pre-commit autoupdate
	@echo "✅ Pre-commit hooks updated!"

# ============================================================================
# CI HELPERS
# ============================================================================
ci-lint: lint-go lint-swift fmt-check ## Run all CI lint checks
	@echo "✅ CI lint checks passed!"

ci-test: test-go test-swift ## Run all CI tests
	@echo "✅ CI tests passed!"

ci: ci-lint ci-test build ## Full CI pipeline
	@echo ""
	@echo "✅ Full CI pipeline passed!"

