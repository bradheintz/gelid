hyperparams = [
	population_size: 1000,
	max_generations: 1000,
	gene_count: 10, # equal to domain size
	keep_portion: 10,
	mutation_rate: 0.005,
	domain_size: 10 ]
final_pop = Gelid.run(TravSalesExperiment, hyperparams)