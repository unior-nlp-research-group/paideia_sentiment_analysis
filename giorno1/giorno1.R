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
my_data <- read_excel("./materiali/dataset.xlsx")
my_data <- data.frame(my_data)

class(my_data)
nrow(my_data)
colnames(my_data)
head(unique(my_data$Name))


head(my_data$Style)

testi <- my_data$Text

#tokenizzazione
tokens <- tokenize_words(testi)
head(tokens)

length(tokens)

tokens <- unlist(tokens)
head(tokens)
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


pattern = "[aA][mM][aoiAOI][rR]*[eEiI]*"

sum(!is.na(str_extract(testi, regex(pattern))))




nas <- c(NA, NA, 4)
is.na(nas)


pattern = regex("#[A-Za-z0-9àèéòìù]*")
table(str_extract(tolower(testi), pattern))

# **quanti testi presentano hashtag?**
# **estraiamo i tag di altri utenti**

# rimozione punteggiatura

clean_text <- function(text){
  text <- tolower(text)
  text <- gsub(".", " ", text, fixed=TRUE)
  text <- gsub(":", " ", text, fixed=TRUE)
  text <- gsub("?", " ", text, fixed=TRUE)
  text <- gsub("!", " ", text, fixed=TRUE)
  text <- gsub("; ", " ", text, fixed=TRUE)
  text <- gsub(", ", " ", text, fixed=TRUE)
  text <- gsub("\ `", " ", text, fixed=TRUE)
  text <- gsub("\n", " ", text, fixed=TRUE)
  text <- gsub("\r", " ", text, fixed=TRUE)

  return(text)
  }

my_data$clean_text <- clean_text(my_data$Text)


# analisi sintattica
ud_it <- udpipe_load_model(file='./materiali/italian-isdt-ud-2.5-191206.udpipe')
annotazione = as.data.table(udpipe_annotate(ud_it, 
                                            x="Questo è il corso di sentiment analysis per le scienze sociali",
                                            doc_id = 1))

annotazione[annotazione$upos=='PRON']

# scriviamo una funzione per estrarre info sintattiche
annotate_splits <- function(x) {
  ud_model <- ud_it
  x <- as.data.table(udpipe_annotate(ud_model, 
                                     x = x$clean_text,
                                     doc_id = x$id))
  return(x)
}


# load parallel library future.apply
library(future.apply)

# numero di core da utilizzare
ncores <- 3L
plan(multiprocess, workers = ncores)

#prima inseriamo una colonna per identificare gli id dei testi nel dataframe
my_data$id <- seq(1:nrow(my_data))

# dividere il corpus
corpus_splitted <- split(my_data, seq(1, nrow(my_data), by = 1000))

annotation <- future_lapply(corpus_splitted, annotate_splits)
annotation <- rbindlist(annotation)
head(annotation)

write.csv(annotation, 'annotazioni-sintattiche.csv')


upos_df <- data.frame(table(annotation$upos))
ggplot(upos_df, aes(x=Var1, y=Freq)) + geom_histogram(stat='identity')

# quali sono le colonne di interesse per la sentiment analysis?
colnames(my_data)

my_data$Multiculturalism
my_data$Style



## **carichiamo il dataset poivorrei dai materiali**

## **ripetiamo gli step spiegati in questa giornata**
