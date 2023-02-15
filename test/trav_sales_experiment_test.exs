defmodule TravSalesExperimentTest do
  use ExUnit.Case
  doctest TravSalesExperiment
  @test_delta 0.0001
  @test_domain_size 5
  @test_keep_portion 0.4
  @test_population_size 300
  @test_mutation_rate 0.01
  @test_map %CityMap{cities: [[0.0, 0.0], [0.1, 0.0], [0.2, 0.0]]}

  test "exposes a function to give a single population member" do
    test_result = TravSalesExperiment.new_individual(@test_domain_size)

    assert %Individual{} = test_result
    assert Enum.count(test_result.genes) == @test_domain_size # TODO currently hardcoded, which is bad - needs to be config
    assert test_result.age == 0
  end

  test "exposes a function to give a new domain instance" do
    test_domain_size = 5
    test_result = TravSalesExperiment.new_domain(test_domain_size)
    # TODO right now, this is a very specific type - not sure how to make a generic "domain", but need to keep framework dumb about this type
    assert %CityMap{} = test_result
    assert Enum.count(test_result.cities) == test_domain_size
  end

  test "exposes a function that scores a individual against the domain" do
    test_individual = %Individual{genes: [0,0,0]} # traverses the three cities in list order

    test_result = TravSalesExperiment.score(test_individual, @test_map)
    assert %Individual{} = test_result
    assert_in_delta test_result.fitness, 2.62842712, @test_delta

    # double-checking for non-trivial route
    test_individual2 = %Individual{genes: [0,1,0]}

    test_result = TravSalesExperiment.score(test_individual2, @test_map)
    assert_in_delta test_result.fitness, 2.52842712, @test_delta
  end

  # NB this means we can only mutate babies
  test "the scoring function should skip already-scored individuals" do
    impossible_score = 321.0 # verifies skip
    test_individual = %Individual{ genes: [0,0,0], fitness: impossible_score }

    test_result = TravSalesExperiment.score(test_individual, @test_map)
    assert %Individual{} = test_result
    assert_in_delta test_result.fitness, impossible_score, @test_delta
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

  # reproduction
  test "exposes a function that takes two population members and returns a third" do
    test_parent1 = TravSalesExperiment.new_individual(@test_domain_size)
    test_parent2 = TravSalesExperiment.new_individual(@test_domain_size)

    test_result = TravSalesExperiment.mix_genes(test_parent1, test_parent2, @test_mutation_rate)

    assert %Individual{} = test_result
    # tough to test more than that, b/c randomness
  end

  # mutation

  def count_diff_genes([], _), do: 0
  def count_diff_genes([h1 | t1], [h2 | t2]) do
    count_diff_genes(t1, t2) + (if h1 == h2, do: 0, else: 1)
  end

  test "exposes a function to mutate genes of a population member" do
    test_individual = TravSalesExperiment.new_individual(@test_domain_size)

    test_result = TravSalesExperiment.mutate_one_gene(test_individual)

    assert %Individual{} = test_result

    genes_before = test_individual.genes
    genes_after = test_result.genes
    l = length(genes_before)
    assert l == length(genes_after)

    # TODO I either need a good stochastic test here or I need to ensure that mutation is never a no-op
    # change_count = count_diff_genes(genes_before, genes_after)
    # assert 1 == change_count

    # TODO should i had a sentry for the correctness of the change?
  end
end
