#calcolo tf idf
# tf = frequenza di una parola data una classe / occorrenza della parola
# idf = log(num. di documenti / num. di documenti che contengono la parola)

# calcoliamo le idf

frasi_tokenizzate <- tokenize_words(testi)
frasi_tokenizzate <- lapply(frasi_tokenizzate, unique)
token_per_frasi <- unlist(frasi_tokenizzate)

table_tokens <- table(token_per_frasi)
dataframe_df_full <- as.data.frame(table_tokens)

dataframe_df_full['idf'] <- log(
  length(testi)/
    dataframe_df_full['Freq']
) 

dataframe_df_full <- rename(dataframe_df_full, tokens=token_per_frasi) 
head(dataframe_df_full)

# uniamo tf e idf
dataframe_tf_idf <- merge(dataframe_df_full, dataframe_tf_full, by='tokens')

colnames(dataframe_tf_idf)

dataframe_tf_idf['tfidf'] <- dataframe_tf_idf$tf*dataframe_tf_idf$idf

parola <- 'salvini'
dataframe_parola <- dataframe_tf_idf[dataframe_tf_idf['tokens']==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tfidf), stat='identity')

parola <- 'pessimo'
dataframe_parola <- dataframe_tf_idf[dataframe_tf_idf['tokens']==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tfidf), stat='identity')

#visualizzare parole per tfidf data una classe
classe <- 'not applicable'
dataframe_classe <- dataframe_tf_idf[dataframe_tf_idf['classe']==classe,]
dataframe_classe_ordinato <- dataframe_classe[order(-dataframe_classe$tfidf),]
head(dataframe_classe_ordinato, 20)

ggplot(data=head(dataframe_classe_ordinato,10)) +
  geom_bar(mapping=aes(x=reorder(tokens,tfidf) , y=tfidf), stat='identity')

# **se prendiamo in considerazione solo i testi pos e neg, come cambiano i risultati?**
# **ripetiamo l'analisi ma con un'altra colonna**