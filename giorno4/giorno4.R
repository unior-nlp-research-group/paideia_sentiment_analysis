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
library(data.table)
library(tm)
library(readxl)
library(RTextTools)
library(e1071)
library(caret)

sw <- stopwords("it")


#ricarichiamo il nostro file annotato sintatticamente
data <- read.csv("./materiali/annotazioni-sintattiche.csv")
class(data)
colnames(data)
#data <- as.data.frame(data)

dataset <- read_excel("materiali/dataset.xlsx")
data_annotato <- data.frame(dataset)

head(data)

data$doc_id

doc_ids <- unique(data$doc_id)

token_from_lemmas <- function(id){
  tokens <- data[data$doc_id==id,]$lemma
  tokens <- unlist(tolower(tokens[!tokens %in% sw]))
  return(paste(tokens))
}
testi_lemmatizzati <- lapply(doc_ids, token_from_lemmas)
testi_lemmatizzati[2]

length(testi_lemmatizzati)

data_annotato$Style[data_annotato$Style == "positivr"] <- "positive"
data_annotato$Style[data_annotato$Style == "emphasising candidate's values"] <- "not applicable"

data_annotato$Style <- ifelse(is.na(data_annotato$Style),
                        "not applicable",
                        data_annotato$Style)
style <- data_annotato$Style

data_annotato$id <- seq(from=1, to=nrow(data_annotato), by=1)

table(style)

# utilizzo dei lessici per la sentiment
#link nrc
# http://saifmohammad.com/WebPages/AccessResource.htm

#link sentix
# http://valeriobasile.github.io/twita/downloads.html

#importare lessico esterno
lessico <- as.data.frame(
  fread('./materiali/sentix'
  )
)

head(lessico)

#**andiamo a vedere i valori di una parola esemplificativa**

parola <- "non"
mean(lessico[lessico$V1 == parola,]$V4)

#calcoliamo il valore per una frase

frase <- c("Sono molto fiducioso per il futuro, anche se mi sento un po' preoccupato a causa degli ultimi avvenimenti")
tokens_frase <- tokenize_words(frase)
tokens_frase <- unlist(tokens_frase)
tokens_frase <- tokens_frase[!tokens_frase %in% sw]

polarity <- lessico[is.element(lessico$V1, tokens_frase),]$V4
tokens_interest <- lessico[is.element(lessico$V1, tokens_frase),]$V1

df <- data.frame(
  polarity,
  "tokens" = tokens_interest
)
head(df)
ggplot(df)+
  geom_bar(aes(x=tokens, y = polarity), stat="summary", fun="mean")


sentiment_values <- lessico[is.element(lessico$V1, tokens_frase),]$V4
sentiment_values
round(mean(sentiment_values),3)

#**scriviamo una funzione per calcolare il valore di valenza data una frase**

calcolare_sentiment <- function(frase_input){
  tokens <- unlist(tokenize_words(frase_input))
  tokens_clean <- tokens[!tokens %in% sw]
  sentiment_values <- lessico[is.element(lessico$V1, tokens_clean),]$V4
  return(mean(sentiment_values))
}
sentiment_values <- unlist(
  lapply(
    testi_lemmatizzati, calcolare_sentiment))


hist(sentiment_values)
#quanti NA ci sono?

sentiment_values[is.na(sentiment_values)] <- 0
density(sentiment_values)



testi <- data_annotato$Text
sentiment_values_dataframe <- data.frame(
  testi, sentiment_values
)
head(sentiment_values_dataframe)
sentiment_values_dataframe  <- sentiment_values_dataframe[
  order(-sentiment_values_dataframe$sentiment_values)
  ,]
head(sentiment_values_dataframe)


sentiment_values_dataframe$index <- seq(
  from=1,
  to=nrow(sentiment_values_dataframe),
  by=1)
colnames(sentiment_values_dataframe)
head(sentiment_values_dataframe)


# impostiamo dei limiti (threshold):
# negativo  <0.2
# neutro  >=0.4
# positivo  > 0.4

sentiment_values_dataframe$polarity <- ifelse(
  sentiment_values_dataframe$sentiment_values > 0.4,
  "positivo",
  ifelse(sentiment_values_dataframe$sentiment_values < 0.2,
         "negativo",
         "neutro")
)
head(sentiment_values_dataframe$polarity)

table(sentiment_values_dataframe$polarity)



table(style)


# addestramento di un classificatore naive bayes

# creare split
set.seed(12)
#creazione di un indice per il training
train_index <- sample(nrow(sentiment_values_dataframe), 3000)
train_index
test_index <- sentiment_values_dataframe$index[
  !sentiment_values_dataframe$index %in% train_index]
length(test_index)

#creazione di una dtm
corpus <- VCorpus(VectorSource(paste(testi_lemmatizzati)))
dtm <- DocumentTermMatrix(corpus)

dtm$dimnames$Docs

dtm_train <- dtm[dtm$dimnames$Docs %in% train_index,]
dtm_test <- dtm[dtm$dimnames$Docs %in% test_index,]
dtm_train

train_labels <- style[train_index]
test_labels <- style[-train_index]

table(train_labels)
library(e1071)
classifier <- naiveBayes(
  as.matrix(dtm_train),
  train_labels)

pred <- predict(classifier, as.matrix(dtm_test))
confusionMatrix(pred, as.factor(test_labels))

dtm_train <- removeSparseTerms(dtm_train, 0.5)
dtm_test <- removeSparseTerms(dtm_test, 0.5)

classifier <- naiveBayes(
  as.matrix(dtm_train),
  train_labels)
pred <- predict(classifier, as.matrix(dtm_test))
confusionMatrix(pred, as.factor(test_labels))

pos_ids <- data_annotato$id[data_annotato$Style == 'positive']
pos_texts <- VCorpus(VectorSource(testi_lemmatizzati[pos_ids]))
package.install(wordcloud)
wordcloud(pos_texts, max.words=50, scale=c(4,0.5))

neg_ids <- data_annotato$id[data_annotato$Style == 'negative']
neg_texts <- VCorpus(VectorSource(testi_lemmatizzati[neg_ids]))
wordcloud(neg_texts, max.words=50, scale=c(4,0.5))


