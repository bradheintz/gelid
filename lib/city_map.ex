defmodule CityMap do
  @type t :: %__MODULE__{
    cities: Enum.t # list of locations
  }
  defstruct cities: [[0.0, 0.0]], map_size: 1

  def build(map_size) do
		city_positions =
			Stream.repeatedly(fn -> [:rand.uniform, :rand.uniform] end)
			|> Enum.take(map_size)
		%CityMap{cities: city_positions}
  end
end