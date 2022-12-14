defmodule Point do
  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def parse(x: x, y: y) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    %__MODULE__{x: x, y: y}
  end
end

defmodule RockPath do
  def parse(line) when is_binary(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn s -> String.split(s, ",") end)
    |> parse
    |> fill
    |> MapSet.new()
  end

  def parse([[x, y] | rest]) do
    [Point.parse(x: x, y: y) | parse(rest)]
  end

  def parse([]) do
    []
  end

  # "Fills in the gaps" of a path, so each point steps by one.
  def fill([%Point{} = p0, %Point{} = p1]) do
    fill(p0, p1)
  end

  def fill([%Point{} = p0, %Point{} = p1 | tail]) do
    Enum.drop(fill(p0, p1), -1) ++ fill([p1 | tail])
  end

  def fill([]) do
    []
  end

  def fill(%Point{x: x, y: start}, %Point{x: xx, y: stop}) when x == xx do
    Enum.map(start..stop, fn y -> %Point{x: x, y: y} end)
  end

  def fill(%Point{x: start, y: y}, %Point{x: stop, y: yy}) when y == yy do
    Enum.map(start..stop, fn x -> %Point{x: x, y: y} end)
  end
end

defmodule PartOne do
  defp pour_start() do
    %Point{x: 500, y: 0}
  end

  defp pour_sand(abyss_start, blocking) do
    pour_sand(abyss_start, blocking, MapSet.new(), pour_start())
  end

  defp pour_sand(abyss_start, _blocking, sand, %Point{} = point)
       when point.y >= abyss_start do
    sand
  end

  defp pour_sand(abyss_start, blocking, sand, %Point{} = point) do
    not_blocked? = fn p -> !MapSet.member?(blocking, p) end

    below = %Point{x: point.x, y: point.y + 1}
    below_left = %Point{x: point.x - 1, y: below.y}
    below_right = %Point{x: point.x + 1, y: below.y}

    cond do
      not_blocked?.(below) ->
        pour_sand(abyss_start, blocking, sand, below)

      not_blocked?.(below_left) ->
        pour_sand(abyss_start, blocking, sand, below_left)

      not_blocked?.(below_right) ->
        pour_sand(abyss_start, blocking, sand, below_right)

      true ->
        pour_sand(abyss_start, MapSet.put(blocking, point), MapSet.put(sand, point), pour_start())
    end
  end

  def solve(rock_paths) do
    blocking =
      Enum.reduce(rock_paths, MapSet.new(), fn rock_path, acc -> MapSet.union(acc, rock_path) end)

    blocking_max_y =
      Enum.reduce(blocking, MapSet.new(), fn %Point{y: y}, acc -> MapSet.put(acc, y) end)
      |> Enum.max()

    abyss_start = blocking_max_y

    pour_sand(abyss_start, blocking)
    |> MapSet.size()
  end
end

defmodule PartTwo do
  @pour_start_x 500
  @pour_start_y 0

  defp pour_start() do
    %Point{x: @pour_start_x, y: @pour_start_y}
  end

  defp pour_sand(bottom, blocking) do
    pour_sand(bottom, blocking, MapSet.new(), pour_start())
  end

  defp pour_sand(bottom, blocking, sand, %Point{} = point) do
    not_blocked? = fn p -> p.y < bottom and !MapSet.member?(blocking, p) end

    below = %Point{x: point.x, y: point.y + 1}
    below_left = %Point{x: point.x - 1, y: below.y}
    below_right = %Point{x: point.x + 1, y: below.y}

    cond do
      not_blocked?.(below) ->
        pour_sand(bottom, blocking, sand, below)

      not_blocked?.(below_left) ->
        pour_sand(bottom, blocking, sand, below_left)

      not_blocked?.(below_right) ->
        pour_sand(bottom, blocking, sand, below_right)

      point.x == @pour_start_x and point.y == @pour_start_y ->
        MapSet.put(sand, point)

      true ->
        pour_sand(bottom, MapSet.put(blocking, point), MapSet.put(sand, point), pour_start())
    end
  end

  def solve(rock_paths) do
    blocking =
      Enum.reduce(rock_paths, MapSet.new(), fn rock_path, acc -> MapSet.union(acc, rock_path) end)

    blocking_max_y =
      Enum.reduce(blocking, MapSet.new(), fn %Point{y: y}, acc -> MapSet.put(acc, y) end)
      |> Enum.max()

    bottom = blocking_max_y + 2

    pour_sand(bottom, blocking)
    |> MapSet.size()
  end
end

defmodule Main do
  def main([input_file]) do
    {:ok, input} = File.read(input_file)

    rock_paths =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> RockPath.parse(line) end)

    part_one_answer = 610 = PartOne.solve(rock_paths)
    IO.puts("part one: #{part_one_answer}")

    part_two_answer = 27194 = PartTwo.solve(rock_paths)
    IO.puts("part two: #{part_two_answer}")
  end
end

Main.main(System.argv())
