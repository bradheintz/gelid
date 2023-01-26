defmodule Individual do
  @type t :: %__MODULE__{
    genes: Enum.t,
    age: integer,
    fitness: float
  }
	defstruct genes: [], age: 0, fitness: 0.0
end