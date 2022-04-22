defmodule Descisionex.Helper do
  @moduledoc """
  Utility functions
  """

  def normalize(data, size) do
    summed_columns =
      Matrix.transpose(data)
      |> Enum.map(fn row -> Enum.sum(row) end)
      |> Enum.with_index()

    Enum.reduce(0..(size - 1), [], fn index, acc ->
      column =
        Enum.map(Enum.with_index(Enum.at(data, index)), fn {alternative, ind} ->
          {sum, _} = Enum.at(summed_columns, ind)
          Float.round(alternative / sum, 3)
        end)

      acc ++ [column]
    end)
  end

  def calculate_weights(data, size) do
    Enum.map(data, fn row ->
      [Float.round(Enum.sum(row) / size, 3)]
    end)
  end

  @spec avg(any, number) :: float
  def avg(row, size) do
    Float.round(Enum.sum(row) / size, 3)
  end

  def find_max_criteria(criteria) do
    criteria |> Enum.with_index() |> Enum.max()
  end

  def find_min_criteria(criteria) do
    criteria |> Enum.with_index() |> Enum.min()
  end
end
