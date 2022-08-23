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
my_data <- read_excel("./materiali/dataset.xlsx")
my_data <- data.frame(my_data)

testi <- my_data$Text

# carichiamo il nostro file annotato sintatticamente
data_annotati <- read_csv("path/to/file")


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

# **scriviamo una funzione che trovi il numero di occorrenze data una parola e una lista di token**


# creazione di un progetto di annotazione
# nlpgroup.unior.it


# importare i dati annotati

df <- read.csv('path/to/csv')

# analisi IAA

kappam.fleiss(df[,c("rater1", "rater2",...)])

# **proposta di progetto**
