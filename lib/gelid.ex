defmodule Gelid do
  import Bitwise

  def gethp(hyperparams, k) do
    Keyword.get(hyperparams, k) || raise ArgumentError, "Specify #{k} in hyperparameters"
  end

  def gethp(hyperparams, k, default) do
    Keyword.get(hyperparams, k, default)
  end

  def run(experiment, hyperparams) do
    pop_size = gethp(hyperparams, :population_size)
    max_gens = gethp(hyperparams, :max_generations)
    gene_count = gethp(hyperparams, :gene_count)
    mutation_rate = gethp(hyperparams, :mutation_rate)
    domain_size = gethp(hyperparams, :domain_size)
    keep_portion = gethp(hyperparams, :keep_portion)
    report_mode = gethp(hyperparams, :report_mode, 0) # 0 is nothing output

    domain = experiment.new_domain(domain_size)
    # IO.inspect(domain)
    init_population(experiment, pop_size, gene_count)
      |> score(domain)
      |> report(0, "BEGIN", report_mode)
      |> advance_generations_until_done(domain, keep_portion, mutation_rate, report_mode, 1, max_gens)
      |> score(domain) # one last time
      |> report(max_gens, "FINAL", report_mode)
  end

  def init_population(experiment, pop_size, gene_count) do
    pop_members = Stream.repeatedly(fn -> experiment.new_individual(gene_count) end)
      |> Enum.take(pop_size)
    %Population{ members: pop_members, target_size: pop_size, experiment: experiment }
  end

  def advance_generations_until_done(population, _, _, _, _, gen_num, gen_max) when gen_num >= gen_max, do: population
  def advance_generations_until_done(population, domain, keep_portion, mutation_rate, report_mode, gen_num, gen_max) do
      population
        |> report(gen_num, "entering", report_mode &&& 2)
        |> cull_population(keep_portion)
        |> report(gen_num, "after cull", report_mode &&& 2)
        |> repopulate(mutation_rate)
        |> report(gen_num, "after repopulation", report_mode &&& 2)
        |> score(domain)
        |> report(gen_num, "scored and sorted", report_mode)
        |> advance_generations_until_done(domain, keep_portion, mutation_rate, report_mode, gen_num + 1, gen_max)
  end

  def score_list([], _, _), do: []
  def score_list([next_unscored | remaining_unscored], experiment, domain) do
    [experiment.score(next_unscored, domain) | score_list(remaining_unscored, experiment, domain)]
  end

  def score(population, domain) do
    scored_and_sorted_individuals = population.members
      |> score_list(population.experiment, domain)
      |> Enum.sort_by(&(&1).fitness, :desc)

    %Population{population | members: scored_and_sorted_individuals}
  end

  def cull_population(population, keep_portion) do
    population.experiment.cull_population(population, keep_portion)
  end

  def repopulate(population, mutation_rate) do
    old_members = population.members

    new_members = Stream.repeatedly(fn -> population.experiment.mix_genes(Enum.random(old_members), Enum.random(old_members), mutation_rate) end)
      |> Enum.take(population.target_size - length(old_members))

    %Population{ population | members: old_members ++ new_members }
  end

  def report(population, _, _, 0), do: population # silent for automated testing
  def report(population, gen_num, step, 2) do # dump raw for debug
    report(population, gen_num, step, 1)
    IO.inspect(population.members)

    population
  end
  def report(population, gen_num, step, 1) do # lo-fi screen dump with max/avg/min
    scores = Enum.map(population.members, fn x -> x.fitness end)
    count = length(scores)
    { min, max } = Enum.min_max(scores)
    sum = Enum.sum(scores)

    IO.write("\n\nGeneration #{gen_num} #{step}:\n")
    # IO.write("  #{count} members\n")
    IO.write("  [ MAX | AVG | MIN ] : [ #{max} | #{sum/count} | #{min} ]\n")

    population
  end
end
