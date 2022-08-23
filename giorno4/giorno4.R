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



data_annotato$Style[data_annotato$Style == "positivr"] <- "positive"
data_annotato$Style <- ifelse(is.na(data_annotato$Style),
                        "not applicable",
                        data_annotato$Style)

style <- data_annotato$Style

table(style)
# utilizzo dei lessici per la sentiment
#link nrc
# http://saifmohammad.com/WebPages/AccessResource.htm

#link sentix
# http://valeriobasile.github.io/twita/downloads.html

#importare lessico esterno
nrc_table <- as.data.frame(
  fread('./materiali/NRC-VAD-Lexicon-Aug2018Release/OneFilePerLanguage/Italian-it-NRC-VAD-Lexicon.txt'
  )
)

head(nrc_table)

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

# creare split
set.seed(12)
train_index = sample(3792, 3000)

train_sentences <- lemmatized_texts[train_index]
train_corpus <- VCorpus(VectorSource(train_sentences))
test_sentences <- lemmatized_texts[-train_index]
test_corpus <- VCorpus(VectorSource(test_sentences))


train_dtm <- DocumentTermMatrix(train_corpus)
test_dtm <- DocumentTermMatrix(test_corpus)

tm::inspect(test_dtm)

train_labels <- style[train_index]
test_labels <- style[-train_index]

classifier <- naiveBayes(as.matrix(train_dtm), train_labels)

predict(classifier, "Secondo me Salvini rappresenta la sola speranza per questo paese")
predict(classifier, "Secondo me Salvini rappresenterebbe un pessimo premier orrendo")


pos_ids <- data_annotato$id[data_annotato$Style == 'positive']
pos_texts <- VCorpus(VectorSource(lemmatized_texts[pos_ids]))
wordcloud(pos_texts, max.words=50, scale=c(4,0.5))

neg_ids <- data_annotato$id[data_annotato$Style == 'negative']
neg_texts <- VCorpus(VectorSource(lemmatized_texts[neg_ids]))
wordcloud(neg_texts, max.words=50, scale=c(4,0.5))
# **proviamo a creare un classificatore simile ma utilizzando i dati NRC / sentix**
