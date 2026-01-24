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

    # Enter test directory
    pushd "$test_path" > /dev/null

    # Clean up previous artifacts
    rm -f *.rsk *.e my_output.txt diff.log

    # --- STEP 1: COMPILATION ---
    
    # 1a. Compile test.cmm
    "$COMPILER" test.cmm > compilation.log 2>&1
    local cc_exit=$?

    # 1b. Compile helper.cmm (if it exists)
    local has_helper=false
    if [[ -f "helper.cmm" ]]; then
        # Append log to compilation.log
        echo "--- Compiling helper.cmm ---" >> compilation.log
        "$COMPILER" helper.cmm >> compilation.log 2>&1
        local helper_exit=$?
        
        # If helper fails, treating it as a general compilation failure
        if [ $helper_exit -ne 0 ]; then
            cc_exit=$helper_exit
        fi
        has_helper=true
    fi

    # CHECK COMPILATION RESULT
    # CASE: Expected Failure (Negative Test)
    if [ "$expect_pass" = false ]; then
        if [ $cc_exit -ne 0 ]; then
            echo -e "${GREEN}PASS (Compilation failed as expected)${NC}"
        else
            echo -e "${RED}FAIL (Expected compilation error, but succeeded)${NC}"
        fi
        popd > /dev/null
        return
    fi

    # CASE: Expected Success
    if [ $cc_exit -ne 0 ]; then
        echo -e "${RED}FAIL (Compilation error)${NC}"
        echo "  See $test_path/compilation.log"
        popd > /dev/null
        return
    fi

    # --- STEP 2: LINKING ---
    
    # Ensure rx-runtime.rsk exists locally
    if [[ ! -f "rx-runtime.rsk" ]]; then
         cp "$ROOT_DIR/rx-runtime.rsk" . 2>/dev/null
    fi

    # Prepare linker arguments: test.rsk + helper.rsk (if exists)
    local link_files="test.rsk"
    if [ "$has_helper" = true ]; then
        link_files="test.rsk helper.rsk"
    fi

    "$LINKER" $link_files > linker.log 2>&1
    local ld_exit=$?

    if [ $ld_exit -ne 0 ]; then
        echo -e "${RED}FAIL (Linker error)${NC}"
        echo "  See $test_path/linker.log"
        popd > /dev/null
        return
    fi

    # --- STEP 3: VM EXECUTION ---
    
    local exe_name="test.e"
    if [[ ! -f "$exe_name" ]]; then
        echo -e "${RED}FAIL (Linker succeeded but $exe_name not found)${NC}"
        popd > /dev/null
        return
    fi

    # Detect Input File (Prioritize input.input, fallback to input.in)
    local input_arg=""
    if [[ -f "input.input" ]]; then
        input_arg="input.input"
    elif [[ -f "input.in" ]]; then
        input_arg="input.in"
    else
        touch empty_input.tmp
        input_arg="empty_input.tmp"
    fi

    "$VM" "$exe_name" < "$input_arg" > my_output.txt 2>&1
    
    # Clean temp input if created
    [ -f empty_input.tmp ] && rm empty_input.tmp

    # --- STEP 4: VERIFICATION ---
    
    # Detect Output File (Prioritize output.out)
    local expected_output=""
    if [[ -f "output.out" ]]; then
        expected_output="output.out"
    elif [[ -f "output.output" ]]; then
        expected_output="output.output"
    fi

    if [[ -z "$expected_output" ]]; then
        echo -e "${YELLOW}WARN (output.out missing, cannot verify)${NC}"
    else
        # diff -w ignores whitespace/newline differences
        diff -w "$expected_output" my_output.txt > diff.log
        local diff_exit=$?

        if [ $diff_exit -eq 0 ]; then
             echo -e "${GREEN}PASS${NC}"
        else
             echo -e "${RED}FAIL (Output mismatch)${NC}"
             echo "  Expected ($expected_output):"
             head -n 5 "$expected_output"
             echo "  Got:"
             head -n 5 my_output.txt
             echo "  (See $test_path/diff.log)"
        fi
    fi

    popd > /dev/null
}

# ================= EXECUTION LOOP =================
echo "Running tests in: $SUITE_DIR"
echo "----------------------------------------"

for i in {1..10}; do
    target_folder="$SUITE_DIR/test$i"
    if [[ -d "$target_folder" ]]; then
        run_test "$target_folder"
    else
        # Optional: verify if folder exists before warning, 
        # or just silently finish if fewer than 10 tests.
        if [ -d "$target_folder" ]; then
             echo -e "${YELLOW}Directory test$i not found${NC}"
        fi
    fi
done
