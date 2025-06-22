function goproj -d "Create a comprehensive Golang project template"
    # Default project location
    set -l base_dir $HOME/Code
    
    if test (count $argv) -eq 0
        echo "Usage: goproj project_name [options]"
        echo "Options:"
        echo "  --lib       Create a library project"
        echo "  --cli       Create a CLI application project"
        echo "  --web       Create a web application project"
        echo "  --private   Initialize with private GitHub repo"
        return 0
    end
    
    set -l project $argv[1]
    set -l project_type "standard"
    set -l is_private false
    
    # Parse optional arguments
    for arg in $argv[2..-1]
        switch $arg
            case "--lib"
                set project_type "library"
            case "--cli"
                set project_type "cli"
            case "--web"
                set project_type "web"
            case "--private"
                set is_private true
        end
    end
    
    # Validate project name
    if test -z "$project"
        echo "Error: Project name required"
        return 1
    end
    
    set -l project_path $base_dir/$project
    set -l module_name $project
    
    # Check if directory already exists
    if test -d $project_path
        echo "Error: Directory already exists at $project_path"
        return 1
    end
    
    # Create project directory and navigate to it
    mkdir -p $project_path
    cd $project_path
    
    # Initialize git repository
    git init
    
    # Initialize Go module
    go mod init $module_name
    
    # Create directories based on project type
    mkdir -p cmd/$project pkg internal docs test
    
    # Create initial directories and files
    switch $project_type
        case "standard"
            mkdir -p api configs scripts
            mkdir -p internal/{app,config,models,repository,service}
        case "library"
            mkdir -p examples
        case "cli"
            mkdir -p internal/{app,cli,config}
            mkdir -p cmd/$project
        case "web"
            mkdir -p internal/{app,api,config,handlers,middleware,models,repository,service}
            mkdir -p web/{templates,static/{css,js,img}}
    end
    
    # Create main.go file
    if test "$project_type" = "library"
        # Create example usage for library
        mkdir -p examples
        echo "package main

import (
	\"fmt\"
	\"github.com/username/$project\"
)

func main() {
	fmt.Println(\"Example usage of $project library\")
}
" > examples/main.go
    else
        # Create main.go in cmd directory
        mkdir -p cmd/$project
        echo "package main

import (
	\"fmt\"
)

func main() {
	fmt.Println(\"Hello from $project\")
}
" > cmd/$project/main.go
    end
    
    # Create README.md
    echo "# $project

A Go project.

## Installation

\`\`\`
go get github.com/username/$project
\`\`\`

## Usage

\`\`\`go
package main

import (
    \"github.com/username/$project\"
)

func main() {
    // Use the package
}
\`\`\`
" > README.md

    # Create a comprehensive Makefile inspired by the example
    echo "# Project metadata
BINARY_NAME  := $project
AUTHOR       := \\\$(shell git config user.name)
EMAIL        := \\\$(shell git config user.email)

# Directory structure
BUILD_DIR    := bin
COVERAGE_DIR := coverage
BENCH_DIR    := benchmark_results
DOCS_DIR     := docs

# Go toolchain
GO           := go
GOFMT        := gofmt
GOBUILD      := \\\$(GO) build
GOTEST       := \\\$(GO) test
GOVET        := \\\$(GO) vet
GOGET        := \\\$(GO) get
GOMOD        := \\\$(GO) mod

# Version control
VERSION      ?= \\\$(shell git describe --tags --abbrev=0 2>/dev/null || echo \"v0.0.0\")
BUILD_TIME   := \\\$(shell date -u '+%Y-%m-%d_%H:%M:%S')
COMMIT_HASH  := \\\$(shell git rev-parse HEAD)

# Build configuration
LDFLAGS      := -ldflags=\"-X main.Version=\\\$(VERSION) -X main.BuildTime=\\\$(BUILD_TIME) -X main.CommitHash=\\\$(COMMIT_HASH) -X 'main.Author=\\\$(AUTHOR)' -X 'main.Email=\\\$(EMAIL)'\"
PLATFORMS    := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64

.PHONY: all build test bench coverage clean deps lint format help

# Main targets
all: test build ## Run tests and build

build: ## Build the binary for current platform
	@mkdir -p \\\$(BUILD_DIR)
	\\\$(GOBUILD) \\\$(LDFLAGS) -o \\\$(BUILD_DIR)/\\\$(BINARY_NAME) ./cmd/\\\$(BINARY_NAME)
	@echo \"Binary built at \\\$(BUILD_DIR)/\\\$(BINARY_NAME)\"

run: build ## Build and run the application
	./\\\$(BUILD_DIR)/\\\$(BINARY_NAME)

# Testing targets
test: ## Run tests
	\\\$(GOTEST) -race -v ./...

coverage: ## Generate test coverage report
	@mkdir -p \\\$(COVERAGE_DIR)
	\\\$(GOTEST) -race -coverprofile=\\\$(COVERAGE_DIR)/coverage.out ./...
	\\\$(GO) tool cover -html=\\\$(COVERAGE_DIR)/coverage.out -o \\\$(COVERAGE_DIR)/coverage.html
	@echo \"Coverage report available at \\\$(COVERAGE_DIR)/coverage.html\"

# Code quality targets
format: ## Format code
	\\\$(GOFMT) -w -s .

# Utility targets
clean: ## Clean build artifacts
	rm -rf \\\$(BUILD_DIR)
	rm -rf \\\$(COVERAGE_DIR)

deps: ## Download and verify dependencies
	\\\$(GOMOD) download
	\\\$(GOMOD) verify
	\\\$(GOMOD) tidy

help: ## Display this help
	@echo \"$project Makefile\"
	@echo \"====================\"
	@echo \"Usage: make [target]\"
	@echo \"\"
	@echo \"Targets:\"
	@grep -h -E \"^[a-zA-Z_-]+:.*?## .*\" \\\$(MAKEFILE_LIST) | awk 'BEGIN {FS = \":.*?## \"}; {printf \"\\\\033[36m%-20s\\\\033[0m %s\\\\n\", \\\$1, \\\$2}'
" > Makefile

    # Create .gitignore file
    echo "# Binaries and build artifacts
/bin/
/coverage/
/benchmark_results/

# Dependency directories
/vendor/

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific
.DS_Store
Thumbs.db

# Test coverage
*.out
*.test" > .gitignore

    # Create a sample Go test file
    mkdir -p internal/app
    echo "package app

import \"testing\"

func TestSample(t *testing.T) {
	// Add your test here
	if 1+1 != 2 {
		t.Error(\"Expected 1+1 to be 2\")
	}
}" > internal/app/sample_test.go

    # Initialize GitHub repo if private flag is set
    if test "$is_private" = true
        git remote add origin git@github.com:username/$project.git
    end

    # Initial commit
    git add .
    git commit -m "Initial commit: Project template created"

    echo "Go project created at $project_path"
    echo "Project structure initialized with comprehensive template"
    echo "Run 'make help' to see available commands"
end 