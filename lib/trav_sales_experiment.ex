defmodule TravSalesExperiment do
	@behaviour Experiment


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
  	max_possible = (Enum.count(domain.cities) - 1) * Float.pow(2.0, 0.5)
  	actual_distance = calc_distance(individual.genes, domain.cities) # going from generic to specific here
  	%Individual{individual | fitness: max_possible - actual_distance}
  end


  def _two_city_distance(nil, _), do: 0.0
  def _two_city_distance(c1, c2) do
  	[c1x,c1y] = c1
  	[c2x,c2y] = c2
  	dx = c1x - c2x
  	dy = c1y - c2y
  	Float.pow(dx * dx + dy * dy, 0.5)
  end

  # TODO recurse this once computation is fixed
  def _calc_distance(dist_acc, _, [], _), do: dist_acc
  def _calc_distance(dist_acc, curr_city, possible_next_cities, [next_gene | remaining_genes]) do
  	{ next_city, remaining_cities } = List.pop_at(possible_next_cities, next_gene)
  	_calc_distance(dist_acc + _two_city_distance(curr_city, next_city), next_city, remaining_cities, remaining_genes)
  end

  def calc_distance(genes, cities) do
  	_calc_distance(0.0, nil, cities, genes)
  end
end