defmodule TravSalesExperimentTest do
  use ExUnit.Case


  test "has a map with the correct number of cities in it" do
    # TODO "correct" number is currently hardcoded to 20
    assert TravSalesExperiment.city_count == 20
  end

  test "exposes a function to give a single population member" do
    result = TravSalesExperiment.new_individual()
    assert %Individual{} = result
    assert Enum.count(result.genes) == 20 # TODO currently hardcoded, which is bad - needs to be config
    assert result.age == 0
  end

  test "exposes a function that scores a individual against the domain" do
    assert false
    # make a test domain
    # make a test individual
    # score
  end
end
