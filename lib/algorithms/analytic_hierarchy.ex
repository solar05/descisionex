defmodule Descisionex.AnalyticHierarchy do
  @moduledoc """
  https://en.wikipedia.org/wiki/Analytic_hierarchy_process
  """

  alias Descisionex.AnalyticHierarchy

  defstruct comparison_matrix: [],
            with_mean: [],
            normalized: [],
            weighting_criteria: [],
            criteria_num: 0,
            alternatives: [],
            alternatives_num: 0,
            criteria: []

  def set_criteria(%AnalyticHierarchy{} = data, criteria) do
    data |> Map.put(:criteria, criteria) |> Map.put(:criteria_num, Enum.count(criteria))
  end

  def set_alternatives(%AnalyticHierarchy{} = data, alternatives) do
    data
    |> Map.put(:alternatives, alternatives)
    |> Map.put(:alternatives_num, Enum.count(alternatives))
  end

  def normalize(%AnalyticHierarchy{} = data) do
    size = data.alternatives_num

    summed_columns =
      traverse_columns(size, data.comparison_matrix)
      |> Enum.map(fn row -> Enum.sum(row) end)
      |> Enum.with_index()

    normalized =
      Enum.reduce(0..(size - 1), [], fn index, acc ->
        column =
          Enum.map(Enum.with_index(Enum.at(data.comparison_matrix, index)), fn {alternative, ind} ->
            {sum, _} = Enum.at(summed_columns, ind)
            Float.round(alternative / sum, 3)
          end)

        acc ++ [column]
      end)

    Map.put(data, :normalized, normalized)
  end

  def calculate_mean(%AnalyticHierarchy{} = data) do
    data
  end

  defp avg(row, size) do
    Float.round(Enum.sum(row) / size, 3)
  end

  defp traverse_columns(size, matrix) do
    Enum.reduce(0..(size - 1), [], fn index, acc ->
      acc ++ [Enum.map(matrix, fn row -> Enum.at(row, index) end)]
    end)
  end
end
