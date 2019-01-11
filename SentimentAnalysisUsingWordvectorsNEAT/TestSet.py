#Loading Packages and mounting google drive

import pickle
import pandas as pd
import numpy as np
from gensim.models import KeyedVectors
from gensim.utils import SaveLoad
from google.colab import drive
drive.mount('/content/gdrive')

#Loading google vectors and gensim model from drive

googlevecs = KeyedVectors.load_word2vec_format('/content/gdrive/My Drive/GoogleNews-vectors-negative300.bin', binary=True) #Path should be given where google News wordvectors are saved
model = SaveLoad.load('/content/gdrive/My Drive/Thesis/wordvectors') #Path should be given where the model created using gensim is saved

#Loading test list

with open('test_list.txt','rb') as f:
  test_list = pickle.load(f)

#Creating test set inputs

test_inputs = list()
for sentence in test_list:
  v = np.zeros(300)
  for word in sentence:
    if word in model.wv:
      v += model.wv[word]
    elif word in googlevecs:
      v += googlevecs[word]
    else:
      continue
  sv = tuple(v)
  test_inputs.append(sv)

#Saving test inputs

with open('test_inputs.txt','wb') as f:
  pickle.dump(test_inputs, f)