defmodule Gelid do
  def run(experiment, hyperparams) do
    pop_size = Keyword.get(hyperparams, :population_size) || raise ArgumentError, "Specify :population_size in hyperparams"
    max_gens = Keyword.get(hyperparams, :max_generations) || raise ArgumentError, "Specify :max_generations in hyperparams"
    gene_count = Keyword.get(hyperparams, :gene_count) || raise ArgumentError, "Specify :gene_count in hyperparams"


    init_population(experiment, pop_size, gene_count)
    # create population, then
    #  start lifecycle
    #  score & rank population - gather mean score, best this gen, GOAT
    #  select/cull?
    #  repopulate - use crossover or other sexual mutation - spec in experiment?
    #  mutate
    #  continue lifecycle until we stabilize, or hit max generations
  end

  def init_population(experiment, pop_size, gene_count) do
    pop_members = Stream.repeatedly(fn -> experiment.new_individual(gene_count) end)
      |> Enum.take(pop_size)
    %Population{members: pop_members, target_size: pop_size}
  end

  def score_list(scored, [], _, _), do: scored
  def score_list(scored, [next_unscored | remaining_unscored], experiment, domain) do
    new_scored = experiment.score(next_unscored, domain)
    score_list(scored ++ [new_scored], remaining_unscored, experiment, domain)
  end

  def score(experiment, population, domain) do
    scored_and_sorted_individuals = score_list([], population.members, experiment, domain)
      |> Enum.sort_by(&(&1).fitness, :desc)
    %Population{population | members: scored_and_sorted_individuals}
  end

  def cull_population(experiment, population, keep_portion) do
    experiment.cull_population(population, keep_portion)
  end

  def repopulate(experiment, population) do
    old_members = population.members
    start_count = Enum.count(old_members)
    new_members = Stream.repeatedly(fn -> experiment.mix_genes(Enum.fetch!(old_members, :rand.uniform(start_count) - 1), Enum.fetch!(old_members, :rand.uniform(start_count) - 1)) end)
      |> Enum.take(population.target_size - start_count)
    %Population{ population | members: old_members ++ new_members }
  end
end
