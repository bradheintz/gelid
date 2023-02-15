defmodule Gelid do
  def gethp(hyperparams, k) do
    Keyword.get(hyperparams, k) || raise ArgumentError, "Specify #{k} in hyperparameters"
  end

  def run(experiment, hyperparams) do
    pop_size = gethp(hyperparams, :population_size)
    max_gens = gethp(hyperparams, :max_generations)
    gene_count = gethp(hyperparams, :gene_count)
    mutation_rate = gethp(hyperparams, :mutation_rate)
    domain_size = gethp(hyperparams, :domain_size)
    keep_portion = gethp(hyperparams, :keep_portion)

    domain = experiment.new_domain(domain_size)
    init_population(experiment, pop_size, gene_count)
      |> advance_generations_until_done(experiment, domain, keep_portion, mutation_rate, 0, max_gens)
  end

  def advance_generations_until_done(population, _, _, _, _, gen_num, gen_max) when gen_num >= gen_max, do: population
  def advance_generations_until_done(population, experiment, domain, keep_portion, mutation_rate, gen_num, gen_max) do
      population |> score(experiment, domain)
        |> cull_population(experiment, keep_portion)
        |> repopulate(experiment, mutation_rate)
        # report/dump state
        |> advance_generations_until_done(experiment, domain, keep_portion, mutation_rate, gen_num + 1, gen_max)
  end

  def init_population(experiment, pop_size, gene_count) do
    pop_members = Stream.repeatedly(fn -> experiment.new_individual(gene_count) end)
      |> Enum.take(pop_size)
    %Population{members: pop_members, target_size: pop_size}
  end

  def score_list([], _, _), do: []
  def score_list([next_unscored | remaining_unscored], experiment, domain) do
    [experiment.score(next_unscored, domain) | score_list(remaining_unscored, experiment, domain)]
  end

  def score(population, experiment, domain) do
    scored_and_sorted_individuals = population.members
      |> score_list(experiment, domain)
      |> Enum.sort_by(&(&1).fitness, :desc)

    %Population{population | members: scored_and_sorted_individuals}
  end

  def cull_population(population, experiment, keep_portion) do
    experiment.cull_population(population, keep_portion)
  end

  def repopulate(population, experiment, mutation_rate) do
    old_members = population.members
    start_count = length(old_members)

    new_members = Stream.repeatedly(fn -> experiment.mix_genes(Enum.fetch!(old_members, :rand.uniform(start_count) - 1), Enum.fetch!(old_members, :rand.uniform(start_count) - 1), mutation_rate) end)
      |> Enum.take(population.target_size - start_count)

    %Population{ population | members: old_members ++ new_members }
  end
end
