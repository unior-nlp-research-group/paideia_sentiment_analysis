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

testi <- my_data$Text

#tokenizzazione
tokens_full <- tokenize_words(testi)
tokens_full <- unlist(tokens_full)

class(tokens_full)

# ottenere la frequenza dei token
freq_parole <- as.data.frame(table(tokens_full))

# esaminare una parola di interesse
parola_di_interesse <- "di"
tokens==parola_di_interesse
num_occorrenze <- freq_parole[freq_parole$tokens_full == parola_di_interesse,]

num_occorrenze$Freq

# ordiniamo le parole per numero di occorrenze
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
# guardiamo le parole più frequenti
head(freq_parole_ordinate,10)

#pulizia del testo

#testo in minuscolo
test <- my_data$Text[12]
print(test)
print(tolower(test))

#stopword
sw <- stopwords("it")
head(sw, 10)

tokens_clean <- tokens[!tokens_full %in% sw]

freq_parole <- as.data.frame(table(tokens_clean))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
head(freq_parole_ordinate,10)

# **aggiungiamo punteggiatura e altre stop word per ottenere risultati migliori**


#lemmatizzazione

ud_model <- udpipe_download_model(language = "italian", overwrite = F)
ud_it <- udpipe_load_model(ud_model)


# scriviamo una funzione per lemmatizzare
#prima inseriamo una colonna per identificare gli id dei testi nel dataframe
my_data$id <- seq(1:nrow(my_data))

#scriviamo la funzione
annotate_splits <- function(x, file) {
  ud_model <- udpipe_load_model(file)
  x <- as.data.table(udpipe_annotate(ud_model, 
                                     x = tolower(x$Text),
                                     doc_id = x$id))
  return(x)
}

# load parallel library future.apply
library(future.apply)

# Define cores to be used
ncores <- 4L
plan(multisession, workers = ncores)

# split comments based on available cores
corpus_splitted <- split(my_data, seq(1, nrow(my_data), by = 500))

annotation <- future_lapply(corpus_splitted, annotate_splits, file = ud_model$file_model)
annotation <- rbind(annotation)
head(annotation)

lemmi <- annotation$lemma[!annotation$lemma %in% sw]
freq_lemmi <- as.data.frame(table(lemmi))
freq_lemmi_ordinati <- freq_lemmi[order(-freq_lemmi$Freq),]

head(freq_lemmi_ordinati,10)

freq_lemmi_clean <- freq_lemmi_ordinati[!freq_lemmi_ordinati$lemmi %in% sw,]
head(freq_lemmi_clean,100)

# **scriviamo una funzione che trovi il numero di occorrenze data una parola e una lista di token**


