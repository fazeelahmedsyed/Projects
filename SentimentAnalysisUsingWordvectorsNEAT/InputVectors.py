#Loading/Installing Packages and mounting google drive

%env PYTHONHASHSEED = 1
!pip install --upgrade gensim
!pip install --upgrade stemming
import nltk
import pandas as pd
import numpy as np
import pickle
from gensim.models import Word2Vec
from stemming.porter2 import stem 
from string import punctuation
from google.colab import drive
drive.mount('/content/gdrive')

#Reading Files

train = pd.read_csv('train.csv', index_col = 0)
test = pd.read_csv('test.csv', index_col = 0)
data = pd.read_csv('data.csv', index_col = 0)

#Downloading dependencies

nltk.download(['stopwords','wordnet'])
stopwords = nltk.corpus.stopwords.words('english')
lemma = nltk.wordnet.WordNetLemmatizer()

#Pre-processing text

lemma_list = list()
for sentence in train.sentence:
  s = [''.join([i for i in lemma.lemmatize(word) if not i.isdigit()]) for word in nltk.tokenize.TreebankWordTokenizer().tokenize(sentence.lower()) if word and word not in stopwords and word not in punctuation]
  clean_s = list(filter(None, s))    
  lemma_list.append(clean_s)

test_list = list()
for sentence in test.sentence:
  s = [''.join([i for i in lemma.lemmatize(word) if not i.isdigit()]) for word in nltk.tokenize.TreebankWordTokenizer().tokenize(sentence.lower()) if word and word not in stopwords and word not in punctuation]
  clean_s = list(filter(None, s))
  test_list.append(s)

#Converting text to word vectors

%time model = Word2Vec(lemma_list, size=300, window=5, min_count=1, workers=1, seed=1)
%time model.intersect_word2vec_format('/content/gdrive/My Drive/GoogleNews-vectors-negative300.bin', lockf = 1.0, binary = True) #Accessing google's GoogleNews word vectors from google drive. Details for obtaining them can be found at: https://code.google.com/archive/p/word2vec
model.save('/content/gdrive/My Drive/Thesis/wordvectors') #Saving model to google drive for future use

#Creating inputs

inputs_main = list()
for sentence in lemma_list:
  v = np.zeros(300)
  for word in sentence:
    v += model.wv[word]
  sv = tuple(v)
  inputs_main.append(sv)

#Saving Inputs

with open('inputs_main.txt','wb') as f:
  pickle.dump(inputs_main,f)
  
#Saving lists

with open('lemma_list.txt','wb') as f:
  pickle.dump(lemma_list, f)

with open('test_list.txt','wb') as f:
  pickle.dump(test_list, f)
