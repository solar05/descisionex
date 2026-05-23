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
            probabilities: [],
            hurwitz_additional_value: 0.5,
            generalized_additional_value: 0.5,
            bayes_criterion: %{},
            wald_criterion: %{},
            laplace_criterion: %{},
            savage_criterion: %{},
            hurwitz_criterion: %{},
            generalized_criterion: %{}

  @doc """
  Set variants (states of nature) for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"])
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: ["some", "variants"],
        variants_num: 2,
        wald_criterion: %{}
      }

  """
  def set_variants(%PaymentMatrix{} = data, variants) do
    data
    |> Map.put(:variants, variants)
    |> Map.put(:variants_num, Enum.count(variants))
  end

  @doc """
  Set steps (strategies/decisions) for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_steps(["some", "steps"])
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: ["some", "steps"],
        possible_steps_num: 2,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def set_steps(%PaymentMatrix{} = data, steps) do
    data
    |> Map.put(:possible_steps, steps)
    |> Map.put(:possible_steps_num, Enum.count(steps))
  end

  @doc """
  Set Hurwitz additional value for payment matrix (range from 0.1 to 0.9), defaults to 0.5.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_hurwitz_additional_value(0.3)
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.3,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_hurwitz_additional_value(0)
      ** (ArgumentError) Hurwitz additional value incorrect (number range must be from 0.1 to 0.9)

  """
  def set_hurwitz_additional_value(%PaymentMatrix{} = data, value) do
    if 0.1 <= value && value <= 0.9 do
      Map.put(data, :hurwitz_additional_value, value)
    else
      raise ArgumentError,
        message: "Hurwitz additional value incorrect (number range must be from 0.1 to 0.9)"
    end
  end

  @doc """
  Set Generalized additional value for payment matrix (range from 0.1 to 0.9), defaults to 0.5.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_generalized_additional_value(0.3)
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.3,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_generalized_additional_value(0)
      ** (ArgumentError) Generalized additional value incorrect (number range must be from 0.1 to 0.9)

  """
  def set_generalized_additional_value(%PaymentMatrix{} = data, value) do
    if 0.1 <= value && value <= 0.9 do
      Map.put(data, :generalized_additional_value, value)
    else
      raise ArgumentError,
        message: "Generalized additional value incorrect (number range must be from 0.1 to 0.9)"
    end
  end

  @doc """
  Set probabilities for states of nature (must sum to 1.0). Required for Bayes criterion.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.set_probabilities([0.4, 0.6])
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [0.4, 0.6],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_probabilities([])
      ** (ArgumentError) Probabilities must be not empty!

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_probabilities([0.3, 0.3])
      ** (ArgumentError) Probabilities must sum to 1.0!

  """
  def set_probabilities(%PaymentMatrix{} = _data, []) do
    raise ArgumentError, message: "Probabilities must be not empty!"
  end

  def set_probabilities(%PaymentMatrix{} = data, probabilities) do
    sum = Enum.sum(probabilities)

    unless abs(sum - 1.0) < 0.001 do
      raise ArgumentError, message: "Probabilities must sum to 1.0!"
    end

    Map.put(data, :probabilities, probabilities)
  end

  @doc """
  Calculates Wald criterion (maximin) for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_wald_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{criterion: 4, strategy_index: 1, strategy_name: nil}
      }

  """
  def calculate_wald_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    all_criteria = Enum.map(data.matrix, fn row -> Enum.max(row) end)
    {wald_criterion, strategy_index} = Helper.find_max_criteria(all_criteria)

    Map.put(data, :wald_criterion, %{
      criterion: wald_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates Laplace criterion (equal probability) for payment matrix (variants must be set).

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_laplace_criterion()
      ** (ArgumentError) For Laplace criterion variants must be set!
      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"]) |> Descisionex.PaymentMatrix.calculate_laplace_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{criterion: 3.5, strategy_index: 1, strategy_name: nil},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: ["some", "variants"],
        variants_num: 2,
        wald_criterion: %{}
      }

  """
  def calculate_laplace_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    variant_rows = data.variants_num

    if variant_rows == 0,
      do: raise(ArgumentError, message: "For Laplace criterion variants must be set!")

    all_criteria =
      data.matrix
      |> Enum.map(fn row ->
        Enum.map(row, fn element ->
          Float.round(element / variant_rows, 3)
        end)
      end)
      |> Enum.map(fn row -> Enum.sum(row) end)

    {laplace_criterion, strategy_index} = Helper.find_max_criteria(all_criteria)

    Map.put(data, :laplace_criterion, %{
      criterion: laplace_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates Hurwitz criterion (pessimism-optimism) for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_hurwitz_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{criterion: 3.5, strategy_index: 1, strategy_name: nil},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_hurwitz_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    additional_value = data.hurwitz_additional_value

    max =
      data.matrix
      |> Enum.map(fn row -> Enum.max(row) end)
      |> Enum.map(fn element ->
        num = element * additional_value
        if is_float(num), do: Float.round(num, 3), else: num
      end)
      |> Enum.with_index()

    min =
      data.matrix
      |> Enum.map(fn row -> Enum.min(row) end)
      |> Enum.map(fn element ->
        num = element * (1 - additional_value)
        if is_float(num), do: Float.round(num, 3), else: num
      end)

    {hurwitz_criterion, strategy_index} =
      max
      |> Enum.map(fn {element, index} ->
        element + Enum.at(min, index)
      end)
      |> Helper.find_max_criteria()

    Map.put(data, :hurwitz_criterion, %{
      criterion: hurwitz_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates Savage criterion (minimax regret) for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_savage_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{criterion: 0, strategy_index: 1, strategy_name: nil},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_savage_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    matrix = data.matrix

    max =
      matrix
      |> Matrix.transpose()
      |> Enum.map(fn row -> Enum.max(row) end)

    all_criteria =
      matrix
      |> Enum.map(fn row ->
        Enum.zip(max, row)
        |> Enum.map(fn {risk, elem} ->
          num = risk - elem
          if is_float(num), do: Float.round(num, 3), else: num
        end)
      end)
      |> Enum.map(fn row -> Enum.max(row) end)

    {savage_criterion, strategy_index} = Helper.find_min_criteria(all_criteria)

    Map.put(data, :savage_criterion, %{
      criterion: savage_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates generalized criterion for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_generalized_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{criterion: 1.5, strategy_index: 0, strategy_name: nil},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_generalized_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    additional_value = data.generalized_additional_value

    max =
      data.matrix
      |> Enum.map(fn row -> Enum.max(row) end)
      |> Enum.map(fn element ->
        num = element * additional_value
        if is_float(num), do: Float.round(num, 3), else: num
      end)
      |> Enum.with_index()

    min =
      data.matrix
      |> Enum.map(fn row -> Enum.min(row) end)
      |> Enum.map(fn element ->
        num = element * additional_value
        if is_float(num), do: Float.round(num, 3), else: num
      end)

    {generalized_criterion, strategy_index} =
      max
      |> Enum.map(fn {element, index} ->
        element + Enum.at(min, index)
      end)
      |> Helper.find_min_criteria()

    Map.put(data, :generalized_criterion, %{
      criterion: generalized_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates Bayes criterion (decision under risk) for payment matrix (probabilities must be set).

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_bayes_criterion()
      ** (ArgumentError) For Bayes criterion probabilities must be set!
      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.set_probabilities([0.4, 0.6]) |> Descisionex.PaymentMatrix.calculate_bayes_criterion()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{criterion: 3.6, strategy_index: 1, strategy_name: nil},
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [0.4, 0.6],
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_bayes_criterion(%PaymentMatrix{} = data) do
    if data.matrix == [], do: raise(ArgumentError, message: "Matrix must be set!")

    if data.probabilities == [],
      do: raise(ArgumentError, message: "For Bayes criterion probabilities must be set!")

    all_criteria =
      data.matrix
      |> Enum.map(fn row ->
        Enum.zip(data.probabilities, row)
        |> Enum.map(fn {prob, val} -> prob * val end)
        |> Enum.sum()
        |> then(fn sum -> if is_float(sum), do: Float.round(sum, 3), else: sum end)
      end)

    {bayes_criterion, strategy_index} = Helper.find_max_criteria(all_criteria)

    Map.put(data, :bayes_criterion, %{
      criterion: bayes_criterion,
      strategy_index: strategy_index,
      strategy_name: resolve_strategy_name(data, strategy_index)
    })
  end

  @doc """
  Calculates all criteria for payment matrix. Includes Bayes criterion if probabilities are set.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"]) |> Descisionex.PaymentMatrix.calculate_criteria()
      %Descisionex.PaymentMatrix{
        bayes_criterion: %{},
        generalized_additional_value: 0.5,
        generalized_criterion: %{criterion: 1.5, strategy_index: 0, strategy_name: nil},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{criterion: 3.5, strategy_index: 1, strategy_name: nil},
        laplace_criterion: %{criterion: 3.5, strategy_index: 1, strategy_name: nil},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        probabilities: [],
        savage_criterion: %{criterion: 0, strategy_index: 1, strategy_name: nil},
        variants: ["some", "variants"],
        variants_num: 2,
        wald_criterion: %{criterion: 4, strategy_index: 1, strategy_name: nil}
      }

  """
  def calculate_criteria(%PaymentMatrix{} = data) do
    result =
      data
      |> calculate_wald_criterion()
      |> calculate_savage_criterion()
      |> calculate_laplace_criterion()
      |> calculate_hurwitz_criterion()
      |> calculate_generalized_criterion()

    if result.probabilities != [], do: calculate_bayes_criterion(result), else: result
  end

  defp resolve_strategy_name(data, strategy_index) do
    if data.possible_steps != [], do: Enum.at(data.possible_steps, strategy_index), else: nil
  end
end
