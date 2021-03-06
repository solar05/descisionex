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
            hurwitz_additional_value: 0.5,
            generalized_additional_value: 0.5,
            wald_criterion: %{},
            laplace_criterion: %{},
            savage_criterion: %{},
            hurwitz_criterion: %{},
            generalized_criterion: %{}

  @doc """
  Set variants for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"])
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
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
  Set steps for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{} |> Descisionex.PaymentMatrix.set_steps(["some", "steps"])
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: ["some", "steps"],
        possible_steps_num: 2,
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
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.3,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
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
        generalized_additional_value: 0.3,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [],
        possible_steps: [],
        possible_steps_num: 0,
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
  Calculates Wald criterion for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_wald_criterion()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{criterion: 4, strategy_index: 1}
      }

  """
  def calculate_wald_criterion(%PaymentMatrix{} = data) do
    all_criteria = Enum.map(data.matrix, fn row -> Enum.max(row) end)
    {wald_criterion, strategy_index} = Helper.find_max_criteria(all_criteria)

    Map.put(data, :wald_criterion, %{criterion: wald_criterion, strategy_index: strategy_index})
  end

  @doc """
  Calculates Laplace criterion for payment matrix (variants must be set).

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_laplace_criterion()
      ** (ArgumentError) For Laplace criterion variants must be set!
      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"]) |> Descisionex.PaymentMatrix.calculate_laplace_criterion()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{criterion: 3.5, strategy_index: 1},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{},
        variants: ["some", "variants"],
        variants_num: 2,
        wald_criterion: %{}
      }

  """
  def calculate_laplace_criterion(%PaymentMatrix{} = data) do
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
      strategy_index: strategy_index
    })
  end

  @doc """
  Calculates Hurwitz criterion for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_hurwitz_criterion()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{criterion: 3.5, strategy_index: 1},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_hurwitz_criterion(%PaymentMatrix{} = data) do
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
      strategy_index: strategy_index
    })
  end

  @doc """
  Calculates Savage criterion for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3, 4]]} |> Descisionex.PaymentMatrix.calculate_savage_criterion()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{criterion: 0, strategy_index: 1},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_savage_criterion(%PaymentMatrix{} = data) do
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
      strategy_index: strategy_index
    })
  end

  @doc """
  Calculates generalized criterion for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3,4]]} |> Descisionex.PaymentMatrix.calculate_generalized_criterion()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{criterion: 1.5, strategy_index: 0},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{},
        laplace_criterion: %{},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{},
        variants: [],
        variants_num: 0,
        wald_criterion: %{}
      }

  """
  def calculate_generalized_criterion(%PaymentMatrix{} = data) do
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
      strategy_index: strategy_index
    })
  end

  @doc """
  Calculates all criteria for payment matrix.

  ## Examples

      iex> %Descisionex.PaymentMatrix{matrix: [[1, 2], [3,4]]} |> Descisionex.PaymentMatrix.set_variants(["some", "variants"]) |> Descisionex.PaymentMatrix.calculate_criteria()
      %Descisionex.PaymentMatrix{
        generalized_additional_value: 0.5,
        generalized_criterion: %{criterion: 1.5, strategy_index: 0},
        hurwitz_additional_value: 0.5,
        hurwitz_criterion: %{criterion: 3.5, strategy_index: 1},
        laplace_criterion: %{criterion: 3.5, strategy_index: 1},
        matrix: [[1, 2], [3, 4]],
        possible_steps: [],
        possible_steps_num: 0,
        savage_criterion: %{criterion: 0, strategy_index: 1},
        variants: ["some", "variants"],
        variants_num: 2,
        wald_criterion: %{criterion: 4, strategy_index: 1}
      }

  """
  def calculate_criteria(%PaymentMatrix{} = data) do
    data
    |> calculate_wald_criterion()
    |> calculate_savage_criterion()
    |> calculate_laplace_criterion()
    |> calculate_hurwitz_criterion()
    |> calculate_generalized_criterion()
  end
end
