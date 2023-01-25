defmodule Experiment do
  @callback new_individual() :: Enum.t
  # @callback domain_instance(integer) :: Domain
  # @callback scoring_function(Individual, Domain) :: Individual
  # @callback repopulation_function(Enum.t, Domain, integer) :: Enum.t
  # @callback done?(Enum.t, Domain, Enum.t, Map.t) :: boolean()

  def hello do
    :world
  end
end
