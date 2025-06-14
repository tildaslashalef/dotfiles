function cproj -d "Create a comprehensive C project template using clang"
    # Default project location
    set -l base_dir $HOME/Code
    
    if test (count $argv) -eq 0
        echo "Usage: cproj project_name [options]"
        echo "Options:"
        echo "  --lib       Create a library project"
        echo "  --cli       Create a CLI application project"
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
    
    # Create directories based on project type
    mkdir -p src include tests docs build
    
    # Create more specific directories based on project type
    switch $project_type
        case "standard"
            mkdir -p examples scripts
        case "library"
            mkdir -p examples
        case "cli"
            mkdir -p src/cmd
    end
    
    # Create main.c file
    if test "$project_type" = "library"
        # Create library source
        echo "#include \"$project.h\"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Private definitions */
#define UNUSED(x) (void)(x)

/* Version string */
#define VERSION_STR_HELPER(major, minor, patch) #major \".\" #minor \".\" #patch
#define VERSION_STR(major, minor, patch) VERSION_STR_HELPER(major, minor, patch)

/* Error messages */
static const char* const ERROR_MESSAGES[] = {
    [$(string upper $project)_SUCCESS] = \"Success\",
    [$(string upper $project)_ERROR_INVALID_ARGUMENT] = \"Invalid argument\",
    [$(string upper $project)_ERROR_MEMORY_ALLOCATION] = \"Memory allocation failed\",
    [$(string upper $project)_ERROR_IO] = \"I/O error\",
    /* Add more error messages as needed */
};

/* Safe memory allocation wrapper */
static void* safe_malloc(size_t size) {
    void* ptr = malloc(size);
    if (ptr == NULL) {
        fprintf(stderr, \"Memory allocation failed\\n\");
        exit(EXIT_FAILURE);
    }
    return ptr;
}

/* Safe memory reallocation wrapper */
static void* safe_realloc(void* ptr, size_t size) {
    void* new_ptr = realloc(ptr, size);
    if (new_ptr == NULL) {
        fprintf(stderr, \"Memory reallocation failed\\n\");
        free(ptr); /* Free the original memory to avoid leaks */
        exit(EXIT_FAILURE);
    }
    return new_ptr;
}

/* Implementation of public functions */
const char* $(string lower $project)_version(void) {
    static const char version[] = VERSION_STR(
        $(string upper $project)_VERSION_MAJOR,
        $(string upper $project)_VERSION_MINOR,
        $(string upper $project)_VERSION_PATCH
    );
    return version;
}

const char* $(string lower $project)_strerror($(string upper $project)_error_t error) {
    if (error >= sizeof(ERROR_MESSAGES) / sizeof(ERROR_MESSAGES[0])) {
        return \"Unknown error\";
    }
    return ERROR_MESSAGES[error];
}

/* Add your library implementation here */
" > src/$project.c

        # Create library header
        echo "#ifndef $(string upper $project)_H
#define $(string upper $project)_H
#pragma once  /* Modern compilers support this as well */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

/* Version information */
#define $(string upper $project)_VERSION_MAJOR 0
#define $(string upper $project)_VERSION_MINOR 1
#define $(string upper $project)_VERSION_PATCH 0

/* Error codes */
typedef enum {
    $(string upper $project)_SUCCESS = 0,
    $(string upper $project)_ERROR_INVALID_ARGUMENT,
    $(string upper $project)_ERROR_MEMORY_ALLOCATION,
    $(string upper $project)_ERROR_IO,
    /* Add more error codes as needed */
} $(string upper $project)_error_t;

/* Library declarations go here */

/* Function to get version string */
const char* $(string lower $project)_version(void);

/* Function to get error string from error code */
const char* $(string lower $project)_strerror($(string upper $project)_error_t error);

#endif /* $(string upper $project)_H */
" > include/$project.h

        # Create example usage
        echo "#include <stdio.h>
#include \"$project.h\"

int main(void) {
    printf(\"Example usage of $project library\\n\");
    return 0;
}
" > examples/example.c
    else
        # Create main.c in src directory
        echo "#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>

/* Function prototypes */
static void print_usage(const char* program_name);
static int parse_args(int argc, char *argv[]);
static void cleanup(void);

/* Global state (if needed) */
static bool verbose_mode = false;

/**
 * Print program usage information
 */
static void print_usage(const char* program_name) {
    fprintf(stderr, \"Usage: %s [options]\\n\", program_name);
    fprintf(stderr, \"Options:\\n\");
    fprintf(stderr, \"  -h, --help      Show this help message\\n\");
    fprintf(stderr, \"  -v, --verbose   Enable verbose output\\n\");
}

/**
 * Parse command line arguments
 * 
 * @return 0 on success, non-zero on error
 */
static int parse_args(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], \"-h\") == 0 || strcmp(argv[i], \"--help\") == 0) {
            print_usage(argv[0]);
            exit(EXIT_SUCCESS);
        } else if (strcmp(argv[i], \"-v\") == 0 || strcmp(argv[i], \"--verbose\") == 0) {
            verbose_mode = true;
        } else {
            fprintf(stderr, \"Error: Unknown option '%s'\\n\", argv[i]);
            print_usage(argv[0]);
            return 1;
        }
    }
    
    return 0;
}

/**
 * Perform cleanup before program exit
 */
static void cleanup(void) {
    /* Free any allocated resources here */
}

/**
 * Main program entry point
 */
int main(int argc, char *argv[]) {
    int exit_code = EXIT_SUCCESS;
    
    /* Set up cleanup handler */
    atexit(cleanup);
    
    /* Parse command line arguments */
    if (parse_args(argc, argv) != 0) {
        return EXIT_FAILURE;
    }
    
    if (verbose_mode) {
        printf(\"Running in verbose mode\\n\");
    }
    
    printf(\"Hello from $project\\n\");
    
    /* Main program logic here */
    
    return exit_code;
}
" > src/main.c
    end
    
    # Create README.md
    echo "# $project

A C project using clang.

## Build

```bash
make
```

## Usage

```bash
./bin/$project
```

## Run Tests

```bash
make test
```
" > README.md

    # Create a sample test file
    echo "#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>

/* Define simple test framework macros */
#define TEST_ASSERT(condition) do { \
    if (!(condition)) { \
        fprintf(stderr, \"\\nTest failed at %s:%d: %s\\n\", __FILE__, __LINE__, #condition); \
        return false; \
    } \
} while(0)

#define TEST_ASSERT_EQUAL_INT(expected, actual) do { \
    if ((expected) != (actual)) { \
        fprintf(stderr, \"\\nTest failed at %s:%d: %s != %s (expected %d, got %d)\\n\", \
                __FILE__, __LINE__, #expected, #actual, (expected), (actual)); \
        return false; \
    } \
} while(0)

#define TEST_ASSERT_EQUAL_STRING(expected, actual) do { \
    if (strcmp((expected), (actual)) != 0) { \
        fprintf(stderr, \"\\nTest failed at %s:%d: %s != %s (expected '%s', got '%s')\\n\", \
                __FILE__, __LINE__, #expected, #actual, (expected), (actual)); \
        return false; \
    } \
} while(0)

#define RUN_TEST(test) do { \
    printf(\"Running test: %s... \", #test); \
    bool result = test(); \
    test_count++; \
    if (result) { \
        printf(\"OK\\n\"); \
        pass_count++; \
    } else { \
        printf(\"FAILED\\n\"); \
        fail_count++; \
    } \
} while(0)

/* Test cases */

/**
 * Sample test function
 * 
 * @return true if the test passes, false if it fails
 */
static bool test_sample(void) {
    int a = 1;
    int b = 1;
    TEST_ASSERT_EQUAL_INT(2, a + b);
    return true;
}

/**
 * Test string comparison
 */
static bool test_string_comparison(void) {
    const char* str1 = \"hello\";
    const char* str2 = \"hello\";
    TEST_ASSERT_EQUAL_STRING(str1, str2);
    return true;
}

/**
 * Entry point for tests
 */
int main(void) {
    printf(\"Starting tests for $project...\\n\\n\");
    
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    /* Run all tests */
    RUN_TEST(test_sample);
    RUN_TEST(test_string_comparison);
    
    /* Print test summary */
    printf(\"\\n===== TEST SUMMARY =====\\n\");
    printf(\"Total tests: %d\\n\", test_count);
    printf(\"Passed:      %d\\n\", pass_count);
    printf(\"Failed:      %d\\n\", fail_count);
    printf(\"========================\\n\");
    
    /* Return success only if all tests pass */
    return (fail_count == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
" > tests/test_main.c

    # Create a comprehensive Makefile
    echo "# Project metadata
PROJECT_NAME := $project
CC           := clang
AUTHOR       := \$(shell git config user.name)
VERSION      := 0.1.0

# Directory structure
SRC_DIR      := src
INCLUDE_DIR  := include
BUILD_DIR    := build
BIN_DIR      := bin
TEST_DIR     := tests
DOC_DIR      := docs

# macOS specific settings
MACOS_ARCH   ?= $(uname -m) # arm64 or x86_64
OSX_SYSROOT  := $(xcrun --show-sdk-path)
OSX_MIN_VER  := 11.0        # Minimum macOS version

# Build configuration
BUILD_TYPE   ?= debug  # debug or release

# Compiler flags for different build types
CFLAGS_COMMON := -Wall -Wextra -pedantic -std=c11 -I\$(INCLUDE_DIR) \\
                 -isysroot \$(OSX_SYSROOT) -mmacosx-version-min=\$(OSX_MIN_VER) \\
                 -arch \$(MACOS_ARCH)
                 
CFLAGS_DEBUG  := -g3 -O0 -DDEBUG -fsanitize=address,undefined
CFLAGS_RELEASE := -O3 -DNDEBUG -march=native

# Select flags based on build type
ifeq (\$(BUILD_TYPE),debug)
    CFLAGS := \$(CFLAGS_COMMON) \$(CFLAGS_DEBUG)
    LDFLAGS := -fsanitize=address,undefined
else ifeq (\$(BUILD_TYPE),release)
    CFLAGS := \$(CFLAGS_COMMON) \$(CFLAGS_RELEASE)
    LDFLAGS :=
else
    \$(error Invalid BUILD_TYPE: \$(BUILD_TYPE). Use 'debug' or 'release')
endif

# Find all source files
SRCS         := \$(wildcard \$(SRC_DIR)/*.c)
OBJS         := \$(patsubst \$(SRC_DIR)/%.c,\$(BUILD_DIR)/\$(BUILD_TYPE)/%.o,\$(SRCS))
TEST_SRCS    := \$(wildcard \$(TEST_DIR)/*.c)
TEST_OBJS    := \$(patsubst \$(TEST_DIR)/%.c,\$(BUILD_DIR)/\$(BUILD_TYPE)/%.o,\$(TEST_SRCS))
TEST_BINS    := \$(patsubst \$(TEST_DIR)/%.c,\$(BIN_DIR)/\$(BUILD_TYPE)/%.test,\$(TEST_SRCS))

# Define targets
TARGET       := \$(BIN_DIR)/\$(BUILD_TYPE)/\$(PROJECT_NAME)

# Default target
.PHONY: all
all: \$(TARGET) compile_commands.json

# Create directories
\$(BUILD_DIR)/\$(BUILD_TYPE) \$(BIN_DIR)/\$(BUILD_TYPE):
	@mkdir -p \$@

# Compile source files
\$(BUILD_DIR)/\$(BUILD_TYPE)/%.o: \$(SRC_DIR)/%.c | \$(BUILD_DIR)/\$(BUILD_TYPE)
	@echo \"[\$(BUILD_TYPE)] Compiling \$<...\"
	@\$(CC) \$(CFLAGS) -c \$< -o \$@

# Link the target
\$(TARGET): \$(OBJS) | \$(BIN_DIR)/\$(BUILD_TYPE)
	@echo \"[\$(BUILD_TYPE)] Linking \$@...\"
	@\$(CC) \$(OBJS) -o \$@ \$(LDFLAGS)
	@echo \"[\$(BUILD_TYPE)] Build successful: \$@\"

# Compile test files
\$(BUILD_DIR)/\$(BUILD_TYPE)/%.o: \$(TEST_DIR)/%.c | \$(BUILD_DIR)/\$(BUILD_TYPE)
	@echo \"[\$(BUILD_TYPE)] Compiling test \$<...\"
	@\$(CC) \$(CFLAGS) -c \$< -o \$@

# Build test binaries
\$(BIN_DIR)/\$(BUILD_TYPE)/%.test: \$(BUILD_DIR)/\$(BUILD_TYPE)/%.o \$(filter-out \$(BUILD_DIR)/\$(BUILD_TYPE)/main.o,\$(OBJS)) | \$(BIN_DIR)/\$(BUILD_TYPE)
	@echo \"[\$(BUILD_TYPE)] Linking test \$@...\"
	@\$(CC) \$< \$(filter-out \$(BUILD_DIR)/\$(BUILD_TYPE)/main.o,\$(OBJS)) -o \$@ \$(LDFLAGS)

# Generate compile_commands.json for clangd
.PHONY: compile_commands.json
compile_commands.json:
	@echo \"Generating compile_commands.json for clangd...\"
	@echo \"[\" > compile_commands.json
	@for src in \$(SRCS); do \
		echo \"  {\" >> compile_commands.json; \
		echo \"    \\\"directory\\\": \\\"\$$(pwd)\\\",\" >> compile_commands.json; \
		echo \"    \\\"command\\\": \\\"\$(CC) \$(CFLAGS) -c \$${src} -o \$(BUILD_DIR)/\$(BUILD_TYPE)/\$$(basename \$${src%.c}.o)\\\",\" >> compile_commands.json; \
		echo \"    \\\"file\\\": \\\"\$${src}\\\"\" >> compile_commands.json; \
		if [ \"\$${src}\" != \"\$$(echo \$(SRCS) | rev | cut -d' ' -f1 | rev)\" ]; then \
			echo \"  },\" >> compile_commands.json; \
		else \
			echo \"  }\" >> compile_commands.json; \
		fi; \
	done
	@echo \"]\" >> compile_commands.json
	@echo \"compile_commands.json generated\"

# Build both debug and release
.PHONY: all-builds
all-builds:
	@\$(MAKE) BUILD_TYPE=debug
	@\$(MAKE) BUILD_TYPE=release

# Clean the build
.PHONY: clean
clean:
	@echo \"Cleaning...\"
	@rm -rf \$(BUILD_DIR) \$(BIN_DIR) compile_commands.json

# Run the target
.PHONY: run
run: \$(TARGET)
	@echo \"[\$(BUILD_TYPE)] Running \$(TARGET)...\"
	@\$(TARGET)

# Memory leak check using leaks (macOS tool)
.PHONY: memcheck
memcheck: \$(TARGET)
	@echo \"[\$(BUILD_TYPE)] Running memory check with leaks...\"
	@leaks -atExit -- \$(TARGET)

# Static analysis with clang analyzer
.PHONY: analyze
analyze:
	@echo \"[\$(BUILD_TYPE)] Analyzing code with clang analyzer...\"
	@mkdir -p \$(BIN_DIR)/analysis
	@scan-build \$(CC) \$(CFLAGS) \$(SRCS) -o \$(BIN_DIR)/analysis/analyze

# Code coverage
.PHONY: coverage
coverage:
	@echo \"Building with code coverage...\"
	@\$(MAKE) BUILD_TYPE=debug CFLAGS=\"\$(CFLAGS_COMMON) -g3 -O0 -DDEBUG --coverage\" LDFLAGS=\"--coverage\"
	@\$(MAKE) test BUILD_TYPE=debug CFLAGS=\"\$(CFLAGS_COMMON) -g3 -O0 -DDEBUG --coverage\" LDFLAGS=\"--coverage\"
	@mkdir -p \$(BIN_DIR)/coverage
	@lcov --capture --directory \$(BUILD_DIR)/debug --output-file \$(BIN_DIR)/coverage/coverage.info
	@lcov --remove \$(BIN_DIR)/coverage/coverage.info '/usr/*' --output-file \$(BIN_DIR)/coverage/coverage.info
	@genhtml \$(BIN_DIR)/coverage/coverage.info --output-directory \$(BIN_DIR)/coverage/html
	@echo \"Coverage report generated in \$(BIN_DIR)/coverage/html\"

# Generate documentation with doxygen if available
.PHONY: docs
docs:
	@if command -v doxygen &> /dev/null; then \
		echo \"Generating documentation with doxygen...\"; \
		doxygen Doxyfile 2> /dev/null || echo \"No Doxyfile found. Creating one...\"; \
		if [ ! -f Doxyfile ]; then \
			doxygen -g; \
			sed -i '' 's/PROJECT_NAME\\s*=.*/PROJECT_NAME = \$(PROJECT_NAME)/g' Doxyfile; \
			sed -i '' 's/OUTPUT_DIRECTORY\\s*=.*/OUTPUT_DIRECTORY = \$(DOC_DIR)/g' Doxyfile; \
			doxygen Doxyfile; \
		fi; \
	else \
		echo \"Doxygen not found. Please install doxygen.\"; \
	fi

# Format code with clang-format
.PHONY: format
format:
	@echo \"Formatting code...\"
	@find \$(SRC_DIR) \$(INCLUDE_DIR) \$(TEST_DIR) -type f -name \"*.c\" -o -name \"*.h\" | xargs clang-format -i -style=file

# Help target
.PHONY: help
help:
	@echo \"\$(PROJECT_NAME) Makefile Help\"
	@echo \"=======================\" 
	@echo \"make [BUILD_TYPE=debug|release] - Build the project (debug is default)\"
	@echo \"make all-builds               - Build both debug and release versions\"
	@echo \"make test                     - Build and run tests\"
	@echo \"make run                      - Build and run the project\"
	@echo \"make clean                    - Clean build files\"
	@echo \"make memcheck                 - Run with leaks tool (macOS)\"
	@echo \"make analyze                  - Run static analyzer\"
	@echo \"make coverage                 - Generate code coverage report\"
	@echo \"make docs                     - Generate documentation\"
	@echo \"make format                   - Format code with clang-format\"
	@echo \"make compile_commands.json    - Generate compilation database for clangd\"
" > Makefile

    # Create .gitignore file
    echo "# Build directories
/bin/
/build/
/lib/

# Editor files
*.swp
*.swo
.vscode/
.idea/

# Object files
*.o
*.ko
*.obj

# Libraries
*.lib
*.a
*.la
*.lo

# Shared objects
*.so
*.so.*
*.dylib

# Executables
*.exe
*.out
*.app

# Debug files
*.dSYM/
*.su
*.idb
*.pdb

# OS specific
.DS_Store
Thumbs.db" > .gitignore

    # Create a simple clang-format file
    echo "BasedOnStyle: LLVM
IndentWidth: 4
UseTab: Never
BreakBeforeBraces: Linux
AllowShortIfStatementsOnASingleLine: false
AllowShortFunctionsOnASingleLine: false
IndentCaseLabels: true
ColumnLimit: 100
" > .clang-format

    # Create a clang-tidy configuration
    echo "Checks: 'clang-diagnostic-*,clang-analyzer-*,readability-*,performance-*,portability-*,bugprone-*,-readability-magic-numbers,-readability-braces-around-statements'
WarningsAsErrors: ''
HeaderFilterRegex: '.*'
FormatStyle: file
CheckOptions:
  - key: readability-identifier-naming.VariableCase
    value: camelBack
  - key: readability-identifier-naming.FunctionCase
    value: lower_case
  - key: readability-identifier-naming.ParameterCase
    value: camelBack
  - key: readability-identifier-naming.MacroDefinitionCase
    value: UPPER_CASE
  - key: readability-identifier-naming.ConstantCase
    value: UPPER_CASE
  - key: readability-identifier-naming.StructCase
    value: lower_case
  - key: readability-identifier-naming.TypedefCase
    value: lower_case
" > .clang-tidy

    # Initialize GitHub repo if private flag is set
    if test "$is_private" = true
        git remote add origin git@github.com:username/$project.git
    end

    # Initial commit
    git add .
    git commit -m "Initial commit: C project template created"

    echo "C project created at $project_path"
    echo "Project structure initialized with comprehensive template"
    echo "Run 'make help' to see available commands"

    # Create CMakeLists.txt for CMake integration
    echo "cmake_minimum_required(VERSION 3.16)

# Project details
project($project VERSION 0.1.0 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# MacOS specific settings
set(CMAKE_OSX_DEPLOYMENT_TARGET \"11.0\")

# Build type settings
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE \"Debug\" CACHE STRING \"Build type\" FORCE)
endif()

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR}/bin)

# Compiler flags
set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -Wall -Wextra -pedantic\")
set(CMAKE_C_FLAGS_DEBUG \"\${CMAKE_C_FLAGS_DEBUG} -g3 -O0\")
set(CMAKE_C_FLAGS_RELEASE \"\${CMAKE_C_FLAGS_RELEASE} -O3 -march=native -DNDEBUG\")

# Enable sanitizers in Debug mode
if(CMAKE_BUILD_TYPE STREQUAL \"Debug\")
  set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -fsanitize=address,undefined\")
  set(CMAKE_EXE_LINKER_FLAGS \"\${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address,undefined\")
endif()

# Include directories
include_directories(include)

# Main executable
file(GLOB_RECURSE SOURCES \"src/*.c\")
add_executable(\${PROJECT_NAME} \${SOURCES})

# Testing
enable_testing()
file(GLOB_RECURSE TEST_SOURCES \"tests/*.c\")
foreach(TEST_SRC \${TEST_SOURCES})
  get_filename_component(TEST_NAME \${TEST_SRC} NAME_WE)
  add_executable(\${TEST_NAME} \${TEST_SRC})
  
  # Add project sources except main.c to tests
  list(FILTER SOURCES EXCLUDE REGEX \".*main\\.c\$\")
  target_sources(\${TEST_NAME} PRIVATE \${SOURCES})
  
  # Register test
  add_test(NAME \${TEST_NAME} COMMAND \${TEST_NAME})
endforeach()

# Install rules
install(TARGETS \${PROJECT_NAME} DESTINATION bin)

# Set export compile commands for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
" > CMakeLists.txt
end 