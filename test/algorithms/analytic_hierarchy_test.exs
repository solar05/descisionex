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

  test "normalizes alternatives" do
    hierarchy = setup_hierarchy()
    result = hierarchy |> AnalyticHierarchy.normalize_comparison_matrix()

    assert @normalized_comparison_matrix == result.normalized_comparison_matrix
  end

  test "calculates weight criteria" do
    hierarchy = setup_normalized_hierarchy()
    result = hierarchy |> AnalyticHierarchy.calculate_criteria_weights()

    assert @weights == result.criteria_weights
  end

  def setup_hierarchy() do
    %AnalyticHierarchy{comparison_matrix: @comparison_matrix}
    |> AnalyticHierarchy.set_alternatives(["apartment1", "apartment2", "apartment3"])
    |> AnalyticHierarchy.set_criteria(["price", "size", "rooms", "place", "category"])
  end

  def setup_normalized_hierarchy() do
    setup_hierarchy() |> AnalyticHierarchy.normalize_comparison_matrix()
  end
end
