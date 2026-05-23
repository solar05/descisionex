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
            criteria: [],
            consistency_index: nil,
            consistency_ratio: nil,
            lambda_max: nil

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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        lambda_max: nil,
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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: [],
        criteria_num: 0,
        criteria_weights: [],
        lambda_max: nil,
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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        lambda_max: nil,
        normalized_comparison_matrix: []
      }

  """
  def set_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    if data.criteria_num == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    if Enum.count(matrix) != data.criteria_num,
      do:
        raise(ArgumentError,
          message: "Matrix row count must equal criteria count (#{data.criteria_num})!"
        )

    tagged =
      Enum.map(Enum.with_index(data.criteria), fn {criteria, index} ->
        {criteria, Enum.at(matrix, index)}
      end)
      |> Enum.into(%{})

    data |> Map.put(:alternatives_matrix, tagged)
  end

  @doc """
  Set pre-tagged alternatives matrix for analytic hierarchy (criteria must be set!).
  The map keys must correspond to criteria names.

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_tagged_alternatives_matrix(%{"a" => [1, 2]})
      ** (ArgumentError) Criteria must be set!
      iex> %Descisionex.AnalyticHierarchy{} |> Descisionex.AnalyticHierarchy.set_criteria(["a", "b"]) |> Descisionex.AnalyticHierarchy.set_tagged_alternatives_matrix(%{"a" => [1, 2], "b" => [3, 4]})
      %Descisionex.AnalyticHierarchy{
        alternatives: [],
        alternatives_matrix: %{"a" => [1, 2], "b" => [3, 4]},
        alternatives_num: 0,
        alternatives_weights: [],
        alternatives_weights_by_criteria: [],
        comparison_matrix: [],
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["a", "b"],
        criteria_num: 2,
        criteria_weights: [],
        lambda_max: nil,
        normalized_comparison_matrix: []
      }

  """
  def set_tagged_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    if data.criteria_num == 0, do: raise(ArgumentError, message: "Criteria must be set!")
    if matrix == [] || matrix == %{}, do: raise(ArgumentError, message: "Incorrect matrix!")

    data |> Map.put(:alternatives_matrix, matrix)
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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        lambda_max: nil,
        normalized_comparison_matrix: [[0.25, 0.333], [0.75, 0.667]]
      }

  """
  def normalize_comparison_matrix(%AnalyticHierarchy{} = data) do
    size = data.criteria_num

    if size == 0, do: raise(ArgumentError, message: "Criteria must be set!")

    if data.comparison_matrix == [],
      do: raise(ArgumentError, message: "Comparison matrix must be set!")

    if Enum.count(data.comparison_matrix) != size,
      do:
        raise(ArgumentError,
          message: "Comparison matrix dimensions must match criteria count (#{size}x#{size})!"
        )

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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [[0.291], [0.709]],
        lambda_max: nil,
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
  Calculates the consistency ratio (CR) of the comparison matrix.
  CR < 0.1 indicates acceptable consistency. Requires criteria weights to be calculated first.

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.calculate_consistency_ratio()
      ** (ArgumentError) Criteria weights must be calculated before consistency ratio!

  """
  def calculate_consistency_ratio(%AnalyticHierarchy{} = data) do
    if data.criteria_weights == [],
      do:
        raise(ArgumentError,
          message: "Criteria weights must be calculated before consistency ratio!"
        )

    n = data.criteria_num
    weights = Enum.map(data.criteria_weights, fn [w] -> w end)
    matrix = data.comparison_matrix

    lambda_values =
      matrix
      |> Enum.with_index()
      |> Enum.map(fn {row, i} ->
        dot = Enum.zip(row, weights) |> Enum.map(fn {a, w} -> a * w end) |> Enum.sum()
        dot / Enum.at(weights, i)
      end)

    lambda_max = Enum.sum(lambda_values) / n
    ci = (lambda_max - n) / (n - 1)
    ri = random_index(n)
    cr = if ri == 0.0, do: 0.0, else: ci / ri

    data
    |> Map.put(:lambda_max, Float.round(lambda_max, 3))
    |> Map.put(:consistency_index, Float.round(ci, 3))
    |> Map.put(:consistency_ratio, Float.round(cr, 3))
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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [],
        lambda_max: nil,
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
        consistency_index: nil,
        consistency_ratio: nil,
        criteria: ["some", "criteria"],
        criteria_num: 2,
        criteria_weights: [[0.291], [0.709]],
        lambda_max: nil,
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

  @doc """
  Runs the full AHP pipeline: normalize comparison matrix, calculate criteria weights,
  consistency ratio, alternatives weights by criteria, and final alternatives weights.
  Requires comparison_matrix, criteria, alternatives, and alternatives_matrix to be set beforehand.

  ## Examples

      iex> %Descisionex.AnalyticHierarchy{comparison_matrix: [[1, 2], [3, 4]]} |> Descisionex.AnalyticHierarchy.set_criteria(["some", "criteria"]) |> Descisionex.AnalyticHierarchy.set_alternatives(["alt1", "alt2"]) |> Descisionex.AnalyticHierarchy.set_alternatives_matrix([[[1, 2], [2, 1]], [[3, 1], [1, 3]]]) |> Descisionex.AnalyticHierarchy.calculate() |> Map.get(:alternatives_weights) |> Enum.sum() |> Float.round(2)
      1.0

  """
  def calculate(%AnalyticHierarchy{} = data) do
    data
    |> normalize_comparison_matrix()
    |> calculate_criteria_weights()
    |> calculate_consistency_ratio()
    |> calculate_alternatives_weights_by_criteria()
    |> calculate_alternatives_weights()
  end

  # Random Consistency Index values for matrices of size 1–10 (Saaty, 1980)
  @random_index %{1 => 0.00, 2 => 0.00, 3 => 0.58, 4 => 0.90, 5 => 1.12,
                  6 => 1.24, 7 => 1.32, 8 => 1.41, 9 => 1.45, 10 => 1.49}

  defp random_index(n), do: Map.get(@random_index, n, 1.49)
end
