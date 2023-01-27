defmodule TravSalesExperimentTest do
  use ExUnit.Case
  doctest TravSalesExperiment
  @test_delta 0.0001
  @test_domain_size 5
  @test_keep_portion 0.4
  @test_population_size 300

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
    assert_in_delta test_result.fitness, 2.62842712, @test_delta

    # double-checking for non-trivial route
    test_individual2 = %Individual{genes: [0,1,0]}

    test_result = TravSalesExperiment.score(test_individual2, test_map)
    assert_in_delta test_result.fitness, 2.52842712, @test_delta
  end

  # TODO this means we can only mutate babies
  test "the scoring function should skip already-scored individuals" do
    test_map = %CityMap{cities: [[0.0, 0.0], [0.1, 0.0], [0.2, 0.0]]}
    # NB this score is impossible and will verify the skip
    test_individual = %Individual{genes: [0,0,0], fitness: 321.0} # traverses the three cities in list order

    test_result = TravSalesExperiment.score(test_individual, test_map)
    assert %Individual{} = test_result
    assert_in_delta test_result.fitness, 321.0, @test_delta
  end

  # distance calculations
  test "correctly computes distance for a single segment" do
    test_result = TravSalesExperiment._calc_distance(0.0, [0.1, 0.1], [[0.1, 0.2]], [0])
    assert_in_delta test_result, 0.1, @test_delta
  end

  # who survives to reproduce?
  test "exposes a function to cull a portion of a population" do
    test_pop_members = Stream.repeatedly(fn -> TravSalesExperiment.new_individual(@test_domain_size) end)
      |> Enum.take(@test_population_size)
    test_pop = %Population{ members: test_pop_members, target_size: @test_population_size }

    test_result = TravSalesExperiment.cull_population(test_pop, @test_keep_portion)
    assert %Population{} = test_result
    assert floor(Enum.count(test_pop.members) * @test_keep_portion) == Enum.count(test_result.members)
    assert test_result.target_size == test_pop.target_size
  end
end
