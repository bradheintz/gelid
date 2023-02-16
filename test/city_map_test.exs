defmodule CityMapTest do
  use ExUnit.Case


	test "has a method to create a map with a specified number of cities" do
		test_size = 13
		result = CityMap.build(test_size)
		assert length(result.cities) == test_size
		assert length(List.first(result.cities)) == 2 # 2 coords for city pos btwn 0 and 1
	end
end