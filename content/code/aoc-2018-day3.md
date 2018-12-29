---
title: "Advent of Code 2018 Day 3"
date: 2018-12-14T00:11:35+08:00
draft: false
---

This solution turned out much longer and even more complicated than I had hoped it would. My solutions for previous days involved pipelines of Enum functions and I purposely avoided going that route as they looked less intelligible with every additional line of anonymous iteration. I had hoped writing around "names" ala OOP would lend to a shorter and far more readable code. BurntSushi's [elegant implementation in Rust](https://github.com/BurntSushi/advent-of-code/blob/master/aoc03/src/main.rs) seemed ideal. However, the clarity of having names to code around quickly diluted with writing custom type boilerplate and this also due to Elixir having no actual types. Where the Rust implementation had names referring to vector types, my implementation has structs for names which are basically maps and so much of the code was working around (I would even say, against, in hindsight) this limitation -- where I really wanted a list I got a list inside a map.

```elixir
defmodule Grid do
  defstruct grid: %{}

  defimpl Collectable do
    def into(grid) do
      {grid.grid,
       fn
         acc, {:cont, {row, col}} ->
           into_grid(acc, {Integer.to_string(row), Integer.to_string(col)})

         acc, :done ->
           %{grid | grid: Map.merge(grid.grid, acc)}

         acc, :halt ->
           %{grid | grid: Map.merge(grid.grid, acc)}
       end}
    end

    defp into_grid(acc, {row, col}) do
      if Map.has_key?(acc, row) do
        Map.update!(acc, row, &Map.update(&1, col, 1, fn v -> v + 1 end))
      else
        Map.put(acc, row, Map.put(%{}, col, 1))
      end
    end
  end

  defimpl Enumerable do
    def reduce(%{grid: map}, acc, fun) do
      reduce_list(:maps.to_list(map), acc, fun)
    end

    defp reduce_list(_list, {:halt, acc}, _fun), do: {:halted, acc}

    defp reduce_list(list, {:suspend, acc}, fun),
      do: {:suspended, acc, &reduce_list(list, &1, fun)}

    defp reduce_list([], {:cont, acc}, _fun), do: {:done, acc}

    defp reduce_list([head | tail], {:cont, acc}, fun),
      do: reduce_list(tail, fun.(head, acc), fun)
  end
end

defmodule Disputed do
  def count(input) do
    input
    |> Claims.from_input()
    # claims to enumerable streams
    |> Enum.map(&Claims.stream/1)
    # pipe claim entries to grid
    |> Enum.reduce(%Grid{}, &Enum.into/2)
    # reduce streams to disputed tiles count
    |> Enum.reduce(0, &count_disputed_tiles/2)
  end

  defp count_disputed_tiles({_, col}, acc) do
    acc + Enum.count(col, fn {_, v} -> v > 1 end)
  end
end

defmodule Claims do
  defstruct id: nil,
            x: nil,
            y: nil,
            width: nil,
            height: nil

  @claims_pattern ~r{#(?<id>[0-9]+)\s+@\s+(?<x>[0-9]+),(?P<y>[0-9]+):\s+(?<w>[0-9]+)x(?<h>[0-9]+)}

  def from_input(file) do
    file
    |> File.stream!()
    |> Enum.map(&parse/1)
  end

  def stream(%__MODULE__{x: x, y: y, width: w, height: h}) do
    {x, y}
    |> Stream.iterate(fn {x_, y_} ->
      if x_ + 1 < x + w do
        {x_ + 1, y_}
      else
        {x, y_ + 1}
      end
    end)
    |> Stream.take_while(fn {x_, y_} ->
      x_ < x + w && y_ < y + h
    end)
  end

  defp parse(string) do
    names =
      @claims_pattern
      |> Regex.named_captures(String.trim(string))
      |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)

    struct(
      __MODULE__,
      id: names[:id],
      x: names[:x],
      y: names[:y],
      width: names[:w],
      height: names[:h]
    )
  end
end
```

Jose Valim's super short if not equally (as BurntSushi's) elegant implementation, for comparison. It's concise and readable, despite the nested `Enum.reduce` expressions in the `claimed_inches` function. In the hands of lesser programmers' this approach would have 

(types and doctests redacted)

```elixir
defmodule Day3 do
  def parse_claim(string) when is_binary(string) do
    string
    |> String.split(["#", "@", ",", ":", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def claimed_inches(claims) do
    Enum.reduce(claims, %{}, fn claim, acc -> 
      [id, left, top, width, height] = parse_claim(claim)
    
      Enum.reduce (left+1)..(left+ width), acc, fn x, acc ->
        Enum.reduce (top+1)..(top+height), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &([id | &1]))
        end
      end
    end)
  end

  def overlapped_inches(claims) do
    for {coordinate, [_, _ | _]} <- claimed_inches(claims) do
      coordinate
    end
  end
end
```