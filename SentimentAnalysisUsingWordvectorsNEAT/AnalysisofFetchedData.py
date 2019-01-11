
##########################################################################################################
#######################################        ANALYSIS      #############################################
##########################################################################################################

# path = os.path.abspath('stanfordSentimentTreebank')
# phrases = get_phrase_sentiments(path)
# phrases2 = phrases.copy().set_index('phrase')
# sentences = get_sentence_partitions(path)
# sentences.set_index('sentence', inplace = True)
# data = sentences.join(phrases2)
# data = data.reset_index().rename(columns = {'index':'sentence'})

# # Checking Nulls
# # data.loc[data['fine'].isnull()].shape #we dont have labels for 569
# # data.loc[data['fine'].isnull()] 
# # Alot of Nulls exist due to the presence of the symbols -LRB- and -RRB-. They stand for ( and ) respectively. This can be confirmed using the check below.
# # data.loc[data['sentence'].str.contains('charming and hilarious')]
# # phrases.loc[phrases['phrase'].str.contains('charming and hilarious')]

# # # Assessing -LRB- and -RRB-
# a = data.loc[data.sentence.str.contains('-LRB-|-RRB-')].copy() 
# # a.shape #LRB and RRB applies to 479 so can be eliminated for them
# b = data.loc[data.fine.isnull() & ~data.sentence.str.contains('-LRB-|-RRB-')].copy()
# # b.shape #total 97 have other problems
# # How do 97 appear that have no sentiment and do not contain LRB|RRB when 479 out of 569 with missing sentiment contain LRB or RRB? there is an imbalance of 7
# # b.loc[b.sentence.isin(a.sentence)] #they dont have common elements. This can be ruled out 
# # data.loc[data.fine.notnull() & data.sentence.str.contains('-LRB-|-RRB-')] #7 instances that have LRB and RRB but also have sentiments.
# # phrases[phrases.phrase.str.contains('-LRB-|-RRB-')] # so some phrases with LRB and RRB have sentiments from the start. -LRB- and -RRB- could be removed from phrases.

# c = data.loc[data['fine'].isnull() & data['sentence'].str.contains('-LRB-|-RRB-')].copy()
# # c.sentence = c.sentence.str.replace('-LRB-','(').str.replace('-RRB-',')')
# #c
# # phrases.phrase.str.contains("does n't so much phone") #there is a space after the bracket everywhere in phrases. so we only have to replace as above. no issues

# # # Assessing other problems 
# b.reset_index(inplace = True)
# b.columns = ['sentence','splitset_label','id','sentiment','fine','coarse'] 
# # b
# # problem seems the use of special characters.
# # phrases[phrases['phrase'].str.contains('An overstylized')]
# # phrases[phrases['phrase'].str.contains('affecting and uniquely')] #Different kinds of special characters exist.
# b.loc[:,'sentence'] = b.loc[:,'sentence'].apply(lambda x: x.encode('latin').decode('utf-8')) #solves the problem
# # b

# # # Trying Methods
# phrases = get_phrase_sentiments(path).set_index('phrase')
# sentences = get_sentence_partitions(path).set_index('sentence')

# excess = sentences.join(phrases).reset_index().rename(columns = {'index':'sentence'}).loc[lambda x: x['fine'].notnull() & x['sentence'].str.contains('-LRB-|-RRB-')]

# phrases2 = phrases.reset_index().rename(columns = {'index':'phrase'})
# phrases2.phrase = phrases2.phrase.str.replace('-LRB-','(').str.replace('-RRB-',')')
# sentences = sentences.reset_index().rename(columns = {'index':'sentence'})
# sentences.sentence = sentences.sentence.apply(lambda x: x.encode('latin').decode('utf-8')).str.replace('-LRB-','(').str.replace('-RRB-',')')
# sentences.set_index('sentence', inplace= True)
# phrases2.set_index('phrase', inplace = True)
# data = sentences.join(phrases2)
# data = data.reset_index().rename(columns = {'index':'sentence'})

# pro_excess = excess.copy()
# pro_excess.sentence = pro_excess.sentence.str.replace('-LRB-','(').str.replace('-RRB-',')')

# data.loc[df.sentence.isin(pro_excess.sentence)] #as expected they are duplicated with separate sentiments, but why
# ph = get_phrase_sentiments(path)
# ph.loc[ph.phrase.isin(excess.sentence)].append(ph.loc[ph.phrase.isin(pro_excess.sentence)])
# # phrases has both -LRB-/-RRb- form and the bracket form. 
# # We are picking only the bracket form then as of the 7 under consideration only 1 has a different sentiment class.
# # Such minor bias wont make alot of difference.
# # we will avoid the replacing process for phrases in implementational terms