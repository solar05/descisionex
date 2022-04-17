defmodule Descisionex.AnalyticHierarchy do
  @moduledoc """
  https://en.wikipedia.org/wiki/Analytic_hierarchy_process
  """

  alias Descisionex.{AnalyticHierarchy, Helper}

  defstruct comparison_matrix: [],
            normalized_matrix: [],
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
    size = data.criteria_num

    summed_columns =
      Helper.traverse_columns(size, data.comparison_matrix)
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

    Map.put(data, :normalized_matrix, normalized)
  end

  def calculate_weights(%AnalyticHierarchy{} = data) do
    size = data.criteria_num

    weighting_criteria =
      Enum.map(data.normalized_matrix, fn row ->
        [Float.round(Enum.sum(row) / size, 3)]
      end)

    Map.put(data, :weighting_criteria, weighting_criteria)
  end
end
