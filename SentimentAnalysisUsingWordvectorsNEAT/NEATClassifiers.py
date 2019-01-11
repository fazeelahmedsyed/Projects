#Loading/Installing Packages, setting dependencies and mounting google drive

%env PYTHONHASHSEED = 1
!pip install --upgrade neat-python
import pandas as pd
import neat
import pickle
from google.colab import drive
drive.mount('/content/gdrive')

#Loading files
data = pd.read_csv('data.csv', index_col = 0)
with open('inputs_main.txt', 'rb') as f:
  inputs_main = pickle.load(f)

#Creating necessary data objects

actual_vn = data.fine.copy().replace({'very negative':1,'negative':0,'neutral':0,'positive':0,'very positive':0}).tolist()
actual_n = data.fine.copy().replace({'very negative':0,'negative':1,'neutral':0,'positive':0,'very positive':0}).tolist()
actual_neu = data.fine.copy().replace({'very negative':0,'negative':0,'neutral':1,'positive':0,'very positive':0}).tolist()
actual_p = data.fine.copy().replace({'very negative':0,'negative':0,'neutral':0,'positive':1,'very positive':0}).tolist()
actual_vp = data.fine.copy().replace({'very negative':0,'negative':0,'neutral':0,'positive':0,'very positive':1}).tolist()

#Defining NEAT functions

def eval_genomes(genomes, config): #makes a genome evaluator
  for genome_id, genome in genomes:
    genome.fitness = 9645
    net = neat.nn.FeedForwardNetwork.create(genome,config) #gives the structure to use. U can also choose a recurrent network
    for xi,xo in zip(inputs_main, actual):
      output = net.activate(xi)
      genome.fitness -= (output[0] - xo)**2
       
def run(config_file): #run requires a population object that must contain a config object
  config = neat.Config(neat.DefaultGenome, neat.DefaultReproduction, neat.DefaultSpeciesSet, neat.DefaultStagnation, config_file)
  p = neat.Population(config)  
  p.add_reporter(neat.StdOutReporter(True)) #allows for reporting on the terminal
  stats = neat.StatisticsReporter(); p.add_reporter(stats) #adds a stats reporter
  p.add_reporter(neat.Checkpointer(5)) #adds a checkpointer reporter
  winner = p.run(eval_genomes,50) #runs upto as many generations or uptil the fitness threshold in the config file
  return winner

#Defining function for saving objects on google drive

def save_object(obj, filename):
    with gzip.open('/content/gdrive/My Drive/Thesis/{}'.format(filename), 'w', compresslevel=5) as f: #Any path should be given where the classifiers should be saved
        pickle.dump(obj, f, protocol=pickle.HIGHEST_PROTOCOL)

#Running classifiers for 50 iterations and saving winning genomes

actual = actual_vn.copy() #have to give as global variable as neat-python does not allow for adding parameter
%time winner_vn = run('settings.ini')
save_object(winner_vn, 'winner_vn')

actual = actual_n.copy() #have to give as global variable as neat-python does not allow for adding parameter
%time winner_n = run('settings.ini')
save_object(winner_n, 'winner_n')

actual = actual_neu.copy() #have to give as global variable as neat-python does not allow for adding parameter
%time winner_neu = run('settings.ini')
save_object(winner_neu, 'winner_neu')

actual = actual_p.copy() #have to give as global variable as neat-python does not allow for adding parameter
%time winner_p = run('settings.ini')
save_object(winner_p, 'winner_p')

actual = actual_vp.copy() #have to give as global variable as neat-python does not allow for adding parameter
%time winner_vp = run('settings.ini')
save_object(winner_vp, 'winner_vp')