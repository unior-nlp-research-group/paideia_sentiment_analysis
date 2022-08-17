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
head(my_data)

colnames(my_data)
nrow(my_data)

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
ttr <- length(types) / length(tokens)
cat("Valore di ttr:", ttr)

# espressioni regolari
# https://regex101.com/

testi[2]
str_extract(testi[2], regex("raccontar[a-z]*"))

pattern = regex("#.*")
str_extract(testi, pattern)

pattern = regex("#[A-Za-z0-9àèéòìù]*")
str_extract(testi, pattern)

# **quanti testi presentano hashtag?**
# **estraiamo i tag di altri utenti**

# analisi pos
ud_model <- udpipe_download_model(language = "italian", overwrite = F)
ud_it <- udpipe_load_model(ud_model)


# scriviamo una funzione per estrarre info sintattiche
annotate_splits <- function(x, file) {
  ud_model <- udpipe_load_model(file)
  x <- as.data.table(udpipe_annotate(ud_model, 
                                     x = x$Text,
                                     doc_id = x$id))
  return(x)
}

# vedere pos e lemmi

# load parallel library future.apply
library(future.apply)

# numero di core da utilizzare
ncores <- 3L
plan(multiprocess, workers = ncores)

#prima inseriamo una colonna per identificare gli id dei testi nel dataframe
my_data$id <- seq(1:nrow(my_data))

# dividere il corpus
corpus_splitted <- split(my_data, seq(1, nrow(my_data), by = 1000))

annotation <- future_lapply(corpus_splitted, annotate_splits, file = ud_model$file_model)
annotation <- rbindlist(annotation)
head(annotation)

upos_df <- data.frame(table(annotation$upos))
ggplot(upos_df, aes(x=Var1, y=Freq)) + geom_histogram(stat='identity')

# quali sono le colonne di interesse per la sentiment analysis?
colnames(my_data)

my_data$Multiculturalism
my_data$Style