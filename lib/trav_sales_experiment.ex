defmodule TravSalesExperiment do
	@behaviour Experiment

  @max_generations 10


  @impl Experiment
  def new_individual(gene_count) do
  	%Individual{ genes: add_genes(gene_count) }
  end

  def add_genes(0), do: []
  def add_genes(genes_left), do: [ :rand.uniform(genes_left) - 1 | add_genes(genes_left - 1) ]


  @impl Experiment
  def new_domain(domain_size), do: CityMap.build(domain_size)


  # expect domain to be a map
  @impl Experiment
  def score(individual, _) when individual.fitness > 0.0, do: individual
  def score(individual, domain) do
  	max_possible = (length(domain.cities) - 1) * Float.pow(2.0, 0.5)
    # IO.inspect(individual.genes)

  	actual_distance = calc_distance(domain.cities, individual.genes) # going from generic to specific here

  	%Individual{ individual | fitness: max_possible - actual_distance }
  end


  def _two_city_distance([c1x,c1y], [c2x,c2y]) do
  	dx = c1x - c2x
  	dy = c1y - c2y

  	Float.pow(dx * dx + dy * dy, 0.5)
  end

  def calc_distance(cities, genes) do
    [ first_gene | remaining_genes ] = genes
    { first_city, possible_next_cities } = List.pop_at(cities, first_gene)
    calc_distance(first_city, possible_next_cities, remaining_genes)
  end
  def calc_distance(_, [], _), do: 0.0
  def calc_distance(first_city, possible_next_cities, [first_gene | remaining_genes]) do
    { next_city, remaining_cities } = List.pop_at(possible_next_cities, first_gene)
    # IO.write("FIRST CITY\n")
    # IO.inspect(first_city)
    # IO.write("NEXT CITY\n")
    # IO.inspect(next_city)
    _two_city_distance(first_city, next_city) + calc_distance(next_city, remaining_cities, remaining_genes)
  end

  @impl Experiment
  def cull_population(population, keep_portion) do
  	# NB using a dumb strategy for the moment
  	%Population{ population | members: Enum.take(population.members, floor(length(population.members) * keep_portion))}
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
    # NB right now this just creates one offspring - this is intentional, but is a potential point of change to open

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