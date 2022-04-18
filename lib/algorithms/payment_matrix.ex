defmodule Descisionex.PaymentMatrix do
  @moduledoc """
  https://en.wikipedia.org/wiki/Decision-matrix_method
  """

  alias Descisionex.{PaymentMatrix, Helper}

  defstruct matrix: [],
            variants: [],
            variants_num: 0,
            possible_steps: [],
            possible_steps_num: 0,
            wald_criterion: [],
            laplace_criterion: [],
            savage_criterion: [],
            hurwitz_criterion: [],
            generalized_criterion: []

  def set_variants(%PaymentMatrix{} = data, variants) do
    data
    |> Map.put(:variants, variants)
    |> Map.put(:variants_num, Enum.count(variants))
  end

  def set_steps(%PaymentMatrix{} = data, steps) do
    data
    |> Map.put(:possible_steps, steps)
    |> Map.put(:possible_steps_num, Enum.count(steps))
  end
end
