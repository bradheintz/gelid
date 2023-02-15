defmodule Experiment do
  @callback new_individual(gene_count :: integer) :: Enum.t
  @callback new_domain(domain_size :: integer) :: Domain
  @callback score(individual :: Individual.t, domain :: any) :: float
  @callback cull_population(population :: Population.t, keep_portion :: float) :: Population.t
  @callback mix_genes(parent1 :: Individual.t, parent2 :: Individual.t, mutation_rate :: integer) :: Individual.t
  @callback mutate_one_gene(ind :: Individual.t) :: Individual.t
  # @callback done?(Enum.t, Domain, Enum.t, Map.t) :: boolean()

  def hello do
    :world
  end
end
