defmodule Descisionex.Helper do
  @moduledoc """
  Utility functions
  """

  @doc """
  Normalizes matrix.

  ## Examples

      iex> matrix = [[1, 2], [3, 4], [0, 1]]
      iex> size = 3 # matrix rows
      iex> Descisionex.Helper.normalize(matrix, size)
      [[0.25, 0.286], [0.75, 0.571], [0.0, 0.143]]

  """
  @spec normalize([[number]], integer) :: any
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

  @doc """
  Calculate weights for matrix rows.

  ## Examples

      iex> matrix = [[1, 2], [3, 4], [0, 1]]
      iex> size = 2 # matrix row elements count
      iex> Descisionex.Helper.calculate_weights(matrix, size)
      [[1.5], [3.5], [0.5]]

  """
  @spec calculate_weights(any, any) :: list
  def calculate_weights(data, size) do
    Enum.map(data, fn row ->
      [Float.round(Enum.sum(row) / size, 3)]
    end)
  end

  @doc """
  Average number for matrix row.

  ## Examples

      iex> matrix = [[1, 2], [3, 4], [0, 1]]
      iex> Enum.map(matrix, fn row -> Descisionex.Helper.avg(row, 2) end)
      [1.5, 3.5, 0.5]

  """
  @spec avg(any, number) :: float
  def avg(row, size) do
    Float.round(Enum.sum(row) / size, 3)
  end

  @doc """
  Find maximal criteria (row) in matrix (with index).

  ## Examples

      iex> matrix = [[1, 2], [3, 4], [0, 1]]
      iex> Descisionex.Helper.find_max_criteria(matrix)
      {[3, 4], 1}

  """
  @spec find_max_criteria(any) :: any
  def find_max_criteria(criteria) do
    criteria |> Enum.with_index() |> Enum.max()
  end

  @doc """
  Find minimal criteria (row) in matrix (with index).

  ## Examples

      iex> matrix = [[1, 2], [3, 4], [0, 1]]
      iex> Descisionex.Helper.find_min_criteria(matrix)
      {[0, 1], 2}

  """
  @spec find_min_criteria(any) :: any
  def find_min_criteria(criteria) do
    criteria |> Enum.with_index() |> Enum.min()
  end

  @doc """
  Matrix rounding to 3 numbers.

  ## Examples

      iex> matrix = [[1/3, 2/3], [4/5, 5/6]]
      iex> Descisionex.Helper.round_matrix(matrix)
      [[0.333, 0.667], [0.8, 0.833]]

  """
  @spec round_matrix([[number]]) :: list
  def round_matrix(matrix) do
    Enum.map(matrix, fn row -> Enum.map(row, fn element -> Float.round(element, 3) end) end)
  end
end
