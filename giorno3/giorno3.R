#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(ggplot2)
library(tokenizers)
library(stopwords)
library(tidytext)
library(udpipe)
library(tm)
library(irr)
library(readxl)
library(data.table)


#ricarichiamo il nostro dataset
my_data <- read.csv("~/Progetti/paideia_sentiment_analysis/materiali/Reviews_Dooge_X10.csv",
                    header=FALSE)
my_data <- data.frame(my_data)

colnames(my_data)
head(my_data$V3)


tokens <- tokenize_words(my_data$V3)
tokens <- unlist(tokens)

tokens_df <- data.frame(table(tokens))
head(tokens_df)

sw <- stopwords("it")
sw


tokens_full <- tokens[!tokens %in% sw]
tokens_df <- data.frame(table(tokens))

head(tokens_df[order(-tokens_df$Freq),],10)

## 1. dividiamo il dataset per rating
colnames(my_data)
head(my_data$V1)

table(my_data$V1)


getFreq <- function(rating){
  recensioni <- my_data$V3[my_data$V1 == rating]
  tokens <- unlist(tokenize_words(recensioni))
  tokens <- factor(tokens, levels = unique(tokens_full))
  table_tokens <- table(tokens)
  df <- data.frame(table_tokens)
  df <- df[order(-df$Freq),]
  return(df)
}
ratings <- seq(1:5)
freqs <-lapply(ratings, getFreq)

total_freqs <- rbindlist(freqs, use.names = TRUE, idcol="rating")
total_freqs[total_freqs$tokens == 'ottimo' & total_freqs$rating == 5]

find_occ <- function(parola){
  if (parola %in% tokens_full){
  occ <- total_freqs[
    total_freqs$tokens == parola]$Freq
  return(occ)
  }
  else
  {
    return(c(0,0,0,0,0))
  }
}

lista_parole <- c("bellissimo", "brutto", "batteria")
x <- lapply(lista_parole, find_occ)
x
df3 <- data.frame("rating" = seq(1:5), "values" = x[[3]])
ggplot(df3) + 
  geom_bar(aes(x=rating, y=values), stat ="identity")

total_freqs[total_freqs$tokens == "brutto"]


freq_1 <- freq_1[!freq_1$tokens_1 %in% sw,]
freq_3 <- freq_3[!freq_3$tokens_3 %in% sw,]

freq_3
head(freq_3)

#tokenizzazione
tokens_full <- data_annotati$token

# ottenere la frequenza dei token
table(tokens_full)

freq_parole <- as.data.frame(table(tokens_full))

# esaminare una parola di interesse
parola_di_interesse <- "politiche"

num_occorrenze <- freq_parole[freq_parole$tokens_full == parola_di_interesse,]
num_occorrenze$Freq

# ordiniamo le parole per numero di occorrenze
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
# guardiamo le parole più frequenti
head(freq_parole_ordinate,10)

#pulizia del testo

#stopword
sw <- stopwords("it")
head(sw, 10)

tokens_clean <- tokens[!tokens_full %in% sw]

freq_parole <- as.data.frame(table(tokens_clean))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
head(freq_parole_ordinate,10)


lemmi <- annotation$lemma[!annotation$lemma %in% sw]
freq_lemmi <- as.data.frame(table(lemmi))
freq_lemmi_ordinati <- freq_lemmi[order(-freq_lemmi$Freq),]

head(freq_lemmi_ordinati,10)

freq_lemmi_clean <- freq_lemmi_ordinati[!freq_lemmi_ordinati$lemmi %in% sw,]
head(freq_lemmi_clean,100)

#importare lessico esterno
nrc_table <- as.data.frame(
  fread('./materiali/NRC-VAD-Lexicon-Aug2018Release/OneFilePerLanguage/Italian-it-NRC-VAD-Lexicon.txt'
  )
)

head(nrc_table)

#controlliamo i valori di alcune parole esemplificative

nrc_table[nrc_table["Italian-it"] == 'abaco',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'perfetto',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'pessimo',]$Valence[1]
nrc_table[nrc_table["Italian-it"] == 'fiducioso',]$Valence[1]

# **guardare anche l'altro dataset NRC**
# **creiamo un vettore che affibbia un valore a ogni lemma presente nel dataset annotato**

