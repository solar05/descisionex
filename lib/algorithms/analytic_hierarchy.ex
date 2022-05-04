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

  def set_criteria(%AnalyticHierarchy{} = _data, []) do
    raise ArgumentError, message: "Criteria must be not empty!"
  end

  @doc """
  Set criteria for analytic hierarchy.

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria([])
      ** (ArgumentError) Criteria must be not empty!
      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"])
      %Descisionex.AnalyticHierarchy{
        alternatives: [],
        alternatives_matrix: %{},
        alternatives_num: 0,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        normalized_comparison_matrix: []
      }

  """
  def set_criteria(%AnalyticHierarchy{} = data, criteria) do
    data |> Map.put(:criteria, criteria) |> Map.put(:criteria_num, Enum.count(criteria))
  end

  def set_alternatives(%AnalyticHierarchy{} = _data, []) do
    raise ArgumentError, message: "Alternatives must be not empty!"
  end

  @doc """
  Set alternatives for analytic hierarchy.

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_alternatives([])
      ** (ArgumentError) Alternatives must be not empty!
      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_alternatives(["some", "alternatives"])
      %Descisionex.AnalyticHierarchy{
        alternatives: ["some", "alternatives"],
        alternatives_matrix: %{},
        alternatives_num: 2,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [],
        criteria: [],
        criteria_num: 0,
        criteria_weights: [],
        normalized_comparison_matrix: []
      }

  """
  def set_alternatives(%AnalyticHierarchy{} = data, alternatives) do
    data
    |> Map.put(:alternatives, alternatives)
    |> Map.put(:alternatives_num, Enum.count(alternatives))
  end

  @doc """
  Set alternatives matrix for analytic hierarchy (criteria must be set!).

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{} |>  Descisionex.AnalyticHierarchy.set_alternatives_matrix([[1, 2], [3, 4]])
      ** (ArgumentError) Criteria must be set!
      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.set_alternatives_matrix([[1, 2], [3, 4]])
      %Descisionex.AnalyticHierarchy{
        alternatives: [],
        alternatives_matrix: %{"criteria" => [3, 4], "some" => [1, 2]},
        alternatives_num: 0,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        normalized_comparison_matrix: []
      }

  """
  def set_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    if data.criteria_num == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    tagged =
      Enum.map(Enum.with_index(data.criteria), fn {criteria, index} ->
        {criteria, Enum.at(matrix, index)}
      end)
      |> Enum.into(%{})

    data |> Map.put(:alternatives_matrix, tagged)
  end

  @doc """
  Normalizes comparison matrix for analytic hierarchy (criteria must be set, such as comparison matrix!).

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.normalize_comparison_matrix()
      ** (ArgumentError) Comparison matrix must be set!
      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.normalize_comparison_matrix()
      %Descisionex.AnalyticHierarchy{
        alternatives: [],
        alternatives_matrix: %{},
        alternatives_num: 0,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [[1, 2], [3, 4]],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        normalized_comparison_matrix: [[0.25, 0.333], [0.75, 0.667]]
      }

  """
  def normalize_comparison_matrix(%AnalyticHierarchy{} = data) do
    size = data.criteria_num

    if size == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    if data.comparison_matrix == [],
      do: raise(ArgumentError, message: "Comparison matrix must be set!")

    normalized = Helper.normalize(data.comparison_matrix, size)

    Map.put(data, :normalized_comparison_matrix, normalized)
  end

  @doc """
  Calculates weights for normalized comparison matrix for analytic hierarchy (criteria must be set, such as comparison matrix!).

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.calculate_criteria_weights()
      ** (ArgumentError) Comparison matrix must be normalized!
      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.normalize_comparison_matrix() |> Descisionex.AnalyticHierarchy.calculate_criteria_weights()
      %Descisionex.AnalyticHierarchy{
        alternatives: [],
        alternatives_matrix: %{},
        alternatives_num: 0,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [[1, 2], [3, 4]],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [[0.291], [0.709]],
        normalized_comparison_matrix: [[0.25, 0.333], [0.75, 0.667]]
      }

  """
  def calculate_criteria_weights(%AnalyticHierarchy{} = data) do
    size = data.criteria_num

    if size == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    if data.normalized_comparison_matrix == [],
      do: raise(ArgumentError, message: "Comparison matrix must be normalized!")

    criteria_weights = Helper.calculate_weights(data.normalized_comparison_matrix, size)

    Map.put(data, :criteria_weights, criteria_weights)
  end

  @doc """
  Calculates alternatives weights by criteria for analytic hierarchy (criteria must be set, such as comparison matrix!).

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights_by_criteria()
      ** (ArgumentError) Alternatives matrix must be set!
      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.set_alternatives(["some", "alternatives"]) |> Descisionex.AnalyticHierarchy.set_alternatives_matrix([[[1, 2, 3]], [[4, 5, 6]]]) |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights_by_criteria()
      %Descisionex.AnalyticHierarchy{
        alternatives: ["some", "alternatives"],
        alternatives_matrix: %{"criteria" => [[4, 5, 6]], "some" => [[1, 2, 3]]},
        alternatives_num: 2,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [[3.0, 3.0]],
        comparison_matrix: [],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        normalized_comparison_matrix: []
      }

  """
  def calculate_alternatives_weights_by_criteria(%AnalyticHierarchy{} = data) do
    if data.criteria_num == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    if data.alternatives_matrix == %{},
      do: raise(ArgumentError, message: "Alternatives matrix must be set!")

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

  @doc """
  Calculates alternatives weights for analytic hierarchy (criteria must be set, such as comparison matrix and weights before must be calculated!).

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.normalize_comparison_matrix() |> Descisionex.AnalyticHierarchy.set_alternatives(["some", "alternatives"]) |> Descisionex.AnalyticHierarchy.set_alternatives_matrix([[[1, 2, 3]], [[4, 5, 6]]]) |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights_by_criteria() |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights()
      ** (ArgumentError) Weights must be calculated before!
      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.normalize_comparison_matrix() |> Descisionex.AnalyticHierarchy.calculate_criteria_weights() |> Descisionex.AnalyticHierarchy.set_alternatives(["some", "alternatives"]) |> Descisionex.AnalyticHierarchy.set_alternatives_matrix([[[1, 2, 3]], [[4, 5, 6]]]) |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights_by_criteria() |> Descisionex.AnalyticHierarchy.calculate_alternatives_weights()
      %Descisionex.AnalyticHierarchy{
        alternatives: ["some", "alternatives"],
        alternatives_matrix: %{"criteria" => [[4, 5, 6]], "some" => [[1, 2, 3]]},
        alternatives_num: 2,
        alternatives_weights: [3.0],
        alternatives_weights_by_criteria: [[3.0, 3.0]],
        comparison_matrix: [[1, 2], [3, 4]],
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [[0.291], [0.709]],
        normalized_comparison_matrix: [[0.25, 0.333], [0.75, 0.667]]
      }

  """
  def calculate_alternatives_weights(%AnalyticHierarchy{} = data) do
    weights = data.criteria_weights

    if weights == [], do: raise(ArgumentError, message: "Weights must be calculated before!")

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
