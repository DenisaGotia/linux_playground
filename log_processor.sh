#!/bin/bash

# Default values
input=""
output=""
errors_only=false
warnings_only=false
summary=false
top_n=0

# Use getopt for long options
PARSED=$(getopt -o "" \
--long input:,output:,errors-only,warnings-only,summary,top: \
-n "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    echo "Failed to parse options." >&2
    exit 1
fi

eval set -- "$PARSED"

# Parse flags
while true; do
    case "$1" in
        --input)
            input="$2"
            shift 2
            ;;
        --output)
            output="$2"
            shift 2
            ;;
        --errors-only)
            errors_only=true
            shift
            ;;
        --warnings-only)
            warnings_only=true
            shift
            ;;
        --summary)
            summary=true
            shift
            ;;
        --top)
            top_n="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unexpected option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$input" ]]; then
    echo "Error: --input is required."
    exit 1
fi

if [[ ! -f "$input" ]]; then
    echo "Error: File '$input' does not exist."
    exit 1
fi

# Function to filter logs
filter_logs() {
    local log_lines=$(cat "$input")

    if $errors_only && ! $warnings_only; then
        log_lines=$(echo "$log_lines" | grep -i "ERROR")
    elif $warnings_only && ! $errors_only; then
        log_lines=$(echo "$log_lines" | grep -i "WARNING")
    elif $warnings_only && $errors_only; then
        log_lines=$(echo "$log_lines" | grep -Ei "ERROR|WARNING")
    fi

    echo "$log_lines"
}

# Function to output summary
print_summary() {
    echo "$1" | grep -i "ERROR" | wc -l | awk '{print "ERRORS: "$1}'
    echo "$1" | grep -i "WARNING" | wc -l | awk '{print "WARNINGS: "$1}'
    echo "$1" | grep -i "INFO" | wc -l | awk '{print "INFO: "$1}'
}

# Function to show top N messages
print_top() {
    echo "$1" | sort | uniq -c | sort -nr | head -n "$top_n"
}

# Run
filtered_logs=$(filter_logs)

if [[ -n "$output" ]]; then
    echo "$filtered_logs" > "$output"
else
    echo "$filtered_logs"
fi

if $summary; then
    echo
    echo "==== Summary ===="
    print_summary "$filtered_logs"
fi

if [[ "$top_n" -gt 0 ]]; then
    echo
    echo "==== Top $top_n Messages ===="
    print_top "$filtered_logs"
fi
