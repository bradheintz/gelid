defmodule Gelid do
  # TODO should i pass in just the fn instead of the whole experiment?
  # experiment becomes a binder for all steps if i include everywhere
  # including just the fn is more generic
  # but i also don't think i'm looking to reuse heavily outside here...
  def add_pop(pop_list, _, 0, _), do: pop_list
  def add_pop(pop_list, experiment, num_left, gene_count) do
    add_pop([experiment.new_individual(gene_count) | pop_list], experiment, num_left - 1, gene_count)
  end


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
    pop_list = add_pop([], experiment, pop_size, gene_count)
    %Population{members: pop_list, target_size: pop_size}
  end

  def score_list(scored, [], _, _), do: scored
  def score_list(scored, [next_unscored | remaining_unscored], experiment, domain) do
    new_scored = experiment.score(next_unscored, domain)
    score_list(scored ++ [new_scored], remaining_unscored, experiment, domain)
  end

  def score(experiment, population, domain) do
    # TODO do this in a more elixirish way with |> operator
    individuals_to_score = population.members
    scored_individuals = score_list([], individuals_to_score, experiment, domain)
    sorted_individuals = Enum.sort_by(scored_individuals, &(&1).fitness, :desc)
    %Population{population | members: sorted_individuals}
  end

  def cull_population(experiment, population, keep_portion) do
    experiment.cull_population(population, keep_portion)
  end
end
