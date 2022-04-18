defmodule DescisionexTest.AnalyticHierarchyTest do
  use ExUnit.Case

  alias Descisionex.AnalyticHierarchy

  @comparison_matrix [
    [1, 3, 1, 1 / 2, 5],
    [1 / 3, 1, 1 / 4, 1 / 7, 2],
    [1, 4, 1, 1, 6],
    [2, 7, 1, 1, 8],
    [1 / 5, 1 / 2, 1 / 6, 1 / 8, 1]
  ]

  @normalized_comparison_matrix [
    [0.221, 0.194, 0.293, 0.181, 0.227],
    [0.074, 0.065, 0.073, 0.052, 0.091],
    [0.221, 0.258, 0.293, 0.361, 0.273],
    [0.441, 0.452, 0.293, 0.361, 0.364],
    [0.044, 0.032, 0.049, 0.045, 0.045]
  ]

  @weights [
    [0.223],
    [0.071],
    [0.281],
    [0.382],
    [0.043]
  ]

  @alternatives_weights_by_criteria [
    [0.334, 0.32, 0.387, 0.299, 0.383],
    [0.098, 0.557, 0.443, 0.601, 0.073],
    [0.568, 0.123, 0.17, 0.1, 0.543]
  ]

  @alternatives_matrix %{
    "category" => [[1, 2, 4], [0.5, 1, 0.16666666666666666], [5, 6, 1]],
    "place" => [[1, 0.3333333333333333, 4], [3, 1, 4], [0.25, 0.2, 1]],
    "price" => [[1, 4, 0.5], [0.25, 1, 0.2], [2, 5, 1]],
    "rooms" => [[1, 1, 2], [1, 1, 3], [0.5, 0.3333333333333333, 1]],
    "size" => [[1, 0.5, 3], [2, 1, 4], [0.3333333333333333, 0.25, 1]]
  }

  @alternatives_weights [0.336, 0.41900000000000004, 0.245]

  test "normalizes comparison matrix" do
    hierarchy = setup_hierarchy()
    result = hierarchy |> AnalyticHierarchy.normalize_comparison_matrix()

    assert @normalized_comparison_matrix == result.normalized_comparison_matrix
  end

  test "calculates criteria weights" do
    hierarchy = setup_normalized_hierarchy()
    result = hierarchy |> AnalyticHierarchy.calculate_criteria_weights()

    assert @weights == result.criteria_weights
  end

  test "sets alternatives matrix" do
    hierarchy = setup_normalized_hierarchy()

    result = hierarchy |> AnalyticHierarchy.set_alternatives_matrix(alternatives_matrix())

    assert @alternatives_matrix == result.alternatives_matrix
  end

  test "calculates alternatives weights by criteria" do
    hierarchy = setup_hierarchy_with_alternatives()

    result = hierarchy |> AnalyticHierarchy.calculate_alternatives_weights_by_criteria()

    assert @alternatives_weights_by_criteria == result.alternatives_weights_by_criteria
  end

  test "calculate alternatives weights" do
    hierarchy =
      setup_hierarchy_with_alternatives()
      |> AnalyticHierarchy.calculate_criteria_weights()
      |> AnalyticHierarchy.calculate_alternatives_weights_by_criteria()

    result = hierarchy |> AnalyticHierarchy.calculate_alternatives_weights()

    assert @alternatives_weights == result.alternatives_weights
    assert 1.0 == Enum.sum(result.alternatives_weights)
  end

  def alternatives_matrix() do
    price = [[1, 4, 1 / 2], [1 / 4, 1, 1 / 5], [2, 5, 1]]
    size = [[1, 1 / 2, 3], [2, 1, 4], [1 / 3, 1 / 4, 1]]
    rooms = [[1, 1, 2], [1, 1, 3], [1 / 2, 1 / 3, 1]]
    place = [[1, 1 / 3, 4], [3, 1, 4], [1 / 4, 1 / 5, 1]]
    category = [[1, 2, 4], [1 / 2, 1, 1 / 6], [5, 6, 1]]

    [price, size, rooms, place, category]
  end

  def setup_hierarchy() do
    %AnalyticHierarchy{comparison_matrix: @comparison_matrix}
    |> AnalyticHierarchy.set_alternatives(["apartment1", "apartment2", "apartment3"])
    |> AnalyticHierarchy.set_criteria(["price", "size", "rooms", "place", "category"])
  end

  def setup_normalized_hierarchy() do
    setup_hierarchy() |> AnalyticHierarchy.normalize_comparison_matrix()
  end

  def setup_hierarchy_with_alternatives do
    setup_normalized_hierarchy()
    |> AnalyticHierarchy.set_alternatives_matrix(alternatives_matrix())
  end
end
