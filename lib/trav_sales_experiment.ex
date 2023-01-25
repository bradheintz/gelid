defmodule TravSalesExperiment do
	# config stuff like hyperparams
	# would do a struct and take a config but i'm trying not to treat this as OO
	# maybe have it load stuff from a config file or an in-memory kv store?
	# TODO figure out how to do this right & idiomatically
	@_city_count 20
	def city_count(), do: @_city_count

	@behaviour Experiment

	def add_genes(genes, 0), do: genes
	def add_genes(genes, num_left) do
		add_genes([Enum.random(0..(num_left - 1)) | genes], num_left - 1)
	end

  @impl Experiment
  def new_individual() do
  	%Individual{ genes: add_genes([], @_city_count) }
  end
end