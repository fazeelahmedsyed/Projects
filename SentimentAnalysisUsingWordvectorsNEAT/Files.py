#Loading Packages

import urllib
import zipfile
import gzip
import os
import pandas as pd

#Downloading Dataset

url = 'http://nlp.stanford.edu/~socherr/stanfordSentimentTreebank.zip'
response = urllib.request.urlretrieve(url, 'Stanford.zip')
zipfile.ZipFile('Stanford.zip').extractall()

#Reading Files

def get_phrase_sentiments(base_directory):
  def group_labels(label):
    if label in ['very negative','negative']: 
      return 'negative'
    elif label in ['positive','very positive']:
      return 'positive'
    else:
      return 'neutral'
    
  dictionary = pd.read_csv(os.path.join(base_directory, 'dictionary.txt'), sep = '|')
  dictionary.columns = ['phrase', 'id']
  dictionary = dictionary.set_index('id')
  
  sentiment_labels = pd.read_csv(os.path.join(base_directory, 'sentiment_labels.txt'), sep = '|')
  sentiment_labels.columns = ['id', 'sentiment']
  sentiment_labels.set_index('id')
  
  phrase_sentiments = dictionary.join(sentiment_labels)
  phrase_sentiments['fine'] = pd.cut(phrase_sentiments.sentiment, [0,0.2,0.4, 0.6, 0.8, 1.0], include_lowest = True, labels = ['very negative', 'negative', 'neutral', 'positive', 'very positive'])
  phrase_sentiments['coarse'] = phrase_sentiments.fine.apply(group_labels)
  
  return phrase_sentiments

def get_sentence_partitions(base_directory):
  sentences = pd.read_csv(os.path.join(base_directory, 'datasetSentences.txt'), index_col = 'sentence_index', sep = '\t')
  splits = pd.read_csv(os.path.join(base_directory, 'datasetSplit.txt'), index_col = 'sentence_index')
  return sentences.join(splits)

path = os.path.abspath('stanfordSentimentTreebank')

phrases = get_phrase_sentiments(path).set_index('phrase')

sentences = get_sentence_partitions(path)
sentences.sentence = sentences.sentence.apply(lambda x: x.encode('latin').decode('utf-8')).str.replace('-LRB-','(').str.replace('-RRB-',')') #included after analysing fetched data
sentences.set_index('sentence', inplace = True)

data = sentences.join(phrases)
data = data.reset_index().rename(columns = {'index':'sentence'})

train = data.loc[data.splitset_label.isin([1,3])].copy()
test = data.loc[data.splitset_label == 2].copy()

#Writing files to working directory

data.to_csv('data.csv')
train.to_csv('train.csv')
test.to_csv('test.csv')