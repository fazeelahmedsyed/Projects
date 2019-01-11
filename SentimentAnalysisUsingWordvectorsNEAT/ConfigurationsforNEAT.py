#Loading Package

import configparser

#Creating sections in config file

my_config = configparser.ConfigParser()
my_config['NEAT'] = {'fitness_criterion' : 'max',
                    'fitness_threshold' : '9600',
                    'pop_size' : '200',
                    'reset_on_extinction' : 'False'}
my_config['DefaultGenome'] = {'activation_default' : 'sigmoid','activation_mutate_rate' : '0.0','activation_options' : 'sigmoid',
                             'aggregation_default' : 'sum','aggregation_mutate_rate' : '0.0','aggregation_options' : 'sum',
                             'bias_init_mean' : '0.0','bias_init_stdev' : '1.0','bias_max_value' : '30.0','bias_min_value' : '-30.0','bias_mutate_power' : '0.5','bias_mutate_rate' : '0.7','bias_replace_rate' : '0.1',
                             'compatibility_disjoint_coefficient' : '1.0','compatibility_weight_coefficient' : '0.5',
                             'conn_add_prob' : '0.5','conn_delete_prob' : '0.5','enabled_default' : 'True',
                             'enabled_mutate_rate' : '0.2',
                             'feed_forward' : 'True',
                             'initial_connection' : 'unconnected',
                             'node_add_prob' : '0.2','node_delete_prob' : '0.2',
                             'num_hidden' : '100','num_inputs' : '300','num_outputs' : '1',
                             'response_init_mean' : '1.0','response_init_stdev' : '0.0','response_max_value' : '30.0','response_min_value' : '-30.0','response_mutate_power' : '0.0','response_mutate_rate' : '0.0','response_replace_rate' : '0.0',
                             'weight_init_mean' : '0.0','weight_init_stdev' : '0.0','weight_max_value' : '30.0','weight_min_value' : '-30.0',
                             'weight_mutate_power' : '0.5','weight_mutate_rate' : '0.8','weight_replace_rate' : '0.1'
                             }
my_config['DefaultSpeciesSet'] = {'compatibility_threshold':'3.0'}
my_config['DefaultStagnation'] = {'species_fitness_func': 'max',
                                   'max_stagnation':'5',
                                   'species_elitism':'2'}
my_config['DefaultReproduction'] = {'elitism':'2',
                                     'survival_threshold':'0.2'}
#Saving file

with open('settings.ini', 'w') as f:
  my_config.write(f)