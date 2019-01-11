#Loading Packages and mounting google drive

import pandas as pd
import numpy as np
import pickle
from textblob import TextBlob
from gensim.utils import SaveLoad
from google.colab import drive
drive.mount('/content/gdrive')

#Loading lemma list and Word2vec model

with open('lemma_list.txt','rb') as f:
  lemma_list = pickle.load(f)
  
model = SaveLoad.load('/content/gdrive/My Drive/Thesis/wordvectors') #Path should be given where the model created using gensim is saved

#Creating inputs

inputs_main = list()
for sentence in lemma_list:
  v = np.zeros(300)
  for word in sentence:
    if TextBlob(word).sentiment.polarity != 0:
      v += model.wv[word]
    else:
      continue
  sv = tuple(v)
  inputs_main.append(sv)

#Saving inputs

with open('lexiinputs_main.txt','wb') as f:
  pickle.dump(inputs_main,f)