#!/usr/bin/env julia

priorities = merge(
    # Lowercase item types a through z have priorities 1 through 26.
    Dict(c => p for (c, p) in zip('a':'z', 1:26)),
    # Uppercase item types A through Z have priorities 27 through 52.
    Dict(c => p for (c, p) in zip('A':'Z', 27:52)),
)

function part_one(input_file)
    priority_sum = 0

    for line in eachline(input_file)
        # A given rucksack always has the same number of items in each of its two compartments,
        # so the first half of the characters represent items in the first compartment,
        # while the second half of the characters represent items in the second compartment.
        line_length = length(line)
        middle = div(line_length, 2)
        first_compartment = @view line[1:middle]
        second_compartment = @view line[middle+1:end]
        @assert length(first_compartment) == length(second_compartment) "compartment lengths differ!"

        common_items = intersect(Set(first_compartment), Set(second_compartment))
        for item in common_items
            priority_sum += priorities[item]
        end
    end

    priority_sum
end

function part_two(input_file)
    priority_sum = 0

    for bags in Iterators.partition(eachline(input_file), 3)
        # For efficiency, within each group of three Elves,
        # the badge is the only item type carried by all three Elves.
        badges = intersect(Set(bags[1]), Set(bags[2]), Set(bags[3]))
        @assert length(badges) == 1 "too many badges found!"

        (item,) = badges
        priority_sum += priorities[item]
    end

    priority_sum
end

function main(args)
    input_file = args[1]

    part_one_answer = part_one(input_file)
    @assert part_one_answer == 7553 "wrong answer!"
    println("part one: ", part_one_answer)

    part_two_answer = part_two(input_file)
    @assert part_two_answer == 2758 "wrong answer!"
    println("part two: ", part_two_answer)
end

main(ARGS)
