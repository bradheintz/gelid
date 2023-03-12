city_count = 10

hyperparams = [
	population_size: 100,
	max_generations: 100,
	gene_count: city_count, # equal to domain size
	keep_portion: 0.5,
	mutation_rate: 0.01,
	domain_size: city_count,
	report_mode: 4,
	seed: 1729
]

Gelid.run(TravSalesExperiment, hyperparams)
