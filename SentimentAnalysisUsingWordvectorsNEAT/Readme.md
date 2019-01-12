# Sentiment Analysis of Online Reviews using Neuroevolution of Augmenting Topologies

This repository contains code for the thesis submitted at **University of Management Technology, Lahore** under the said title by **Syed Fazeel Ahmed** in January, 2019 as partial requirement for completion of Masters degree in Business Analytics.

The thesis was concerned with proposing a new framework for predicting sentiment polarity using a reinforcement learning algorithm called *NeuroEvolution of Augmenting Topologies* (NEAT) and representing text using semantic word vectors.

A brief description of the files present in this repository is given below:

* ***Files***: Python code for fetching the dataset and saving it into useful files,
* ***AnalysisofFetchedData***: A rough python code that analyzes the data received in the dataset and the intial processing needed,
* ***InputVectors***: Python code for creating inputs used in the analysis,
* ***ConfigurationforNEAT***: Python code for creating the configurations file for running NEAT in python,
* ***NEATClassifiers***: Python code for creating NEAT classifiers for each class and saving them,
* ***TestSet***: Python code for creating the test inputs required for test accuracy measurement,
* ***TestAccuracy***: Python code that provides the test accuracy for the NEAT ensemble,
* Files named as ***BetterFeatures***: Python code files that serve the corresponding purpose as stated above but for features defined using additional steps (using lexicons),
* ***ResultCompilation***: Python code that creates the graphs used in the thesis on plotly,
* Files named as ***generations***: Output of running NEAT classifiers saved as text files,
* Files named as ***lexigens***: Output of running NEAT classifiers with better features saved as text files.

The purpose of this repository is to make code available for assessment and recommendation. Packages used in the files are properly cited in the final copy of the thesis (where required).
