#Loading packages and mounting google drive

import neat
import pickle
import pandas as pd
from google.colab import drive
drive.mount('/content/gdrive')

#Defining function to load objects from google drive

def load_object(filename):
    with gzip.open('/content/gdrive/My Drive/Thesis/{}'.format(filename)) as f:
        obj = pickle.load(f)
        return obj

#Loading classifiers

lexiwinner_vn = load_object('lexiwinner_vn')
lexiwinner_n = load_object('lexiwinner_n')
lexiwinner_neu = load_object('lexiwinner_neu')
lexiwinner_p = load_object('lexiwinner_p')
lexiwinner_vp = load_object('lexiwinner_vp')

#Loading test_inputs
with open('lexitest_inputs.txt','rb') as f:
  test_inputs = pickle.load(f)

#Creating neural networks from winning genomes

config = neat.Config(neat.DefaultGenome, neat.DefaultReproduction, neat.DefaultSpeciesSet, neat.DefaultStagnation, 'settings.ini')

net_vn = neat.nn.FeedForwardNetwork.create(lexiwinner_vn,config)
net_n = neat.nn.FeedForwardNetwork.create(lexiwinner_n,config)
net_neu = neat.nn.FeedForwardNetwork.create(lexiwinner_neu,config)
net_p = neat.nn.FeedForwardNetwork.create(lexiwinner_p,config)
net_vp = neat.nn.FeedForwardNetwork.create(lexiwinner_vp,config)

#Creating solution set

solution = pd.DataFrame({'vn': [net_vn.activate(x)[0] for x in test_inputs],
                         'n': [net_n.activate(x)[0] for x in test_inputs],
                         'neu': [net_neu.activate(x)[0] for x in test_inputs],
                         'p': [net_p.activate(x)[0] for x in test_inputs],
                         'vp':[net_vp.activate(x)[0] for x in test_inputs]
                        })
solution = solution.assign(preds = solution.idxmax(axis = 1)).assign(actual = data.loc[data.splitset_label == 2].fine.reset_index(drop = True).replace({'very negative':'vn','negative':'n','neutral':'n','positive':'p','very positive':'vp'}))

#Checking test accuracy

sum([1 if x==y else 0 for x,y in zip(solution.preds,solution.actual)])/len(solution.actual)