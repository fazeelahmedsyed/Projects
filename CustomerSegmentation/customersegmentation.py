# from google.colab import drive
# drive.mount('/content/gdrive')
# from zipfile import ZipFile as zp
# import pandas as pd
# import numpy as np
# import re
# import nltk; nltk.download('punkt'); nltk.download('averaged_perceptron_tagger')
# !pip install --upgrade gensim
# import gensim.models
# !pip install --upgrade pyclustering
# from pyclustering.cluster.kmedoids import kmedoids
# from pyclustering.cluster.kmeans import kmeans, kmeans_visualizer
# from pyclustering.cluster.center_initializer import kmeans_plusplus_initializer
# import pickle
# import matplotlib.pyplot as plt
# !pip install --upgrade kmodes
# from kmodes.kmodes import KModes


# zp('/content/gdrive/My Drive/ecommerce-data.zip', 'r').extractall(); data = pd.read_csv('data.csv', encoding = 'latin1'); data.dropna(inplace = True);
# data.shape # 406829 total transactions
# data.head()

# len(data.Description.unique()) #There are 3896 different items, this means to make groups we will need to apply sth
# len(data.StockCode.unique()) #3684. Wont help much in making groups.
# len(data.CustomerID.unique()) #4372

# NumCode = list(); AlphaCode = list()
# for i in data.StockCode:
#   splt = list(filter(None, re.split('(\D+)', i)))
#   NumCode.append(splt[0])
#   if len(splt) == 2: AlphaCode.append(splt[1])
#   else: AlphaCode.append('')
# data['NumCode'] = pd.Series(NumCode); data['AlphaCode'] = pd.Series(AlphaCode)
# len(data.NumCode.unique()) # 3184 NumCodes arent a good option to create product categories

# #Creating product categories out of scratch

# Products = data.Description.unique().tolist()
# worded_products = list(); i = 1
# for product in Products:
#   print(i); i += 1
#   tokenized = nltk.word_tokenize(product.lower()) ; noun_product = [word for (word, pos) in nltk.pos_tag(tokenized) if pos == 'NN' or pos == 'NNS'] 
#   worded_products.append(noun_product)

# %time model = gensim.models.KeyedVectors.load_word2vec_format('/content/gdrive/My Drive/GoogleNews-vectors-negative300.bin', binary = True)

# sentence_vectors = pd.DataFrame() ; i = 0
# for worded_product in worded_products:
#   sentence = np.empty(300)
#   for word in worded_product:
#     if word in model.wv:
#       vector = model.wv[word]
#     else:
#       #only 200 cases exist where worded_product has only 1 word. Some sentences may end up being zero arrays, but such a small number is fine.
#       vector = np.empty(300)
#     sentence += vector
#   sentence_vectors = sentence_vectors.append(pd.Series(sentence), ignore_index = True)
#   print(i); i += 1

# with open('/content/gdrive/My Drive/sentence_vectors','wb') as f:
#   pickle.dump(sentence_vectors,f)
# with open('/content/gdrive/My Drive/sentence_vectors','rb') as f:
#   sentence_vectors = pickle.load(f)

# initial_centers = kmeans_plusplus_initializer(sentence_vectors, 100).initialize()
# kmeans_instance = kmeans(sentence_vectors, initial_centers)
# kmeans_instance.process()

# len(kmeans_instance.get_clusters()) #95 clusters
# for cluster in kmeans_instance.get_clusters():
#   print(len(cluster))
# kmeans_instance.get_centers()

# letters = list('ABCDEFGHIJKLMNOPQRSTUVWXYZ'); letters.extend([i+b for i in letters for b in letters])
# category = [None] * 3896
# for i, cluster in enumerate(kmeans_instance.get_clusters()):
#   for x in cluster:
#     category[x] = letters[i]
#   print(i)

# categories = pd.DataFrame({'Description':data.Description.unique(),'product_category': category}); data = pd.merge(data,categories,on = 'Description',how = 'left')
# data.Country.value_counts()# around 90% of all transactions are from UK; data = data.loc[data.Country == 'United Kingdom']
# pd.Series(data.product_category.value_counts() <100).value_counts() # Only one category has been bought less than 100 times; categories seem useful
# data.product_category = data.product_category.astype('category')
# data.InvoiceDate = pd.to_datetime(data.InvoiceDate)
# data.CustomerID = data.CustomerID.astype(int).astype('category')
# data['amount'] = data.UnitPrice*data.Quantity

# with open('/content/gdrive/My Drive/segmentation_data','wb') as f:
#   pickle.dump(data,f)
# with open('/content/gdrive/My Drive/segmentation_data','rb') as f:
#   data = pickle.load(f)

# # RFM Calculations

# frequencies = pd.DataFrame({'CustomerID' : data.CustomerID.value_counts().index, 'frequency' : data.CustomerID.value_counts()})
# frequencies['freqqt'] = pd.qcut(frequencies.frequency, q = 5, labels = [0,1,2,3,4])

# values = data[['CustomerID','amount']].groupby('CustomerID').sum().round(2)
# values.reset_index(inplace = True); values.rename(columns = {'amount': 'monetary_value'}, inplace = True)
# values['valueqt'] = pd.qcut(values.monetary_value, q = 5, labels = [0,1,2,3,4])

# recencies = pd.DataFrame({'CustomerID' : data.CustomerID, 'recencies' : max(data.InvoiceDate) - data.InvoiceDate})
# recencies = recencies.groupby('CustomerID').min(); recencies.reset_index(inplace = True); recencies.rename(columns = {'recencies' : 'recency'}, inplace = True)
# recencies['recqt'] = pd.qcut(recencies.recency, q = 5, labels = [0,1,2,3,4])

# avgs = data[['CustomerID','amount']].groupby('CustomerID').mean().round(2)
# avgs.reset_index(inplace = True); avgs.rename(columns = {'amount':'avg_amnt_cust'}, inplace = True)

# fav_categories = data[['CustomerID','product_category']].groupby(['CustomerID', 'product_category']).size().to_frame(name = 'size').reset_index()
# fav_cats = pd.DataFrame(columns = ['CustomerID','fav1','fav2','fav3'])
# for i, customer in enumerate(fav_categories.CustomerID.unique()):
#   fav1,fav2,fav3 = [None]*3
#   xx = fav_categories.loc[fav_categories.CustomerID == customer].nlargest(3,'size').product_category.values
#   if len(xx) ==3: 
#     fav1,fav2,fav3 = xx 
#   elif len(xx) ==2: 
#     fav1,fav2 = xx
#   else:
#     fav1 = xx[0]
#   favorites = [customer,fav1,fav2,fav3]
#   fav_cats = fav_cats.append(pd.Series(favorites, index = ['CustomerID','fav1','fav2','fav3']), ignore_index = True)
#   print(i)

# visits = data[['CustomerID','InvoiceNo']].groupby('CustomerID').size().to_frame(name= 'visits').reset_index()

# avgs2 = data[['InvoiceNo','amount']].groupby('InvoiceNo').sum().round(2).rename(columns = {'amount':'avg_amnt_visit'}).reset_index()
# visitamounts = data[['CustomerID','InvoiceNo']].merge(avgs2, on = 'InvoiceNo', how = 'right').drop_duplicates()
# avg_visit_amnts = visitamounts.groupby('CustomerID').mean().round(2).reset_index()

# basketsize = data[['InvoiceNo','Quantity']].groupby('InvoiceNo').sum().rename(columns = {'Quantity':'basket_size'}).reset_index()
# customerbaskets = data[['CustomerID','InvoiceNo']].merge(basketsize, on = 'InvoiceNo', how = 'right').drop_duplicates()
# avg_bskt_size = customerbaskets[['CustomerID','basket_size']].groupby('CustomerID').mean().astype(int).reset_index()

# Merging All now

# customer_data = frequencies.merge(recencies, on = 'CustomerID',how = 'left').merge(values, on = 'CustomerID',how = 'left').merge(avgs, on = 'CustomerID',how = 'left').merge(avg_bskt_size, on = 'CustomerID',how = 'left').merge(visits, on = 'CustomerID',how = 'left').merge(avg_visit_amnts, on = 'CustomerID', how = 'left').merge(fav_cats, on = 'CustomerID',how = 'left')
# with open('/content/gdrive/My Drive/customerdata', 'wb') as f:
#   pickle.dump(customer_data, f)
# with open('/content/gdrive/My Drive/customerdata','rb') as f:
#   customer_data = pickle.load(f)

# plt.scatter(customer_data.frequency.index,customer_data.frequency)
# plt.scatter(customer_data.monetary_value.index,customer_data.monetary_value)
# plt.scatter(customer_data.recency.index, customer_data.recency.dt.days)
# plt.scatter(customer_data.visits.index, customer_data.visits)
# plt.scatter(customer_data.basket_size.index, customer_data.basket_size)

# customer_data = customer_data.loc[customer_data.frequency < 4000]
# customer_data = customer_data.loc[customer_data.monetary_value >= 0]
# customer_data = customer_data.loc[customer_data.monetary_value < 80000]
# customer_data = customer_data.loc[customer_data.basket_size < 4000]

# kmeans_df = customer_data[['frequency','recency','monetary_value','avg_amnt_cust','basket_size','visits','avg_amnt_visit']]
# kmeans_df = ((kmeans_df-kmeans_df.min())/(kmeans_df.max()-kmeans_df.min()))

# initial_centers = kmeans_plusplus_initializer(kmeans_df, 5).initialize()

# kmeans_instance = kmeans(kmeans_df, initial_centers)
# kmeans_instance.process()

# kmeans_instance.get_clusters()
# kmeans_instance.get_centers()

# kmeans_df.shape

# segment = [None] * customer_data.shape[0]
# segments = [0,1,2,3,4]
# for i, cluster in enumerate(kmeans_instance.get_clusters()):
#   for x in cluster:
#     segment[x] = segments[i]
#   print(i)

# customer_data['segment'] = segment

# colors = [None]*len(customer_data.segment)
# for i in range(0,len(colors)):
#   if list(customer_data.segment == 0)[i] == True: 
#     colors[i] = 'firebrick'
#   elif list(customer_data.segment == 1)[i] == True:
#     colors[i] = 'darkturquoise'
#   elif list(customer_data.segment == 2)[i] == True:
#     colors[i] = 'gold'
#   elif list(customer_data.segment == 3)[i] == True:
#     colors[i] = 'forestgreen'
#   else:
#     colors[i] = 'darkmagenta'

# def scatter_creator(x,y, title, xlabel, ylabel, fig):
#   plt.figure(num = fig, figsize = (7.98,6)) #w/h = 1.33
#   plot = plt.scatter(x, y, s = 70, c = colors, marker = '2')
#   plt.title(title); plt.xlabel(xlabel); plt.ylabel(ylabel)
#   return plot

# scatter_creator(customer_data.frequency, customer_data.monetary_value, 'Scatter','Freq','MV', 1)

# data = pd.merge(data, customer_data[['CustomerID','segment']], on = 'CustomerID', how = 'right')

# def bar_cat_creator(segment_type, category, no_of_values):
#   plot = plt.bar(data.loc[data[segment_type] == category].product_category.value_counts().index[0:no_of_values], data.loc[data[segment_type] == category].product_category.value_counts()[0:no_of_values], color = ['blue','magenta','gold']) 
#   return plot

# customer_data.fav1 = customer_data.fav1.astype('category'); customer_data['fav1cat'] = customer_data.fav1.cat.codes
# customer_data.fav2 = customer_data.fav2.astype('category'); customer_data['fav2cat'] = customer_data.fav2.cat.codes
# customer_data.fav3 = customer_data.fav3.astype('category'); customer_data['fav3cat'] = customer_data.fav3.cat.codes

# kmodes_array = customer_data[['freqqt','recqt','valueqt','fav1cat','fav2cat','fav3cat']].values

# km = KModes(n_clusters = 5, init = 'Huang', n_init = 5, verbose = 1)
# clusters = km.fit_predict(kmodes_array)
# customer_data['mode_segment'] = clusters

# colors = [None]*len(customer_data.mode_segment)
# for i in range(0,len(colors)):
#   if list(customer_data.mode_segment == 0)[i] == True: 
#     colors[i] = 'firebrick'
#   elif list(customer_data.mode_segment == 1)[i] == True:
#     colors[i] = 'darkturquoise'
#   elif list(customer_data.mode_segment == 2)[i] == True:
#     colors[i] = 'gold'
#   elif list(customer_data.mode_segment == 3)[i] == True:
#     colors[i] = 'forestgreen'
#   else:
#     colors[i] = 'darkmagenta'

# scatter_creator(customer_data.frequency, customer_data.monetary_value, 'Scatter','Freq','MV', 1)
# data = pd.merge(data, customer_data[['CustomerID','mode_segment']], on = 'CustomerID', how = 'right')
# bar_cat_creator('segment',3, 5)
