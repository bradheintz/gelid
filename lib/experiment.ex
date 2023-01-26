defmodule Experiment do
  @callback new_individual(gene_count :: integer) :: Enum.t
  @callback new_domain(domain_size :: integer) :: Domain
  @callback score(individual :: Individual.t, domain :: any) :: float
  # @callback scoring_function(Individual, Domain) :: Individual
  # @callback repopulation_function(Enum.t, Domain, integer) :: Enum.t
  # @callback done?(Enum.t, Domain, Enum.t, Map.t) :: boolean()

  def hello do
    :world
  end
end
