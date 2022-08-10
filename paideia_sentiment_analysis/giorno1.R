#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(tokenizers)
library(udpipe)
library(stopwords)
library(R.utils)
library(tm)


#scarichiamo un testo di prova
download.file("https://raw.githubusercontent.com/AlessandroGianfelici/italian_reviews_dataset/main/raw_data.txt", "review")
review <- read.csv(file='review')

nrow(review)
colnames(review)

testo <- review$review_text

#tokenizzazione
tokens <- tokenize_words(testo)
tokens <- unlist(tokens)

#tokens <- unlist(tokenize_words(testo))
cat("Numero totale di token:", length(tokens))

parola_di_interesse <- "ottimo"
num_occorrenze <- sum(tokens==parola_di_interesse)
cat("La parola", parola_di_interesse, " compare ", num_occorrenze, " volte nel testo")
# SFIDA: Scriviamo una funzione che trovi il numero di occorrenze data una parola e una lista di token


types <- unique(tokens)
cat("Numero totale di token unici:", length(types))


ttr <- length(tokens) / length(types)


cat("Valore di ttr:", ttr)

freq_parole <- as.data.frame(table(tokens))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]

head(freq_parole_ordinate,10)

sw <- stopwords("it")
head(sw, 10)

tokens_clean <- tokens[!tokens %in% sw]
freq_parole <- as.data.frame(table(tokens_clean))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
head(freq_parole_ordinate,10)
#SFIDA: scriviamo una funzione che, data una lista di token e un numero, restituisce i token che compaiono con frequenza = il numero


testo[1:10]
x <- udpipe(x = testo[1:1000], object='italian')
colnames(x)
