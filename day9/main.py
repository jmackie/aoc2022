#!/usr/bin/env python3

"""
Advent of Code 2022: part nine
"""

import argparse
import sys
from collections import namedtuple
from typing import NamedTuple, Optional
from enum import Enum
from functools import reduce


class Direction(Enum):
    R = 1
    U = 2
    D = 3
    L = 4

    @classmethod
    def parse(cls, str):
        assert str in ["R", "U", "D", "L"]
        if str == "R":
            return cls.R
        if str == "U":
            return cls.U
        if str == "D":
            return cls.D
        if str == "L":
            return cls.L

    def __str__(self):
        return f"{self.name}"


class Move:
    direction: Direction
    count: int

    def __init__(self, *, direction, count):
        self.direction = direction
        self.count = count

    @classmethod
    def parse(cls, line):
        raw_direction, raw_count = line.split()
        direction = Direction.parse(raw_direction)
        count = int(raw_count)
        return cls(direction=direction, count=count)

    def __str__(self):
        return f"{self.direction} {self.count}"


class Point(NamedTuple):
    x: int
    y: int

    @classmethod
    def origin(cls):
        return cls(x=0, y=0)

    def right(self, n: int):
        return Point(x=self.x + n, y=self.y)

    def left(self, n: int):
        return Point(x=self.x - n, y=self.y)

    def up(self, n: int):
        return Point(x=self.x, y=self.y + n)

    def down(self, n: int):
        return Point(x=self.x, y=self.y - n)


def close_points(p0: Point, p1: Point) -> Point:
    """
    Brings two points `p0` and `p1` together, given the logic defined in today's problem.
    """
    x_diff = p0.x - p1.x
    y_diff = p0.y - p1.y

    touching = x_diff in range(-1, 2) and y_diff in range(-1, 2)
    if touching:
        return p1

    if y_diff == 0:
        x_diff = x_diff - 1 if x_diff > 0 else x_diff + 1
        return Point(x=p1.x + x_diff, y=p1.y)

    if x_diff == 0:
        y_diff = y_diff - 1 if y_diff > 0 else y_diff + 1
        return Point(x=p1.x, y=p1.y + y_diff)

    x_diff = x_diff - 1 or 1 if x_diff > 0 else x_diff + 1 or -1
    y_diff = y_diff - 1 or 1 if y_diff > 0 else y_diff + 1 or -1
    return Point(x=p1.x + x_diff, y=p1.y + y_diff)


class Rope:
    knots: list[Point]

    def __init__(self, knots):
        self.knots = knots

    @classmethod
    def initial(cls, *, n_knots):
        return cls(knots=[Point.origin() for _ in range(n_knots)])

    def move_head(self, move: Move):
        head, *tail = self.knots

        if move.direction == Direction.R:
            head = head.right(move.count)
        if move.direction == Direction.U:
            head = head.up(move.count)
        if move.direction == Direction.L:
            head = head.left(move.count)
        if move.direction == Direction.D:
            head = head.down(move.count)

        return Rope(
            reduce(
                lambda knots, knot: [*knots, close_points(knots[-1], knot)],
                tail,
                [head],
            )
        )


def solve_for(input_file: str, n_knots: int) -> int:
    states = [Rope.initial(n_knots=n_knots)]
    with open(input_file, "r") as input:
        for line in input.readlines():
            move = Move.parse(line)
            for _ in range(move.count):
                rope = states[-1]
                new_state = rope.move_head(Move(direction=move.direction, count=1))
                states.append(new_state)

    return len({rope.knots[-1] for rope in states})


def part_one(input_file: str) -> int:
    return solve_for(input_file, 2)


def part_two(input_file: str) -> int:
    return solve_for(input_file, 10)


def main(argv=()):
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("input")
    args = cli.parse_args(argv)

    part_one_answer = part_one(args.input)
    assert part_one_answer == 6464
    print("part one:", part_one_answer)

    part_two_answer = part_two(args.input)
    assert part_two_answer == 2604
    print("part two:", part_two_answer)


if __name__ == "__main__":
    main(argv=sys.argv[1:])
