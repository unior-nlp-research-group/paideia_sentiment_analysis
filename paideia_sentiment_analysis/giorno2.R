#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(ggplot2)
library(tokenizers)
library(stopwords)
library(tidytext)
library(tm)
library(readxl)


#ricarichiamo il nostro file di testo
my_data <- read_excel("../materiali/dataset.xlsx")
my_data <- data.frame(my_data)
my_data$Style[my_data$Style == "positivr"] = "positive"

sw <- stopwords("it")

testi <- my_data$Text

#tokenizzazione
tokens_full <- tokenize_words(testi)
tokens_full <- unlist(tokens_full)

tokens_full <- tokens_full[!tokens_full %in% sw]
class(tokens_full)

# recuperiamo testi a partire da valutazioni specifiche

# quali valutazioni sono presenti nel dataset?
table(my_data$Style)

my_data$Style <- ifelse(is.na(my_data$Style),
                        "not applicable",
                        my_data$Style)


# raccogliamo i testi per le valutazioni = positive
testi_positive <- my_data[my_data$Style=="positive",]$Text
head(testi_positive,10)

tokens_positive <- unlist(tokenize_words(testi_positive))
class(tokens_positive)
tokens_positive <- tokens_positive[!tokens_positive %in% sw]

head(as.data.frame(table(tokens_positive)))

#creiamo un dataframe che per ogni coppia parola-classe ci mostra la frequenza

total_tokens <- length(tokens_full)
total_tokens

as.data.frame(table(tokens_full))
as.data.frame(table(factor(tokens_full, levels=unique(tokens_full))))

count_total_tokens <- as.data.frame(table(tokens_full))
plot(count_total_tokens$Freq[count_total_tokens$Freq <= 500])

count_total_tokens

get_frequencies <- function(polarity){
  testi_classe <- my_data[my_data$Style==polarity,]$Text
  tokens_classe <- unlist(tokenize_words(testi_classe))
  tokens_classe <- tokens_classe[!tokens_classe %in% sw] 
  
  dataframe_tf <- as.data.frame(
    table(
      #factor ci serve ad avere anche i token che compaiono con occorrenza = 0 in una data classe
      factor(
        tokens_classe, levels = unique(tokens_full)
       )
     #tokens_classe
       )
  )
  dataframe_tf['tf'] <- dataframe_tf$Freq/length(tokens_classe)
  dataframe_tf['classe'] <- c(polarity)
  dataframe_tf <- rename(dataframe_tf, 'tokens'=Var1)

  return(dataframe_tf)
}

dataframe_tf_pos <- get_frequencies("positive")
dataframe_tf_neg <- get_frequencies("negative")
dataframe_tf_na <- get_frequencies("not applicable")

dataframe_tf_full <- bind_rows(
  dataframe_tf_pos,
  dataframe_tf_neg,
  dataframe_tf_na,
 .id = "column_label")

head(dataframe_tf_full)

#visualizzare la frequenza di una parola rispetto alle classi

parola <- 'salvini'
dataframe_parola <- dataframe_tf_full[dataframe_tf_full$tokens==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tf), stat='identity')

# visualizzare parole per frequenza data una classe
classe_specifica <- 'positive'
dataframe_classe <- dataframe_tf_full[dataframe_tf_full$classe==classe_specifica,]
dataframe_classe
colnames(dataframe_classe)
nrow(dataframe_classe)

dataframe_classe_ordinato <- head(dataframe_classe[order(-dataframe_classe$tf),],10)
dataframe_classe_ordinato

ggplot(data=dataframe_classe_ordinato) +
  geom_bar(mapping=aes(x=reorder(tokens,-Freq) , y=Freq), stat='identity')

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