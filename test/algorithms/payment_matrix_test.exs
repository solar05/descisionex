defmodule DescisionexTest.PaymentMatrixTest do
  use ExUnit.Case

  alias Descisionex.PaymentMatrix

  doctest Descisionex.PaymentMatrix

  @matrix [
    [0.221, 0.194, 0.293, 0.181, 0.227],
    [0.074, 0.065, 0.073, 0.052, 0.091],
    [0.221, 0.258, 0.293, 0.361, 0.273],
    [0.441, 0.452, 0.293, 0.361, 0.364],
    [0.044, 0.032, 0.049, 0.045, 0.045]
  ]

  @variants ["some1", "some2", "some3", "some4", "some5"]
  @steps ["step0", "step1", "step2", "step3", "step4"]

  @hurwitz_criterion %{criterion: 0.372, strategy_index: 3, strategy_name: nil}
  @hurwitz_criterion_additional %{criterion: 0.421, strategy_index: 3, strategy_name: nil}
  @laplace_criterion %{criterion: 0.382, strategy_index: 3, strategy_name: nil}
  @savage_criterion %{criterion: 0.0, strategy_index: 3, strategy_name: nil}
  @wald_criterion %{criterion: 0.293, strategy_index: 3, strategy_name: nil}
  @maximax_criterion %{criterion: 0.452, strategy_index: 3, strategy_name: nil}
  @generalized_criterion %{criterion: 0.041, strategy_index: 4, strategy_name: nil}
  @generalized_criterion_additional %{criterion: 0.065, strategy_index: 4, strategy_name: nil}

  test "calculates hurwitz criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_hurwitz_criterion()
    assert @hurwitz_criterion == result.hurwitz_criterion
  end

  test "calculates hurwitz criterion with different additional value" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_hurwitz_additional_value(0.8)
      |> PaymentMatrix.calculate_hurwitz_criterion()

    assert @hurwitz_criterion_additional == result.hurwitz_criterion
  end

  test "calculates laplace criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_laplace_criterion()
    assert @laplace_criterion == result.laplace_criterion
  end

  test "calculates laplace criterion without explicit variants (infers from matrix)" do
    result = %PaymentMatrix{matrix: @matrix} |> PaymentMatrix.calculate_laplace_criterion()
    assert @laplace_criterion == result.laplace_criterion
  end

  test "calculates savage criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_savage_criterion()
    assert @savage_criterion == result.savage_criterion
  end

  test "calculates wald criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_wald_criterion()
    assert @wald_criterion == result.wald_criterion
  end

  test "calculates maximax criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_maximax_criterion()
    assert @maximax_criterion == result.maximax_criterion
  end

  test "calculate generalized criterion" do
    result = setup_matrix() |> PaymentMatrix.calculate_generalized_criterion()
    assert @generalized_criterion == result.generalized_criterion
  end

  test "calculate generalized criterion with different additional value" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_generalized_additional_value(0.8)
      |> PaymentMatrix.calculate_generalized_criterion()

    assert @generalized_criterion_additional == result.generalized_criterion
  end

  # --- strategy_name ---

  test "strategy_name is populated when possible_steps are set" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_steps(@steps)
      |> PaymentMatrix.calculate_wald_criterion()

    assert result.wald_criterion.strategy_name == "step3"
  end

  test "strategy_name is nil when possible_steps are not set" do
    result = setup_matrix() |> PaymentMatrix.calculate_wald_criterion()
    assert result.wald_criterion.strategy_name == nil
  end

  test "all criteria include correct strategy_name when steps are set" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_steps(@steps)
      |> PaymentMatrix.calculate_criteria()

    assert result.wald_criterion.strategy_name == "step3"
    assert result.maximax_criterion.strategy_name == "step3"
    assert result.savage_criterion.strategy_name == "step3"
    assert result.hurwitz_criterion.strategy_name == "step3"
    assert result.laplace_criterion.strategy_name == "step3"
    assert result.generalized_criterion.strategy_name == "step4"
  end

  # --- Bayes criterion ---

  test "calculates bayes criterion" do
    probabilities = [0.2, 0.2, 0.2, 0.2, 0.2]

    result =
      setup_matrix()
      |> PaymentMatrix.set_probabilities(probabilities)
      |> PaymentMatrix.calculate_bayes_criterion()

    assert result.bayes_criterion.strategy_index == 3
    assert result.bayes_criterion.strategy_name == nil
  end

  test "bayes criterion with unequal probabilities selects correct strategy" do
    matrix = %PaymentMatrix{matrix: [[10, 0], [4, 4]]}

    result =
      matrix
      |> PaymentMatrix.set_probabilities([0.9, 0.1])
      |> PaymentMatrix.calculate_bayes_criterion()

    # Row 0: 10*0.9 + 0*0.1 = 9.0
    # Row 1: 4*0.9 + 4*0.1 = 4.0
    assert result.bayes_criterion.criterion == 9.0
    assert result.bayes_criterion.strategy_index == 0
  end

  test "bayes criterion with possible_steps returns strategy_name" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_steps(@steps)
      |> PaymentMatrix.set_probabilities([0.2, 0.2, 0.2, 0.2, 0.2])
      |> PaymentMatrix.calculate_bayes_criterion()

    assert result.bayes_criterion.strategy_name == "step3"
  end

  test "calculate_criteria includes bayes when probabilities set" do
    result =
      setup_matrix()
      |> PaymentMatrix.set_probabilities([0.2, 0.2, 0.2, 0.2, 0.2])
      |> PaymentMatrix.calculate_criteria()

    assert result.bayes_criterion != %{}
    assert result.bayes_criterion.strategy_index == 3
  end

  test "calculate_criteria skips bayes when probabilities not set" do
    result = setup_matrix() |> PaymentMatrix.calculate_criteria()
    assert result.bayes_criterion == %{}
  end

  # --- Input validation ---

  test "raises on empty matrix for wald criterion" do
    assert_raise ArgumentError, "Matrix must be set!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.calculate_wald_criterion()
    end
  end

  test "raises on empty matrix for savage criterion" do
    assert_raise ArgumentError, "Matrix must be set!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.calculate_savage_criterion()
    end
  end

  test "raises on empty matrix for hurwitz criterion" do
    assert_raise ArgumentError, "Matrix must be set!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.calculate_hurwitz_criterion()
    end
  end

  test "raises on empty matrix for generalized criterion" do
    assert_raise ArgumentError, "Matrix must be set!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.calculate_generalized_criterion()
    end
  end

  test "raises on empty matrix for bayes criterion" do
    assert_raise ArgumentError, "Matrix must be set!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.calculate_bayes_criterion()
    end
  end

  test "raises when probabilities do not sum to 1" do
    assert_raise ArgumentError, "Probabilities must sum to 1.0!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.set_probabilities([0.3, 0.3])
    end
  end

  test "raises on empty probabilities" do
    assert_raise ArgumentError, "Probabilities must be not empty!", fn ->
      %PaymentMatrix{} |> PaymentMatrix.set_probabilities([])
    end
  end

  def setup_matrix() do
    %PaymentMatrix{matrix: @matrix}
    |> PaymentMatrix.set_variants(@variants)
  end
end
