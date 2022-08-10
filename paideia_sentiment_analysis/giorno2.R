#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(ggplot2)
library(tokenizers)
library(stopwords)
library(tidytext)
library(tm)

#ricarichiamo il nostro file di testo
review <- read.csv(file='review')
testi_full <- review$review_text
sw <- stopwords("it")

tokens_full <- tokenize_words(testi_full)
tokens_full <- unlist(tokens)
tokens_full <- tokens_full[!tokens_full %in% sw]
class(tokens_full)
colnames(review)
# recuperiamo testi a partire da valutazioni specifiche

# come vengono valutati i prodotti?
head(review$review_stars)

# raccogliamo i testi per le valutazioni = 5
testi_5stelle <- review[review$review_stars==5,]$review_text
head(testi_5stelle,10)

tokens_5stelle <- unlist(tokenize_words(testi_5stelle))
head(as.data.frame(table(tokens_5stelle)))

#creiamo un dataframe che per ogni coppia parola-classe ci mostra la frequenza

total_tokens <- length(tokens_full)
count_total_tokens <- as.data.frame(table(tokens_full))
count_total_tokens <- count_total_tokens[count_total_tokens$Freq >= 100,]
tokens_to_keep <- count_total_tokens$tokens_full

get_frequencies <- function(stars){
  testi_classe <- review[review$review_stars==stars,]$review_text
  tokens_classe <- unlist(tokenize_words(testi_classe))
  
  dataframe_tf <- as.data.frame(
    table(
      factor(
        tokens_classe, levels = unique(tokens_full)
        )
      )
  )
  dataframe_tf['tf'] <- dataframe_tf$Freq/length(tokens_classe)
  dataframe_tf['classe'] <- c(stars)
  dataframe_tf <- rename(dataframe_tf, 'tokens'=Var1)
  dataframe_tf <- dataframe_tf[dataframe_tf$tokens %in% tokens_to_keep,]
  
  
  return(dataframe_tf)
}


dataframe_tf_1 <- get_frequencies(1)
dataframe_tf_2 <- get_frequencies(2)
dataframe_tf_3 <- get_frequencies(3)
dataframe_tf_4 <- get_frequencies(4)
dataframe_tf_5 <- get_frequencies(5)


dataframe_tf_full <- bind_rows(
  dataframe_tf_1,
  dataframe_tf_2,
  dataframe_tf_3,
  dataframe_tf_4,
  dataframe_tf_5, .id = "column_label")

colnames(dataframe_tf_full)

#visualizzare la frequenza di una parola rispetto alle classi

parola <- 'pessimo'
dataframe_parola <- dataframe_tf_full[dataframe_tf_full$tokens==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=Freq), stat='identity')

# visualizzare parole per frequenza data una classe
classe_specifica <- 1
dataframe_classe <- dataframe_tf_full[dataframe_tf_full$classe==classe_specifica,]
colnames(dataframe_classe)
nrow(dataframe_classe)

dataframe_classe_ordinato <- head(dataframe_classe[order(-dataframe_classe$Freq),],20)
dataframe_classe_ordinato

ggplot(data=dataframe_classe_ordinato) +
  geom_bar(mapping=aes(x=reorder(tokens,-Freq) , y=Freq), stat='identity')

#calcolo tf idf
# tf = frequenza di una parola data una classe / occorrenza della parola
# idf = log(num. di documenti / num. di documenti che contengono la parola)

# calcoliamo le idf
table_tokens <- table(tokens_full)
dataframe_df_full <- as.data.frame(table_tokens)

dataframe_df_full['idf'] <- log(
  length(testi_full)/
    dataframe_df_full['Freq']
) 
dataframe_df_full <- dataframe_df_full[dataframe_df_full$Freq >= 100,]
dataframe_df_full <- rename(dataframe_df_full, tokens=tokens_full) 
head(dataframe_df_full)

# uniamo tf e idf
dataframe_tf_idf <- merge(dataframe_df_full, dataframe_tf_full, by='tokens')

colnames(dataframe_tf_idf)

dataframe_tf_idf['tfidf'] <- dataframe_tf_idf$tf*dataframe_tf_idf$idf

parola <- 'ottimo'
dataframe_parola <- dataframe_tf_idf[dataframe_tf_idf['tokens']==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tfidf), stat='identity')

parola <- 'pessimo'
dataframe_parola <- dataframe_tf_idf[dataframe_tf_idf['tokens']==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tfidf), stat='identity')

#visualizzare parole per frequenza data una classe
classe <- 5
dataframe_classe <- dataframe_tf_idf[dataframe_tf_idf['classe']==classe,]
dataframe_classe_ordinato <- dataframe_classe[order(-dataframe_classe$tfidf),]
head(dataframe_classe_ordinato, 20)

ggplot(data=head(dataframe_classe_ordinato,10)) +
  geom_bar(mapping=aes(x=reorder(tokens,tfidf) , y=tfidf), stat='identity')

classe <- 1
dataframe_classe <- dataframe_tf_idf[dataframe_tf_idf['classe']==classe,]
dataframe_classe_ordinato <- dataframe_classe[order(-dataframe_classe$tfidf),]
head(dataframe_classe_ordinato, 20)

ggplot(data=head(dataframe_classe_ordinato,10)) +
  geom_bar(mapping=aes(x=reorder(tokens,tfidf) , y=tfidf), stat='identity')

