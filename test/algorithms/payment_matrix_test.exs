defmodule DescisionexTest.PaymentMatrixTest do
  use ExUnit.Case

  alias Descisionex.PaymentMatrix

  @matrix [
    [0.221, 0.194, 0.293, 0.181, 0.227],
    [0.074, 0.065, 0.073, 0.052, 0.091],
    [0.221, 0.258, 0.293, 0.361, 0.273],
    [0.441, 0.452, 0.293, 0.361, 0.364],
    [0.044, 0.032, 0.049, 0.045, 0.045]
  ]

  @variants ["some1", "some2", "some3", "some4", "some5"]

  @hurwitz_criterion %{criterion: 0.372, strategy_index: 3}
  @hurwitz_criterion_additional %{criterion: 0.421, strategy_index: 3}
  @laplace_criterion %{criterion: 0.382, strategy_index: 3}
  @savage_criterion %{criterion: 0.0, strategy_index: 3}
  @wald_criterion %{criterion: 0.452, strategy_index: 3}
  @generalized_criterion %{criterion: 0.041, strategy_index: 4}
  @generalized_criterion_additional %{criterion: 0.065, strategy_index: 4}

  test "calculates hurwitz criterion" do
    matrix = setup_matrix()
    result = matrix |> PaymentMatrix.calculate_hurwitz_criterion()

    assert @hurwitz_criterion == result.hurwitz_criterion
  end

  test "calculates hurwitz criterion with different additional value" do
    matrix = setup_matrix()

    result =
      matrix
      |> PaymentMatrix.set_hurwitz_additional_value(0.8)
      |> PaymentMatrix.calculate_hurwitz_criterion()

    assert @hurwitz_criterion_additional == result.hurwitz_criterion
  end

  test "calculates laplace criterion" do
    matrix = setup_matrix()
    result = matrix |> PaymentMatrix.calculate_laplace_criterion()

    assert @laplace_criterion == result.laplace_criterion
  end

  test "calculates savage criterion" do
    matrix = setup_matrix()
    result = matrix |> PaymentMatrix.calculate_savage_criterion()

    assert @savage_criterion == result.savage_criterion
  end

  test "calculates wald criterion" do
    matrix = setup_matrix()
    result = matrix |> PaymentMatrix.calculate_wald_criterion()

    assert @wald_criterion == result.wald_criterion
  end

  test "calculate generalized criterion" do
    matrix = setup_matrix()
    result = matrix |> PaymentMatrix.calculate_generalized_criterion()

    assert @generalized_criterion == result.generalized_criterion
  end

  test "calculate generalized criterion with different additional value" do
    matrix = setup_matrix()

    result =
      matrix
      |> PaymentMatrix.set_generalized_additional_value(0.8)
      |> PaymentMatrix.calculate_generalized_criterion()

    assert @generalized_criterion_additional == result.generalized_criterion
  end

  def setup_matrix() do
    %PaymentMatrix{matrix: @matrix}
    |> PaymentMatrix.set_variants(@variants)
  end
end
