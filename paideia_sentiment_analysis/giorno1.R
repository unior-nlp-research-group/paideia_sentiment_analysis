#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(tokenizers)
library(udpipe)
library(stopwords)
library(R.utils)
library(tm)
library(parallel)
library(readxl)
library(data.table)


# importiamo il dataset
my_data <- read_excel("../materiali/dataset.xlsx")
my_data <- data.frame(my_data)

class(my_data)
colnames(my_data)
nrow(my_data)

my_data$id <- seq(1:nrow(my_data))
head(my_data)
my_data$Style
table(my_data$Style)

my_data$Style[my_data$Style == "positivr"] = "positive"

testi <- my_data$Text



#tokenizzazione
tokens <- tokenize_words(testi)
length(tokens)

tokens <- unlist(tokens)
length(tokens)
#tokens <- unlist(tokenize_words(testo))
cat("Numero totale di token:", length(tokens))

#**calcoliamo la lunghezza media delle frasi in token e caratteri**

#calcolo di ttr
types <- unique(tokens)
cat("Numero totale di token unici:", length(types))
ttr <- length(tokens) / length(types)
cat("Valore di ttr:", ttr)


# esaminiamo una parola di interesse
parola_di_interesse <- "ottimo"
tokens==parola_di_interesse
num_occorrenze <- sum(tokens==parola_di_interesse)
cat("La parola", parola_di_interesse, " compare ", num_occorrenze, " volte nel testo")

# **scriviamo una funzione che trovi il numero di occorrenze data una parola e una lista di token**



#parole per occorrenza
freq_parole <- as.data.frame(table(tokens))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]

head(freq_parole_ordinate,10)

#stopword
sw <- stopwords("it")
head(sw, 10)
class(sw)

tokens_clean <- tokens[!tokens %in% sw]
freq_parole <- as.data.frame(table(tokens_clean))
freq_parole_ordinate <- freq_parole[order(-freq_parole$Freq),]
head(freq_parole_ordinate,10)

#**aggiungiamo parole aggiuntive alla lista di stop word**


#lemmatizzazione

ud_model <- udpipe_download_model(language = "italian", overwrite = F)
ud_it <- udpipe_load_model(ud_model)


# scriviamo una funzione
annotate_splits <- function(x, file) {
  ud_model <- udpipe_load_model(file)
  x <- as.data.table(udpipe_annotate(ud_model, 
                                     x = x$Text,
                                     doc_id = x$id))
  return(x)
}


# load parallel library future.apply
library(future.apply)

# Define cores to be used
ncores <- 3L
plan(multiprocess, workers = ncores)

# split comments based on available cores
corpus_splitted <- split(my_data, seq(1, nrow(my_data), by = 100))

annotation <- future_lapply(corpus_splitted, annotate_splits, file = ud_model$file_model)
annotation <- rbindlist(annotation)


lemmi <- annotation$lemma[!annotation$lemma %in% sw]
freq_lemmi <- as.data.frame(table(lemmi))
freq_lemmi_ordinati <- freq_lemmi[order(-freq_lemmi$Freq),]

head(freq_lemmi_ordinati,10)


library(wordcloud)
set.seed(1234)
wordcloud(words = freq_lemmi$lemmi, freq = freq_lemmi$Freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

# **aggiungiamo punteggiatura e altre stop word per avere risultati migliori**