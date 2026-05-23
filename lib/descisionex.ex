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

  # --- Shared setters ---

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

  def set_tagged_alternatives_matrix(%AnalyticHierarchy{} = data, matrix) do
    data |> AnalyticHierarchy.set_tagged_alternatives_matrix(matrix)
  end

  # --- PaymentMatrix setters ---

  def set_hurwitz_additional_value(%PaymentMatrix{} = data, value) do
    data |> PaymentMatrix.set_hurwitz_additional_value(value)
  end

  def set_generalized_additional_value(%PaymentMatrix{} = data, value) do
    data |> PaymentMatrix.set_generalized_additional_value(value)
  end

  def set_probabilities(%PaymentMatrix{} = data, probabilities) do
    data |> PaymentMatrix.set_probabilities(probabilities)
  end

  # --- PaymentMatrix criteria ---

  def calculate_wald_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_wald_criterion()
  end

  def calculate_laplace_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_laplace_criterion()
  end

  def calculate_savage_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_savage_criterion()
  end

  def calculate_hurwitz_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_hurwitz_criterion()
  end

  def calculate_generalized_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_generalized_criterion()
  end

  def calculate_bayes_criterion(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_bayes_criterion()
  end

  def calculate_criteria(%PaymentMatrix{} = data) do
    data |> PaymentMatrix.calculate_criteria()
  end

  # --- AnalyticHierarchy pipeline ---

  def normalize_comparison_matrix(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.normalize_comparison_matrix()
  end

  def calculate_criteria_weights(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.calculate_criteria_weights()
  end

  def calculate_consistency_ratio(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.calculate_consistency_ratio()
  end

  def calculate_alternatives_weights_by_criteria(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.calculate_alternatives_weights_by_criteria()
  end

  def calculate_alternatives_weights(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.calculate_alternatives_weights()
  end

  def calculate(%AnalyticHierarchy{} = data) do
    data |> AnalyticHierarchy.calculate()
  end
end
