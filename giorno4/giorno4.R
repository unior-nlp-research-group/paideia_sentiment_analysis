#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(ggplot2)
library(tokenizers)
library(wordcloud)
library(RColorBrewer)
library(SnowballC)
library(udpipe)
library(stopwords)
library(R.utils)
library(tm)
library(readxl)
library(RTextTools)
library(e1071)
library(caret)

sw <- stopwords("it")


#ricarichiamo il nostro file annotato sintatticamente
data <- read_csv('./annotazioni-sintattiche.csv')
class(data)
data <- as.data.frame(data)

lemmatized_texts <- c()
for (i in unique(data$doc_id)) {
  tokens <- data[data$doc_id==i,]$lemma
  tokens <- tolower(tokens[!tokens %in% sw])
  #text <- paste(tokens, collapse=' ')
  lemmatized_texts <- c(lemmatized_texts, list(tokens))
}
lemmatized_texts[1]

data_annotato <- read_excel("../materiali/dataset.xlsx")
data_annotato <- data.frame(my_data)


testi <- data_annotato$Text
style <- data_annotato$Style



data_annotato$Style[my_data$Style == "positivr"] = "positive"
data_annotato$Style <- ifelse(is.na(my_data$Style),
                        "not applicable",
                        my_data$Style)



# utilizzo dei lessici per la sentiment
#link nrc
# http://saifmohammad.com/WebPages/AccessResource.htm

#link sentix
# http://valeriobasile.github.io/twita/downloads.html


#importare lessico esterno
nrc_table <- as.data.frame(
  fread('../materiali/NRC-VAD-Lexicon-Aug2018Release/OneFilePerLanguage/Italian-it-NRC-VAD-Lexicon.txt'
  )
)

head(nrc_table)

#controlliamo i valori di alcune parole esemplificative

nrc_table[nrc_table["Italian-it"] == 'abaco',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'perfetto',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'pessimo',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'fiducioso',]$Valence[1]


#calcoliamo il valore per una frase esemplificativa

frase <- c("Sono molto fiducioso per il futuro, anche se mi sento un po' preoccupato a causa degli ultimi avvenimenti")
tokens_frase <- tokenize_words(frase)
tokens_frase <- unlist(tokens_frase)
tokens_frase <- tokens_frase[!tokens_frase %in% sw]

nrc_table[is.element(nrc_table$`Italian-it`, tokens_frase),]

sentiment_values <- nrc_table[is.element(nrc_table$`Italian-it`, tokens_frase),]$Valence
sentiment_values


#**scriviamo una funzione per calcolare il valore di valenza data una frase**

calcolare_sentiment_nrc <- function(frase_input){
  tokens <- unlist(tokenize_words(frase_input))
  tokens_clean <- tokens[!tokens %in% sw]
  sentiment_values <- nrc_table[is.element(nrc_table$`Italian-it`, tokens_clean),]$Valence
  return(mean(sentiment_values))
}
sentiment_values <- unlist(lapply(lemmatized_texts, calcolare_sentiment_nrc))

sentiment_values

sentiment_values[is.na(sentiment_values)] <- 0

sentiment_values_dataframe <- data.frame(
  testi, sentiment_values
)
head(sentiment_values_dataframe)
sentiment_values_dataframe  <- sentiment_values_dataframe[
  order(-sentiment_values_dataframe$sentiment_values)
  ,]

sentiment_values_dataframe$index <- seq(
  from=1,
  to=nrow(sentiment_values_dataframe),
  by=1)
colnames(sentiment_values_dataframe)
head(sentiment_values_dataframe)



# impostiamo dei limiti:
# negativo = minore di 0.5
# neutro = compreso tra 0.5 e 0.7
# positivo = maggiore di 0.7

sentiment_values_dataframe$polarity <- ifelse(
  sentiment_values_dataframe$sentiment_values >= 0.7,
  "positivo",
  ifelse(sentiment_values_dataframe$sentiment_values <= 0.5,
         "negativo",
         "neutro")
)
table(sentiment_values_dataframe$polarity)
table(style)


# addestramento di un classificatore naive bayes

neg_texts <- unlist(lemmatized_texts[data_annotato$Style=='negative'])
pos_texts <- unlist(lemmatized_texts[data_annotato$Style=='positive'])
pos_texts <- pos_texts[!is.na(pos_texts)]
neg_texts <- neg_texts[!is.na(neg_texts)]

# la funzione successiva serve a calcolare le probabilità di una sequenza di token

calc_probs <- function(tokens){
  counts <- table(tokens) + 1
  counts/sum(counts)
}

pos_probs <- calc_probs(unlist(pos_texts))
neg_probs <- calc_probs(unlist(neg_texts))

calc_probs_rare <- function(tokens){
  tokens <- unlist(tokens)
  counts <- table(tokens) + 1
  return(log(1/sum(counts)))
}
pos_probs_rare <- calc_probs_rare(pos_texts)
neg_probs_rare <- calc_probs_rare(neg_texts)

calc_sentiment <- function(frase){
  test <- unlist(tokenize_words(frase))
  pos_pred <- sum(
    is.na(pos_probs[test]))*pos_probs_rare+sum(pos_probs[test], na.rm=TRUE)
  neg_pred <- sum(
    is.na(neg_probs[test]))*neg_probs_rare+sum(neg_probs[test], na.rm=TRUE)
  cat("prob. pos.", pos_pred, '\n')
  cat("prob. neg.", neg_pred, '\n')
}
calc_sentiment("salvini")
