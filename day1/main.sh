#!/usr/bin/env bash

# Enable bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
shopt -s inherit_errexit
IFS=$'\n\t'

calorie_totals() {
    local -r input_file="$1"

    local calorie_total=0

    while read -r line; do
        if [ "$line" = "" ]; then
            echo "$calorie_total "
            calorie_total=0
        else
            calorie_total=$((calorie_total + line))
        fi
    done <"$input_file"
}

part_one() {
    local -r input_file="$1"

    local best_total=0
    for total in $(calorie_totals "$input_file"); do
        if ((total > best_total)); then
            best_total=$total
        fi
    done

    echo "part one: $best_total"
}

part_two() {
    local -r input_file="$1"

    local sum=0
    for total in $(calorie_totals "$input_file" | sort -n | tail -3); do
        sum=$((sum + total))
    done

    echo "part two: $sum"
}

usage() {
    cat >/dev/stderr <<-EOF
Usage: ${0} [INPUT]

Advent of Code 2022: part one
EOF
}

main() {
    if [[ "$#" -lt 1 ]]; then
        usage
        exit 1
    fi

    local -r input_file="$1"

    part_one "$input_file"
    part_two "$input_file"
}

main "$@"
