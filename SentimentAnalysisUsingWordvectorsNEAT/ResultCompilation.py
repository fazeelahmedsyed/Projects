#Importing Packages and mounting google drive

import re
from google.colab import drive
drive.mount('/content/gdrive')
import plotly.plotly as py
import plotly.graph_objs as go
py.sign_in('xxxxxxxxxxx', 'xxxxxxxxxxxx') #Sign in for plotly

#Creating Scrapers

avg_fitness = re.compile('(?<=average fitness: )\d*\.\d*')
avg_fitness_std = re.compile('(?<=stdev: )\d*\.\d*')
best_fitness = re.compile('(?<=Best fitness: )\d*\.\d*')
best_fitness_size = re.compile('(?<=size: \()\d')
mean_gene_dis = re.compile('(?<=Mean genetic distance )\d*\.\d*')
mean_gene_std = re.compile('(?<=standard deviation )\d*\.\d*')
generation_species = re.compile('(?<=Population of \d{3} members in )\d')
generation_time = re.compile('(?<=Generation time: )\d*\.\d*')
table_first = re.compile('====[\r\n](.*)')
table_sec = re.compile('====[\r\n].*[\r\n](.*)')
table = re.compile('Running generation (\d*).*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n(.*)\n(.*)\n(.*)\n(.*)')
generation_no = re.compile('(?<=Running generation )\d*')

#Creating function for variable creation

def variables_creator(generations_file):
  avg_fitness_ch = avg_fitness.findall(generations_file)
  avg_fitness_std_ch = avg_fitness_std.findall(generations_file)
  worst_fitness_fl = [float(xa) - float(xs) for xa,xs in zip(avg_fitness_ch, avg_fitness_std_ch)]
  best_fitness_fl = [float(xa) + float(xs) for xa,xs in zip(avg_fitness_ch, avg_fitness_std_ch)]
  avg_fitness_fl = [float(x) for x in avg_fitness_ch]
  
  gen_time_ch = generation_time.findall(generations_file)
  gen_time_fl = [float(x) for x in gen_time_ch]

  mean_genedis_ch = mean_gene_dis.findall(generations_file)
  mean_genedis_fl = [float(x) for x in mean_genedis_ch]
  
  return worst_fitness_fl, best_fitness_fl, avg_fitness_fl, gen_time_fl, mean_genedis_fl

#Creating function for reading generation files

def opener(name):
  path = '/content/gdrive/My Drive/Thesis/{}.txt'.format(name)
  with open(path,'r') as f:
    bazooka = f.read()
  return bazooka

#Loading generation files
##generation files were created by saving the output of the reporters of each classifier while the iterations were run

generations_vn = opener('generations_vn')
generations_n = opener('generations_n')
generations_neu = opener('generations_neu')
generations_p = opener('generations_p')
generations_vp = opener('generations_vp')

#Making variables for graphs

wrst_vn, best_vn, avg_vn, gt_vn, genedis_vn = variables_creator(generations_vn)
wrst_n, best_n, avg_n, gt_n, genedis_n = variables_creator(generations_n)
wrst_neu, best_neu, avg_neu, gt_neu, genedis_neu = variables_creator(generations_neu)
wrst_p, best_p, avg_p, gt_p, genedis_p = variables_creator(generations_p)
wrst_vp, best_vp, avg_vp, gt_vp, genedis_vp = variables_creator(generations_vp)

##Graphs

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = avg_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = avg_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = avg_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = avg_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = avg_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Average Fitness Movement',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Average Fitness'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='avg_fitness')

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = best_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = best_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = best_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = best_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = best_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Best Fitness Movement',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Best Fitness'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='best_fitness')

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = gt_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = gt_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = gt_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = gt_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = gt_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Generation Time Performance',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Time in Seconds'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='gen_time')

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = genedis_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = genedis_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = genedis_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = genedis_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = genedis_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Mean Genetic Distance of species',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Genetic Distance'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='genedis')


### BETTER FEATURE MODEL ###

##Loading generation files

generations_vn = opener('lexigens_vn')
generations_n = opener('lexigens_n')
generations_neu = opener('lexigens_neu')
generations_p = opener('lexigens_p')
generations_vp = opener('lexigens_vp')

##Creating variables for graphs

wrst_vn, best_vn, avg_vn, gt_vn, genedis_vn = variables_creator(generations_vn)
wrst_n, best_n, avg_n, gt_n, genedis_n = variables_creator(generations_n)
wrst_neu, best_neu, avg_neu, gt_neu, genedis_neu = variables_creator(generations_neu)
wrst_p, best_p, avg_p, gt_p, genedis_p = variables_creator(generations_p)
wrst_vp, best_vp, avg_vp, gt_vp, genedis_vp = variables_creator(generations_vp)

##Graphs

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = best_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = best_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = best_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = best_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = best_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Best Fitness Movement (Better features)',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Best Fitness'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='best_fitness')

# generations = [i for i in range(1,51)] 
# trace0 = go.Scatter(x = generations,y = genedis_vn,mode = 'lines+markers',name = 'Very Negative')
# trace1 = go.Scatter(x = generations,y = genedis_n,  mode = 'lines+markers',name = 'Negative')
# trace2 = go.Scatter(x = generations,y = genedis_neu,mode = 'lines+markers',name = 'Neutral')
# trace3 = go.Scatter(x = generations,y = genedis_p,mode = 'lines+markers',name = 'Positive')
# trace4 = go.Scatter(x = generations,y = genedis_vp,mode = 'lines+markers',name = 'Very Positive')
# data = [trace0,trace1,trace2,trace3,trace4]
# layout = dict(title = 'Mean Genetic Distance of species',xaxis = dict(title = 'Generation'),yaxis = dict(title = 'Genetic Distance'))
# fig = dict(data = data, layout = layout)
# py.iplot(fig, filename='genedis')
