# Descisionex

Library for dealing with [descision theory](https://en.wikipedia.org/wiki/Decision_theory) algorithms.

## Current algorithms

- [Payment matrix](https://en.wikipedia.org/wiki/Payoff_matrix)
- [Analytic hierarchy](https://en.wikipedia.org/wiki/Analytic_hierarchy_process)

## Installation

Package can be installed by adding `descisionex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:descisionex, "~> 1.0.0"}
  ]
end
```

## Usage

### Payment matrix (decision under uncertainty)

```elixir
alias Descisionex

matrix = [
  [0.221, 0.194, 0.293, 0.181, 0.227],
  [0.074, 0.065, 0.073, 0.052, 0.091],
  [0.221, 0.258, 0.293, 0.361, 0.273],
  [0.441, 0.452, 0.293, 0.361, 0.364],
  [0.044, 0.032, 0.049, 0.045, 0.045]
]

# Calculate all criteria at once
result =
  Descisionex.payment_matrix(matrix)
  |> Descisionex.set_alternatives(["s1", "s2", "s3", "s4", "s5"])
  |> Descisionex.calculate_criteria()

result.wald_criterion      # %{criterion: 0.293, strategy_index: 3, strategy_name: "s4"}
result.maximax_criterion   # %{criterion: 0.452, strategy_index: 3, strategy_name: "s4"}
result.hurwitz_criterion   # %{criterion: 0.372, strategy_index: 3, strategy_name: "s4"}
result.savage_criterion    # %{criterion: 0.0,   strategy_index: 3, strategy_name: "s4"}
result.laplace_criterion   # %{criterion: 0.382, strategy_index: 3, strategy_name: "s4"}

# Bayes criterion requires probabilities
Descisionex.payment_matrix(matrix)
|> Descisionex.set_probabilities([0.2, 0.2, 0.2, 0.2, 0.2])
|> Descisionex.calculate_bayes_criterion()
```

### Analytic Hierarchy Process (AHP)

```elixir
alias Descisionex

# Pairwise comparison matrix for criteria
comparison_matrix = [
  [1,   3,   1,   1/2, 5],
  [1/3, 1,   1/4, 1/7, 2],
  [1,   4,   1,   1,   6],
  [2,   7,   1,   1,   8],
  [1/5, 1/2, 1/6, 1/8, 1]
]

# Pairwise comparison matrices for each criterion (alternatives vs alternatives)
# Each must be a valid reciprocal matrix: A[i][j] * A[j][i] == 1, diagonal == 1
alternatives_matrix = [
  [[1, 4, 1/2], [1/4, 1, 1/5],  [2, 5, 1]],      # price    CR=0.021
  [[1, 1/2, 3], [2, 1, 4],      [1/3, 1/4, 1]],  # size     CR=0.016
  [[1, 1, 2],   [1, 1, 3],      [1/2, 1/3, 1]],  # rooms    CR=0.016
  [[1, 1/4, 1/2], [4, 1, 2],    [2, 1/2, 1]],    # place    CR=0.000
  [[1, 2, 4],   [1/2, 1, 2],    [1/4, 1/2, 1]]   # category CR=0.000
]

result =
  Descisionex.analytic_hierarchy(comparison_matrix)
  |> Descisionex.set_criteria(["price", "size", "rooms", "place", "category"])
  |> Descisionex.set_alternatives(["apt1", "apt2", "apt3"])
  |> Descisionex.set_alternatives_matrix(alternatives_matrix)
  |> Descisionex.calculate()

result.consistency_ratio    # 0.013 (< 0.1, acceptable)
result.alternatives_weights # [0.286, 0.416, 0.299]

Descisionex.rank_alternatives(result)
# [
#   %{rank: 1, alternative: "apt2", weight: 0.416},
#   %{rank: 2, alternative: "apt3", weight: 0.299},
#   %{rank: 3, alternative: "apt1", weight: 0.286}
# ]
```

## Documentation

Documentation can be found at [https://hexdocs.pm/descisionex](https://hexdocs.pm/descisionex).

