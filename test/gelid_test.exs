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
    @impl Experiment
    def cull_population(population, keep_portion), do: %Population{ population | members: Enum.take(population.members, floor(Enum.count(population.members) * keep_portion))}
    @impl Experiment
    def mix_genes(parent1, _), do: parent1
  end

  @test_pop_size 321
  @test_keep_portion 0.4
  @test_hyperparams [ population_size: @test_pop_size, max_generations: 10, gene_count: 5, keep_portion: @test_keep_portion ]

  @test_domain_size 5
  @test_gene_size 7

  # RUNNING AN EXPERIMENT
  test "run(): runs an experiment and returns a population" do
    result = Gelid.run(TestExperiment, @test_hyperparams)
    assert %Population{} = result
  end

  test "run(): returned pop's member list size matches population_size hyperparam & its own population_size field" do
    test_result = Gelid.run(TestExperiment, @test_hyperparams)
    assert test_result.target_size == @test_pop_size
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
    assert test_result.target_size == @test_pop_size
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

  test "has a step that calls strategy from experiment to cull a proportion of the population specified in hyperparameters" do
    test_pop = Gelid.init_population(TestExperiment, 100, @test_gene_size)
    test_result = Gelid.cull_population(TestExperiment, test_pop, @test_keep_portion)
    assert %Population{} = test_result
    assert Enum.count(test_result.members) == floor(Enum.count(test_pop.members) * @test_keep_portion)
  end

  test "has a step that calls strategy from experiment to refill the population via sexual reproduction of the remaining members" do
    # make a test pop with fewer members than its own target size
    test_pop_size = 10
    test_target_size = 20
    test_pop = %Population{ Gelid.init_population(TestExperiment, test_pop_size, @test_gene_size) | target_size: test_target_size}

    test_result = Gelid.repopulate(TestExperiment, test_pop)

    assert %Population{} = test_result
    assert Enum.count(test_result.members) == test_target_size
  end

  test "has a step that mutates some of the new individuals" do
    flunk "no test yet"
  end


  # TEST experiment stops after some default number of generations (spec'able in hparams) if termination criteria not hit

  # steps of algo - verify experiment is queried properly for each:
  #  start lifecycle
  #  √ score & rank population - gather mean score, best this gen, GOAT
  #  √ select a portion of the population to reproduce - a 0-1 set in hyperparams, algo to be provided experiment
  #  √ repopulate - use crossover or other sexual repro - spec in experiment?
  #  mutate
  #  continue lifecycle until we stabilize, or hit max generations

end
