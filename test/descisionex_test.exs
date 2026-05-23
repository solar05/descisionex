defmodule DescisionexTest do
  use ExUnit.Case
  doctest Descisionex

  alias Descisionex.{PaymentMatrix, AnalyticHierarchy}

  @matrix [
    [0.221, 0.194, 0.293, 0.181, 0.227],
    [0.074, 0.065, 0.073, 0.052, 0.091],
    [0.221, 0.258, 0.293, 0.361, 0.273],
    [0.441, 0.452, 0.293, 0.361, 0.364],
    [0.044, 0.032, 0.049, 0.045, 0.045]
  ]

  @comparison_matrix [
    [1, 3, 1, 1 / 2, 5],
    [1 / 3, 1, 1 / 4, 1 / 7, 2],
    [1, 4, 1, 1, 6],
    [2, 7, 1, 1, 8],
    [1 / 5, 1 / 2, 1 / 6, 1 / 8, 1]
  ]

  # --- PaymentMatrix facade ---

  test "facade: payment_matrix/1 returns PaymentMatrix struct" do
    result = Descisionex.payment_matrix(@matrix)
    assert %PaymentMatrix{} = result
    assert result.matrix == @matrix
  end

  test "facade: calculate_wald_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.calculate_wald_criterion()

    assert result.wald_criterion.strategy_index == 3
  end

  test "facade: calculate_laplace_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_criteria(["v1", "v2", "v3", "v4", "v5"])
      |> Descisionex.calculate_laplace_criterion()

    assert result.laplace_criterion.strategy_index == 3
  end

  test "facade: calculate_savage_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.calculate_savage_criterion()

    assert result.savage_criterion.strategy_index == 3
  end

  test "facade: calculate_hurwitz_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.calculate_hurwitz_criterion()

    assert result.hurwitz_criterion.strategy_index == 3
  end

  test "facade: set_hurwitz_additional_value delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_hurwitz_additional_value(0.8)

    assert result.hurwitz_additional_value == 0.8
  end

  test "facade: calculate_generalized_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.calculate_generalized_criterion()

    assert result.generalized_criterion.strategy_index == 4
  end

  test "facade: set_generalized_additional_value delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_generalized_additional_value(0.7)

    assert result.generalized_additional_value == 0.7
  end

  test "facade: set_probabilities delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_probabilities([0.2, 0.2, 0.2, 0.2, 0.2])

    assert result.probabilities == [0.2, 0.2, 0.2, 0.2, 0.2]
  end

  test "facade: calculate_bayes_criterion delegates to PaymentMatrix" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_probabilities([0.2, 0.2, 0.2, 0.2, 0.2])
      |> Descisionex.calculate_bayes_criterion()

    assert result.bayes_criterion.strategy_index == 3
  end

  test "facade: calculate_criteria runs all criteria" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_criteria(["v1", "v2", "v3", "v4", "v5"])
      |> Descisionex.calculate_criteria()

    assert result.wald_criterion != %{}
    assert result.savage_criterion != %{}
    assert result.laplace_criterion != %{}
    assert result.hurwitz_criterion != %{}
    assert result.generalized_criterion != %{}
  end

  test "facade: set_alternatives delegates to PaymentMatrix as set_steps" do
    result =
      Descisionex.payment_matrix(@matrix)
      |> Descisionex.set_alternatives(["s0", "s1", "s2", "s3", "s4"])

    assert result.possible_steps == ["s0", "s1", "s2", "s3", "s4"]
  end

  # --- AnalyticHierarchy facade ---

  def alternatives_matrix() do
    price = [[1, 4, 1 / 2], [1 / 4, 1, 1 / 5], [2, 5, 1]]
    size = [[1, 1 / 2, 3], [2, 1, 4], [1 / 3, 1 / 4, 1]]
    rooms = [[1, 1, 2], [1, 1, 3], [1 / 2, 1 / 3, 1]]
    place = [[1, 1 / 3, 4], [3, 1, 4], [1 / 4, 1 / 5, 1]]
    category = [[1, 2, 4], [1 / 2, 1, 1 / 6], [5, 6, 1]]
    [price, size, rooms, place, category]
  end

  test "facade: analytic_hierarchy/1 returns AnalyticHierarchy struct" do
    result = Descisionex.analytic_hierarchy(@comparison_matrix)
    assert %AnalyticHierarchy{} = result
    assert result.comparison_matrix == @comparison_matrix
  end

  test "facade: normalize_comparison_matrix delegates to AnalyticHierarchy" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.normalize_comparison_matrix()

    assert result.normalized_comparison_matrix != []
  end

  test "facade: calculate_criteria_weights delegates to AnalyticHierarchy" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.normalize_comparison_matrix()
      |> Descisionex.calculate_criteria_weights()

    assert result.criteria_weights != []
    assert length(result.criteria_weights) == 5
  end

  test "facade: calculate_consistency_ratio delegates to AnalyticHierarchy" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.normalize_comparison_matrix()
      |> Descisionex.calculate_criteria_weights()
      |> Descisionex.calculate_consistency_ratio()

    assert result.consistency_ratio < 0.1
  end

  test "facade: calculate/1 runs full AHP pipeline" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.set_alternatives(["apt1", "apt2", "apt3"])
      |> Descisionex.set_alternatives_matrix(alternatives_matrix())
      |> Descisionex.calculate()

    assert length(result.alternatives_weights) == 3
    assert Float.round(Enum.sum(result.alternatives_weights), 10) == 1.0
    assert result.consistency_ratio < 0.1
  end

  test "facade: set_tagged_alternatives_matrix delegates to AnalyticHierarchy" do
    tagged = %{"price" => [[1, 2], [0.5, 1]], "size" => [[1, 3], [1 / 3, 1]]}

    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size"])
      |> Descisionex.set_tagged_alternatives_matrix(tagged)

    assert result.alternatives_matrix == tagged
  end

  test "facade: calculate_alternatives_weights_by_criteria delegates correctly" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.set_alternatives(["apt1", "apt2", "apt3"])
      |> Descisionex.normalize_comparison_matrix()
      |> Descisionex.set_alternatives_matrix(alternatives_matrix())
      |> Descisionex.calculate_alternatives_weights_by_criteria()

    assert result.alternatives_weights_by_criteria != []
    assert length(result.alternatives_weights_by_criteria) == 3
  end

  test "facade: calculate_alternatives_weights delegates correctly" do
    result =
      Descisionex.analytic_hierarchy(@comparison_matrix)
      |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
      |> Descisionex.set_alternatives(["apt1", "apt2", "apt3"])
      |> Descisionex.normalize_comparison_matrix()
      |> Descisionex.calculate_criteria_weights()
      |> Descisionex.set_alternatives_matrix(alternatives_matrix())
      |> Descisionex.calculate_alternatives_weights_by_criteria()
      |> Descisionex.calculate_alternatives_weights()

    assert length(result.alternatives_weights) == 3
    assert Float.round(Enum.sum(result.alternatives_weights), 10) == 1.0
  end
end
