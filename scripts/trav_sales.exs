hyperparams = [
	population_size: 1000,
	max_generations: 100, # 1000,
	gene_count: 20, # equal to domain size
	keep_portion: 0.5,
	mutation_rate: 0.005,
	domain_size: 20,
	report_mode: 1
]
final_pop = Gelid.run(TravSalesExperiment, hyperparams)
# IO.inspect(final_pop)