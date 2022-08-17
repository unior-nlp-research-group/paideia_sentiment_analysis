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

#ricarichiamo il nostro file di testo
my_data <- read_excel("../materiali/dataset.xlsx")
my_data <- data.frame(my_data)

sw <- stopwords("it")

testi <- my_data$Text
style <- my_data$Style

#tokenizzazione ed eliminazione stop word
tokens_full <- tokenize_words(testi)

tokens_full <- tokens_full[!tokens_full %in% sw]


my_data$Style[my_data$Style == "positivr"] = "positive"
my_data$Style <- ifelse(is.na(my_data$Style),
                        "not applicable",
                        my_data$Style)



# utilizzo dei lessici per la sentiment
#link nrc
# http://saifmohammad.com/WebPages/AccessResource.htm

#link sentix
# http://valeriobasile.github.io/twita/downloads.html


#importare lessico esterno
nrc_table <- as.data.frame(
  fread('./NRC-VAD-Lexicon-Aug2018Release/OneFilePerLanguage/Italian-it-NRC-VAD-Lexicon.txt'
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
tokens_frase

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
sentiment_values <- unlist(lapply(testi, calcolare_sentiment_nrc))
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


ggplot(sentiment_values_dataframe, aes(x=index, y=sentiment_values))+
  geom_bar(stat='identity', aes(fill=sentiment_values))

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


ggplot(sentiment_values_dataframe, aes(x=index, y=sentiment_values))+
  geom_bar(stat='identity', aes(fill=polarity))+
  scale_fill_manual(name='polarity',
                    labels=c('positivo', 'negativo', 'neutro'),
                    values = c("positivo"="#00ba38",
                               "negativo"="#f8766d",
                               "neutro"="#929292")) + 
  coord_flip()
