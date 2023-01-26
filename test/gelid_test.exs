defmodule GelidTest do
  use ExUnit.Case

  defmodule TestExperiment do
    @behaviour Experiment
    @impl Experiment
    def new_individual(_), do: %Individual{genes: [3,2,1], age: 23}
    @impl Experiment
    def new_domain(_), do: []
    @impl Experiment
    def score(i, _), do: %Individual{i | fitness: :rand.uniform()}
  end

  @test_pop_size 321
  @test_hyperparams [ population_size: @test_pop_size, max_generations: 10, gene_count: 5 ]

  @test_domain_size 5
  @test_gene_size 7

  # RUNNING AN EXPERIMENT
  test "run(): runs an experiment and returns a population" do
    result = Gelid.run(TestExperiment, @test_hyperparams)
    assert %Population{} = result
  end

  test "run(): returned pop's member list size matches population_size hyperparam & its own population_size field" do
    test_result = Gelid.run(TestExperiment, @test_hyperparams)
    assert test_result.population_size == @test_pop_size
    assert Enum.count(test_result.members) == @test_pop_size
  end


  # HYPERPARAMS
  # helper for all hyperparams requirement tests
  def assert_hyperparam_checked(hparam_atom) do
    assert_raise ArgumentError, fn -> Gelid.run(TestExperiment, Keyword.delete(@test_hyperparams, hparam_atom)) end
  end

  test "run(): if poulation_size is not specified in hyperparams, raise" do
    assert_hyperparam_checked(:population_size)
  end

  test "run(): if max_generations not specified in hyperparams, raise" do
    assert_hyperparam_checked(:max_generations)
  end

  test "run(): if gene_count not specified in hyperparams, raise" do
    assert_hyperparam_checked(:gene_count)
  end


  # ALGORITHM STEPS
  test "has a step that creates a population with specified size and creation fn" do
    # TODO yeah this is a bit of an implementation test so sue me
    test_result = Gelid.init_population(TestExperiment, @test_pop_size, @test_gene_size)
    assert test_result.population_size == @test_pop_size
    assert Enum.count(test_result.members) == @test_pop_size
    assert %Individual{} = List.first(test_result.members)
  end

  test "has a step that assigns a score to every individual" do
    test_pop = Gelid.init_population(TestExperiment, @test_pop_size, @test_gene_size)
    test_domain = TestExperiment.new_domain(@test_domain_size)

    test_result = Gelid.score(TestExperiment, test_pop, test_domain)
    
    assert %Population{} = test_result
    assert Enum.count(test_result.members) == Enum.count(test_pop.members)
    [m1 | [m2 | _]] = test_result.members
    assert m1.fitness > m2.fitness
  end


  # TEST experiment stops after some default number of generations (spec'able in hparams) if termination criteria not hit

  # steps of algo - verify experiment is queried properly for each:
  #  start lifecycle
  #  √ score & rank population - gather mean score, best this gen, GOAT
  #  select/cull?
  #  repopulate - use crossover or other sexual repro - spec in experiment?
  #  mutate
  #  continue lifecycle until we stabilize, or hit max generations

end
