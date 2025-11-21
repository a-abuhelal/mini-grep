#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

TESTS_PASSED=0
TESTS_FAILED=0

# Get the script directory to build correct paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Detect the correct executable name (windows vs linux)
if [ -f "$PROJECT_ROOT/src/mgrep.exe" ]; then
    MGREP="$PROJECT_ROOT/src/mgrep.exe"
elif [ -f "$PROJECT_ROOT/src/mgrep" ]; then
    MGREP="$PROJECT_ROOT/src/mgrep"
else
    echo -e "${RED}Error: mgrep executable not found!${NC}"
    echo "Looked in: $PROJECT_ROOT/src/"
    echo "Please compile first:"
    echo "  cd $PROJECT_ROOT"
    echo "  make"
    echo ""
    echo "Or manually:"
    echo "  g++ -o src/mgrep src/mgrep.cpp src/cli.cpp src/grep_engine.cpp -std=c++17 -Wall -Wextra -O2 -Iinclude"
    exit 1
fi

echo "Using executable: $MGREP"
echo ""

# Helper function to check test result
check_test() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $1"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $1"
        ((TESTS_FAILED++))
    fi
}

echo "Running mgrep tests..."
echo "======================"

# Create test files in a temp directory
TEST_DIR="$PROJECT_ROOT/test/test_temp"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "foo" > file1.txt
echo "bar" >> file1.txt
echo "FooBar" >> file1.txt
echo "food" >> file1.txt

echo "hello world" > file2.txt
echo "HELLO there" >> file2.txt
echo "goodbye" >> file2.txt

echo "test data" > file3.cpp
echo "more test" >> file3.cpp

echo "log entry" > file4.log

# Test 1: Basic case-sensitive search
echo ""
echo "Test 1: Basic case-sensitive search"
"$MGREP" "foo" file1.txt > output.txt
grep -q "1: foo" output.txt && grep -q "4: food" output.txt
check_test "Case-sensitive 'foo' matches line 1 and 4"

# Test 2: Case-insensitive search with -i flag
echo ""
echo "Test 2: Case-insensitive search"
"$MGREP" -i "foo" file1.txt > output.txt
grep -q "1: foo" output.txt && grep -q "3: FooBar" output.txt && grep -q "4: food" output.txt
check_test "Case-insensitive 'foo' matches lines 1, 3, and 4"

# Test 3: Search in multiple files
echo ""
echo "Test 3: Multiple files"
"$MGREP" "hello" file1.txt file2.txt > output.txt
grep -q "file2.txt:1: hello world" output.txt
check_test "Search across multiple files shows filename"

# Test 4: Case-insensitive multiple files
echo ""
echo "Test 4: Case-insensitive multiple files"
"$MGREP" -i "hello" file2.txt > output.txt
grep -q "1: hello world" output.txt && grep -q "2: HELLO there" output.txt
check_test "Case-insensitive search finds both 'hello' and 'HELLO'"

# Test 5: Wildcard - all files with *
echo ""
echo "Test 5: Wildcard - all files"
"$MGREP" "test" "*" > output.txt
grep -q "file3.cpp" output.txt
check_test "Wildcard * searches all files"

# Test 6: Wildcard - specific extension *.txt
echo ""
echo "Test 6: Wildcard - *.txt extension"
"$MGREP" "hello" "*.txt" > output.txt
grep -q "file2.txt" output.txt && ! grep -q "file3.cpp" output.txt
check_test "Wildcard *.txt only matches .txt files"

# Test 7: Wildcard - *.cpp extension
echo ""
echo "Test 7: Wildcard - *.cpp extension"
"$MGREP" "test" "*.cpp" > output.txt
grep -q "^1: test data" output.txt && grep -q "^2: more test" output.txt && [ $(wc -l < output.txt) -eq 2 ]
check_test "Wildcard *.cpp only matches .cpp files"

# Test 8: No matches found
echo ""
echo "Test 8: No matches"
"$MGREP" "nonexistent" file1.txt > output.txt
[ ! -s output.txt ]
check_test "No output when pattern not found"

# Test 9: File not found error
echo ""
echo "Test 9: File not found"
"$MGREP" "test" nonexistent.txt 2> error.txt
grep -q "Could not open file" error.txt
check_test "Error message for non-existent file"

# Test 10: Missing arguments
echo ""
echo "Test 10: Missing arguments"
"$MGREP" 2> error.txt
grep -q "Usage:" error.txt
check_test "Usage message when arguments missing"

# Test 11: Case-insensitive with wildcard
echo ""
echo "Test 11: Case-insensitive with wildcard"
"$MGREP" -i "HELLO" "*.txt" > output.txt
grep -q "file2.txt:1: hello world" output.txt
check_test "Case-insensitive works with wildcard"

# Cleanup
cd "$PROJECT_ROOT"
rm -rf "$TEST_DIR"

# Summary
echo ""
echo "======================"
echo "Test Summary:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi