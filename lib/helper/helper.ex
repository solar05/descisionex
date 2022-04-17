defmodule Descisionex.Helper do
  @moduledoc """
  Utility functions
  """

  def avg(row, size) do
    Float.round(Enum.sum(row) / size, 3)
  end

  def traverse_columns(size, matrix) do
    Enum.reduce(0..(size - 1), [], fn index, acc ->
      acc ++ [Enum.map(matrix, fn row -> Enum.at(row, index) end)]
    end)
  end
end
