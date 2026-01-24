#!/bin/bash

# ================= CONFIGURATION =================
# Paths to your tools (Assumes script is run from project root)
ROOT_DIR=$(pwd)
COMPILER="$ROOT_DIR/rx-cc"
LINKER="$ROOT_DIR/rx-linker"
VM="$ROOT_DIR/rx-vm"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ================= PRE-CHECKS =================
if [[ ! -x "$COMPILER" || ! -x "$LINKER" || ! -x "$VM" ]]; then
    echo -e "${RED}Error: Executables (rx-cc, rx-linker, rx-vm) not found in $ROOT_DIR${NC}"
    echo "Please build your project first."
    exit 1
fi

if [ "$#" -eq 0 ]; then
    echo "Usage: ./run_tests.sh <path_to_test_suite_folder>"
    echo "Example: ./run_tests.sh proj-part3-tests-123456789-987654321"
    exit 1
fi

SUITE_DIR="$1"

if [[ ! -d "$SUITE_DIR" ]]; then
    echo -e "${RED}Error: Directory $SUITE_DIR does not exist.${NC}"
    exit 1
fi

# ================= TEST LOGIC =================
run_test() {
    local test_path="$1"
    local test_name=$(basename "$test_path")

    echo -n "Testing $test_name... "

    # Check for test.cmm
    if [[ ! -f "$test_path/test.cmm" ]]; then
        echo -e "${YELLOW}SKIP (test.cmm missing)${NC}"
        return
    fi

    # Determine expected mode (PASS or FAIL)
    local expect_pass=false
    if [[ -f "$test_path/pass" ]]; then
        expect_pass=true
    elif [[ -f "$test_path/fail" ]]; then
        expect_pass=false
    else
        echo -e "${YELLOW}SKIP (marker file 'pass'/'fail' missing)${NC}"
        return
    fi

    # Enter test directory to ensure linker finds local rx-runtime.rsk
    # and paths remain simple
    pushd "$test_path" > /dev/null

    # Clean up previous artifacts
    rm -f test.rsk test.e my_output.txt diff.log

    # 1. RUN COMPILER
    "$COMPILER" test.cmm > compilation.log 2>&1
    local cc_exit=$?

    # CASE: Expected Compilation FAILURE
    if [ "$expect_pass" = false ]; then
        if [ $cc_exit -ne 0 ]; then
            echo -e "${GREEN}PASS (Compilation failed as expected)${NC}"
        else
            echo -e "${RED}FAIL (Expected compilation error, but succeeded)${NC}"
        fi
        popd > /dev/null
        return
    fi

    # CASE: Expected Compilation SUCCESS
    if [ $cc_exit -ne 0 ]; then
        echo -e "${RED}FAIL (Compilation error)${NC}"
        echo "  See $test_path/compilation.log"
        popd > /dev/null
        return
    fi

    # 2. RUN LINKER
    # Linker requires rx-runtime.rsk in current dir 
    if [[ ! -f "rx-runtime.rsk" ]]; then
         # Fallback: copy from root if missing in test folder
         cp "$ROOT_DIR/rx-runtime.rsk" . 2>/dev/null
    fi

    "$LINKER" test.rsk > linker.log 2>&1
    local ld_exit=$?

    if [ $ld_exit -ne 0 ]; then
        echo -e "${RED}FAIL (Linker error)${NC}"
        echo "  See $test_path/linker.log"
        popd > /dev/null
        return
    fi

    # 3. RUN VM
    # The linker usually produces 'test.e' (first filename with .e) [cite: 297]
    local exe_name="test.e"
    if [[ ! -f "$exe_name" ]]; then
        echo -e "${RED}FAIL (Linker succeeded but $exe_name not found)${NC}"
        popd > /dev/null
        return
    fi

    # Handle input file (if empty/missing, ensure empty file exists for redirection)
    local input_arg="input.input"
    if [[ ! -f "input.input" ]]; then
        touch empty_input.tmp
        input_arg="empty_input.tmp"
    fi

    "$VM" "$exe_name" < "$input_arg" > my_output.txt 2>&1
    local vm_exit=$?
    
    # Cleanup temp input
    [ -f empty_input.tmp ] && rm empty_input.tmp

    # 4. COMPARE OUTPUT
    if [[ ! -f "output.output" ]]; then
        # If expected output is missing, warn but assume pass if VM ran?
        # Usually strict matching is better.
        echo -e "${YELLOW}WARN (output.output missing, cannot verify)${NC}"
    else
        # Using diff -w to ignore whitespace changes (like trailing newlines)
        diff -w output.output my_output.txt > diff.log
        local diff_exit=$?

        if [ $diff_exit -eq 0 ]; then
             echo -e "${GREEN}PASS${NC}"
        else
             echo -e "${RED}FAIL (Output mismatch)${NC}"
             echo "  Expected:"
             head -n 5 output.output
             echo "  Got:"
             head -n 5 my_output.txt
             echo "  (See $test_path/diff.log for full details)"
        fi
    fi

    popd > /dev/null
}

# ================= EXECUTION LOOP =================
echo "Running tests in: $SUITE_DIR"
echo "----------------------------------------"

# Loop strictly through test1 to test10 to maintain order
for i in {1..10}; do
    target_folder="$SUITE_DIR/test$i"
    if [[ -d "$target_folder" ]]; then
        run_test "$target_folder"
    else
        echo -e "${YELLOW}Directory test$i not found, skipping...${NC}"
    fi
done
