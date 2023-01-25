defmodule Gelid do
  # TODO should i pass in just the fn instead of the whole experiment?
  # experiment becomes a binder for all steps if i include everywhere
  # including just the fn is more generic
  # but i also don't think i'm looking to reuse heavily outside here...
  def add_pop(pop_list, _, 0), do: pop_list
  def add_pop(pop_list, experiment, num_left) do
    add_pop([experiment.new_individual() | pop_list], experiment, num_left - 1)
  end


  def run(experiment, hyperparams) do
    pop_size = Keyword.get(hyperparams, :population_size) || raise ArgumentError, "Specify :population_size in hyperparams"
    max_gens = Keyword.get(hyperparams, :max_generations) || raise ArgumentError, "Specify :max_generations in hyperparams"


    init_population(experiment, pop_size)
    # create population, then
    #  start lifecycle
    #  score & rank population - gather mean score, best this gen, GOAT
    #  select/cull?
    #  repopulate - use crossover or other sexual mutation - spec in experiment?
    #  mutate
    #  continue lifecycle until we stabilize, or hit max generations
  end

  def init_population(experiment, pop_size) do
    pop_list = add_pop([], experiment, pop_size)
    %Population{members: pop_list, population_size: pop_size}
  end

end
