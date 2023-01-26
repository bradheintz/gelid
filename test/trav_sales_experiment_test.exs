defmodule TravSalesExperimentTest do
  use ExUnit.Case
  doctest TravSalesExperiment
  @testdelta 0.0001

  test "exposes a function to give a single population member" do
    test_domain_size = 5
    test_result = TravSalesExperiment.new_individual(test_domain_size)
    assert %Individual{} = test_result
    assert Enum.count(test_result.genes) == test_domain_size # TODO currently hardcoded, which is bad - needs to be config
    assert test_result.age == 0
  end

  test "exposes a function to give a new domain instance" do
    test_domain_size = 5
    # TODO experiment framework currently dumb about domain, so only parametrizes by size
    test_result = TravSalesExperiment.new_domain(test_domain_size)
    # TODO right now, this is a very specific type - not sure how to make a generic "domain", but need to keep framework dumb about this type
    assert %CityMap{} = test_result
    assert Enum.count(test_result.cities) == test_domain_size
  end

  test "exposes a function that scores a individual against the domain" do
    test_map = %CityMap{cities: [[0.0, 0.0], [0.1, 0.0], [0.2, 0.0]]}
    test_individual = %Individual{genes: [0,0,0]} # traverses the three cities in list order

    test_result = TravSalesExperiment.score(test_individual, test_map)
    assert %Individual{} = test_result
    assert_in_delta test_result.fitness, 2.62842712, @testdelta

    # double-checking for non-trivial route
    test_individual2 = %Individual{genes: [0,1,0]}

    test_result = TravSalesExperiment.score(test_individual2, test_map)
    assert_in_delta test_result.fitness, 2.52842712, @testdelta
  end

  # TODO this means we can only mutate babies
  test "the scoring function should skip already-scored individuals" do
    test_map = %CityMap{cities: [[0.0, 0.0], [0.1, 0.0], [0.2, 0.0]]}
    # NB this score is impossible and will verify the skip
    test_individual = %Individual{genes: [0,0,0], fitness: 321.0} # traverses the three cities in list order

    test_result = TravSalesExperiment.score(test_individual, test_map)
    assert %Individual{} = test_result
    assert_in_delta test_result.fitness, 321.0, @testdelta
  end

  # distance calculations
  test "correctly computes distance for a single segment" do
    test_result = TravSalesExperiment._calc_distance(0.0, [0.1, 0.1], [[0.1, 0.2]], [0])
    assert_in_delta test_result, 0.1, @testdelta
  end
end
