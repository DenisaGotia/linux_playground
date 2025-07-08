#!/bin/bash

PASS=0
FAIL=0

test_log="./tests/log_sample_1.txt"

assert_equal() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]; then
        echo "✅ $test_name"
        ((PASS++))
    else
        echo "❌ $test_name"
        echo "Expected:"
        echo "$expected"
        echo "Actual:"
        echo "$actual"
        ((FAIL++))
    fi
}

run_test() {
    local name="$1"
    local args="$2"
    local expected_file="$3"

    output=$(./log_processor.sh --input "$test_log" $args)
    expected=$(cat "$expected_file")
    assert_equal "$name" "$expected" "$output"
}

run_test "Test: --errors-only" "--errors-only" "./tests/expected_errors_only.txt"

echo
echo "✅ Passed: $PASS"
echo "❌ Failed: $FAIL"

