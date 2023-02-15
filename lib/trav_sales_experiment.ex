defmodule TravSalesExperiment do
	@behaviour Experiment

  @max_generations 10


  @impl Experiment
  def new_individual(gene_count) do
  	%Individual{ genes: add_genes([], gene_count) }
  end

	def add_genes(genes, 0), do: genes
	def add_genes(genes, num_left) do
		add_genes([Enum.random(0..(num_left - 1)) | genes], num_left - 1)
	end


  @impl Experiment
  def new_domain(domain_size), do: CityMap.build(domain_size)


  # expect domain to be a map
  @impl Experiment
  def score(individual, _) when individual.fitness > 0.0, do: individual
  def score(individual, domain) do
  	max_possible = (length(domain.cities) - 1) * Float.pow(2.0, 0.5)
  	actual_distance = calc_distance(individual.genes, domain.cities) # going from generic to specific here

  	%Individual{ individual | fitness: max_possible - actual_distance }
  end


  def _two_city_distance(nil, _), do: 0.0
  def _two_city_distance([c1x,c1y], [c2x,c2y]) do
  	dx = c1x - c2x
  	dy = c1y - c2y

  	Float.pow(dx * dx + dy * dy, 0.5)
  end

  def _calc_distance(_, [], _), do: 0
  def _calc_distance(curr_city, possible_next_cities, [next_gene | remaining_genes]) do
  	{ next_city, remaining_cities } = List.pop_at(possible_next_cities, next_gene)
  	_two_city_distance(curr_city, next_city) + _calc_distance(next_city, remaining_cities, remaining_genes)
  end

  def calc_distance(genes, cities) do
  	_calc_distance(nil, cities, genes)
  end

  @impl Experiment
  def cull_population(population, keep_portion) do
  	# NB using a dumb strategy for the moment
  	%Population{ population | members: Enum.take(population.members, floor(Enum.count(population.members) * keep_portion))}
  end


  def maybe_mutate(new_child, mutation_rate) do
    if :rand.uniform() < mutation_rate do
      mutate_one_gene(new_child)
    else
      new_child
    end
  end

  @impl Experiment
  def mix_genes(parent1, parent2, mutation_rate) do
    # crossover
    cross_idx = :rand.uniform(length(parent1.genes)) # TODO this leaves open the possibility of a clone - fix that?
    # NB right now this just creates one offspring - this intentional, but is as potential point of change to open

    {{ hchild, _ }, { _, tchild }} = { Enum.split(parent1.genes, cross_idx), Enum.split(parent2.genes, cross_idx) }

    %Individual{ genes: hchild ++ tchild } |> maybe_mutate(mutation_rate)
  end

  @impl Experiment
  def mutate_one_gene(ind) do
    l = length(ind.genes) - 1 # because last gene never changes
    mutuation_idx = :rand.uniform(l) - 1
    new_value = :rand.uniform(l - mutuation_idx) - 1
    %Individual{ genes: List.replace_at(ind.genes, mutuation_idx, new_value)}
  end

  @impl Experiment
  def done?(generation_number) do
    generation_number >= @max_generations # TODO this should actually be set in hyperparams
  end
end