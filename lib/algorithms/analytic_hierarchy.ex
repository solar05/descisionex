defmodule Descisionex.AnalyticHierarchy do
  @moduledoc """
  https://en.wikipedia.org/wiki/Analytic_hierarchy_process
  """

  alias Descisionex.{AnalyticHierarchy, Helper}

  defstruct comparison_matrix: [],
            normalized_comparison_matrix: [],
            criteria_weights: [],
            criteria_num: 0,
            alternatives: [],
            alternatives_matrix: %{},
            alternatives_weights: [],
            alternatives_weights_by_criteria: [],
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

  def set_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    tagged =
      Enum.map(Enum.with_index(data.criteria), fn {criteria, index} ->
        {criteria, Enum.at(matrix, index)}
      end)
      |> Enum.into(%{})

    data |> Map.put(:alternatives_matrix, tagged)
  end

  def normalize_comparison_matrix(%AnalyticHierarchy{} = data) do
    size = data.criteria_num

    normalized = Helper.normalize(data.comparison_matrix, size)

    Map.put(data, :normalized_comparison_matrix, normalized)
  end

  def calculate_criteria_weights(%AnalyticHierarchy{} = data) do
    size = data.criteria_num
    criteria_weights = Helper.calculate_weights(data.normalized_comparison_matrix, size)

    Map.put(data, :criteria_weights, criteria_weights)
  end

  def calculate_alternatives_weights_by_criteria(%AnalyticHierarchy{} = data) do
    alternatives_weights_by_criteria =
      Enum.map(data.criteria, fn criteria ->
        matrix = data.alternatives_matrix[criteria]
        size = Enum.count(matrix)

        weights =
          matrix
          |> Helper.normalize(size)
          |> Helper.calculate_weights(size)

        weights
      end)

    result = alternatives_weights_by_criteria |> Matrix.transpose() |> Enum.map(&List.flatten/1)

    Map.put(data, :alternatives_weights_by_criteria, result)
  end

  def calculate_alternatives_weights(%AnalyticHierarchy{} = data) do
    weights = data.criteria_weights

    alternatives_weights =
      Enum.reduce(data.alternatives_weights_by_criteria, [], fn column, acc ->
        product =
          Enum.map(Enum.with_index(column), fn {number, index} ->
            [weight | _] = Enum.at(weights, index)
            Float.round(number * weight, 3)
          end)
          |> Enum.sum()

        acc ++ [product]
      end)

    Map.put(data, :alternatives_weights, alternatives_weights)
  end
end
