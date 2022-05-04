defmodule Descisionex do
  @moduledoc """
  Library for dealing with descision theory algorithms.
  """

  alias Descisionex.{PaymentMatrix, AnalyticHierarchy}

  def analytic_hierarchy() do
    raise(ArgumentError, message: "Comparison matrix must be set!")
  end

  def analytic_hierarchy([]) do
    raise(ArgumentError, message: "Comparison matrix must be set!")
  end

  def analytic_hierarchy(matrix) do
    %AnalyticHierarchy{comparison_matrix: matrix}
  end

  def payment_matrix() do
    raise(ArgumentError, message: "Matrix must be set!")
  end

  def payment_matrix([]) do
    raise(ArgumentError, message: "Matrix must be set!")
  end

  def payment_matrix(matrix) do
    %PaymentMatrix{matrix: matrix}
  end

  def set_criteria(%PaymentMatrix{} = data, criteria) do
    data |> PaymentMatrix.set_variants(criteria)
  end

  def set_criteria(%AnalyticHierarchy{} = data, criteria) do
    data |> AnalyticHierarchy.set_criteria(criteria)
  end

  def set_alternatives(%AnalyticHierarchy{} = data, alternatives) do
    data |> AnalyticHierarchy.set_alternatives(alternatives)
  end

  def set_alternatives(%PaymentMatrix{} = data, steps) do
    data |> PaymentMatrix.set_steps(steps)
  end

  def set_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    data |> AnalyticHierarchy.set_alternatives_matrix(matrix)
  end
end
