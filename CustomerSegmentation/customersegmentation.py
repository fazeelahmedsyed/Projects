from google.colab import drive
drive.mount('/content/gdrive')
from zipfile import ZipFile as zp
import pandas as pd
import re
!pip install --upgrade gensim
import gensim.models
!pip install --upgrade pyclustering
from pyclustering.cluster.kmedoids import kmedoids
from pyclustering.utils import calculate_distance_matrix
import pickle


zip('/content/gdrive/My Drive/ecommerce-data.zip', 'r').extractall(); data = pd.read_csv('data.csv', encoding = 'latin1'); data.dropna(inplace = True);
data.shape # 406829 total transactions
data.head()


len(data.Description.unique()) #There are 3896 different items, this means to make groups we will need to apply sth
len(data.StockCode.unique()) #3684. Wont help much in making groups.
len(data.CustomerID.unique()) #4372

NumCode = list(); AlphaCode = list()
for i in data.StockCode:
  splt = list(filter(None, re.split('(\D+)', i)))
  NumCode.append(splt[0])
  if len(splt) == 2: AlphaCode.append(splt[1])
  else: AlphaCode.append('')
data['NumCode'] = pd.Series(NumCode); data['AlphaCode'] = pd.Series(AlphaCode)
len(data.NumCode.unique()) # 3184 NumCodes arent a good option to create product categories

#Creating product categories out of scratch

Products = data.Description.unique().tolist()
worded_Products = list(); i = 1
for product in Products:
  print(i); i += 1
  worded_product = [word for word in product.split(' ')]
  worded_Products.append(worded_product)


%time model = gensim.models.KeyedVectors.load_word2vec_format('/content/gdrive/My Drive/GoogleNews-vectors-negative300.bin', binary = True)
model.init_sims(replace = True)


matrix = list()
for i in list(range(0,3896)):
  row = list()
  for j in list(range(0,3896)):
    distance = model.wmdistance(worded_Products[i], worded_Products[j])
    row.append(distance)
  matrix.append(row)
  print(i)

with  open('/content/gdrive/My Drive/distancematrix.pickle', 'wb') as f:
  pickle.dump(matrix,f)
with open('/content/gdrive/My Drive/distancematrix.pickle', 'rb') as f:
  matrix = pickle.load(f)

initial_medoids = list(range(0,100))
kmedoids_instance = kmedoids(matrix, initial_medoids, data_type='distance_matrix')
kmedoids_instance.process()
kmedoids_instance.get_clusters()
kmedoids_instance.get_medoids()


letters = list('ABCDEFGHIJKLMNOPQRSTUVWXYZ'); letters.extend([i+b for i in letters for b in letters])
category = [None] * 3896
for i, cluster in enumerate(kmedoids_instance.get_clusters()):
  for x in cluster:
    category[x] = letters[i]
  print(i)

categories = pd.DataFrame({'Description':data.Description.unique(),'product_category': category})
data = pd.merge(data,categories,on = 'Description',how = 'left')

data.Country.value_counts()# around 90% of all transactions are from UK
data = data.loc[data.Country == 'United Kingdom']
data.product_category.value_counts() <5 # One category is less than 5 and is useless
data = data.loc[data.product_category != 'CC']
data.InvoiceDate = pd.to_datetime(data.InvoiceDate)
data.CustomerID = data.CustomerID.astype(int).astype('category')
data.product_category = data.product_category.astype('category')
data['amount'] = data.UnitPrice*data.Quantity
with open('/content/gdrive/My Drive/segmentation_data','wb') as f:
  pickle.dump(data,f)
with open('/content/gdrive/My Drive/segmentation_data','rb') as f:
  data = pickle.load(f)

# RFM Calculations

frequencies = pd.DataFrame({'CustomerID' : data.CustomerID.value_counts().index, 'frequency' : data.CustomerID.value_counts()})
frequencies['freqqt'] = pd.qcut(frequencies.frequency, q = 5, labels = ['1st','2nd','3rd','4th','5th'])

values = data[['CustomerID','amount']].groupby('CustomerID').sum().round(2)
values.reset_index(inplace = True); values.rename(columns = {'amount': 'monetary_value'}, inplace = True)

values['valueqt'] = pd.qcut(values.monetary_value, q = 5, labels = ['1st','2nd','3rd','4th','5th'])

recencies = pd.DataFrame({'CustomerID' : data.CustomerID, 'recencies' : max(data.InvoiceDate) - data.InvoiceDate})
recencies = recencies.groupby('CustomerID').min(); recencies.reset_index(inplace = True); recencies.rename(columns = {'recencies' : 'recency'}, inplace = True)
recencies['recqt'] = pd.qcut(recencies.recency, q = 5, labels = ['1st','2nd','3rd','4th','5th'])

avgs = data[['CustomerID','amount']].groupby('CustomerID').mean().round(2)
avgs.reset_index(inplace = True); avgs.rename(columns = {'amount':'avg_amnt_cust'}, inplace = True)

best_categories = data[['CustomerID','product_category']].groupby(['CustomerID', 'product_category']).size().to_frame(name = 'size').reset_index()
best_cats = pd.DataFrame(columns = ['CustomerID','cat1','cat2','cat3'])
for i, customer in enumerate(best_categories.CustomerID.unique()):
  cat1,cat2,cat3 = [None]*3
  xx = best_categories.loc[best_categories.CustomerID == customer].nlargest(3,'size').product_category.values
  if len(xx) ==3: 
    cat1,cat2,cat3 = xx 
  elif len(xx) ==2: 
    cat1,cat2 = xx
  else:
    cat1 = xx[0]
  bests = [customer,cat1,cat2,cat3]
  best_cats = best_cats.append(pd.Series(bests, index = ['CustomerID','cat1','cat2','cat3']), ignore_index = True)
  print(i)

visits = data[['CustomerID','InvoiceNo']].groupby('CustomerID').size().to_frame(name= 'visits').reset_index()

avgs2 = data[['InvoiceNo','amount']].groupby('InvoiceNo').sum().round(2).rename(columns = {'amount':'avg_amnt_visit'}).reset_index()
visitamounts = data[['CustomerID','InvoiceNo']].merge(avgs2, on = 'InvoiceNo', how = 'right').drop_duplicates()
avg_visit_amnts = visitamounts.groupby('CustomerID').mean().round(2).reset_index()

basketsize = data[['InvoiceNo','Quantity']].groupby('InvoiceNo').sum().rename(columns = {'Quantity':'basket_size'}).reset_index()
customerbaskets = data[['CustomerID','InvoiceNo']].merge(basketsize, on = 'InvoiceNo', how = 'right').drop_duplicates()
avg_bskt_size = customerbaskets[['CustomerID','basket_size']].groupby('CustomerID').mean().astype(int).reset_index()

Merging All now

customer_data = frequencies.merge(recencies, on = 'CustomerID',how = 'left').merge(values, on = 'CustomerID',how = 'left').merge(avgs, on = 'CustomerID',how = 'left').merge(avg_bskt_size, on = 'CustomerID',how = 'left').merge(visits, on = 'CustomerID',how = 'left').merge(avg_visit_amnts, on = 'CustomerID', how = 'left').merge(best_cats, on = 'CustomerID',how = 'left')
with open('/content/gdrive/My Drive/customerdata', 'wb') as f:
  pickle.dump(customer_data, f)
