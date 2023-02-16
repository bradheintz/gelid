city_count = 100

hyperparams = [
	population_size: 10000,
	max_generations: 100, # 1000,
	gene_count: city_count, # equal to domain size
	keep_portion: 0.5,
	mutation_rate: 0.01,
	domain_size: city_count,
	report_mode: 1
]

Gelid.run(TravSalesExperiment, hyperparams)