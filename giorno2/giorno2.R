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
require(data.table)
library(readxl)

#ricarichiamo il nostro file di testo
my_data <- read_excel("./materiali/dataset.xlsx")
my_data <- data.frame(my_data)

sw <- stopwords("it")

testi <- my_data$Text
style <- my_data$Style

#ricarichiamo il file annotato
annotation <- read_csv("~/Progetti/paideia_sentiment_analysis/materiali/annotazioni-sintattiche.csv")

# quali classi di sono presenti nel dataset?
table(my_data$Style)
head(my_data$Style)



my_data$Style[my_data$Style == "positivr"] <- "positive"
my_data$Style <- ifelse(is.na(my_data$Style),
                        "not applicable",
                        my_data$Style)

write.csv(my_data, "./materiali/dataset_fixed.csv")

# 
colnames(annotation)

sum(!is.na(annotation[annotation$dep_rel == "root",]$token))

head(annotation[,7:10])

# raccogliamo i testi per le valutazioni = positive
testi_positive <- my_data[my_data$Style=="positive",]$Text
head(testi_positive,10)

tokens_positive <- unlist(tokenize_words(testi_positive))
class(tokens_positive)
tokens_positive <- tokens_positive[!tokens_positive %in% sw]

head(as.data.frame(table(tokens_positive)))

#creiamo un dataframe che per ogni coppia parola-classe ci mostra la frequenza

total_tokens <- length(tokens_full)
total_tokens

as.data.frame(table(tokens_full))

count_total_tokens <- as.data.frame(table(tokens_full))
plot(count_total_tokens$Freq[count_total_tokens$Freq <= 500])
# **estraiamo i token per una data polarità**


# scriviamo una funzione per estrare i token presenti nei post con una certa polarity

# con tf intendiamo la frequenza relativa del token
get_frequencies <- function(polarity){
  testi_classe <- my_data[my_data$Style==polarity,]$Text
  tokens_classe <- unlist(tokenize_words(testi_classe))
  tokens_classe <- tokens_classe[!tokens_classe %in% sw] 
  
  dataframe_tf <- as.data.frame(
    table(
      #factor ci serve ad avere anche i token che compaiono con occorrenza = 0 in una data classe
      factor(
        tokens_classe, levels = unique(tokens_full)
      )
      #tokens_classe
    )
  )
  dataframe_tf['tf'] <- dataframe_tf$Freq/length(tokens_classe)
  dataframe_tf['classe'] <- c(polarity)
  dataframe_tf <- rename(dataframe_tf, 'tokens'=Var1)
  
  return(dataframe_tf)
}

dataframe_tf_pos <- get_frequencies("positive")
dataframe_tf_neg <- get_frequencies("negative")
dataframe_tf_na <- get_frequencies("not applicable")

dataframe_tf_full <- bind_rows(
  dataframe_tf_pos,
  dataframe_tf_neg,
  dataframe_tf_na,
  .id = "column_label")

head(dataframe_tf_full)

#visualizzare la frequenza di una parola rispetto alle classi

parola <- 'salvini'
dataframe_parola <- dataframe_tf_full[dataframe_tf_full$tokens==parola,]
dataframe_parola

ggplot(data=dataframe_parola) +
  geom_bar(mapping=aes(x=classe, y=tf), stat='identity')

# visualizzare parole per frequenza data una classe
classe_specifica <- 'positive'
dataframe_classe <- dataframe_tf_full[dataframe_tf_full$classe==classe_specifica,]
dataframe_classe
colnames(dataframe_classe)
nrow(dataframe_classe)

dataframe_classe_ordinato <- head(dataframe_classe[order(-dataframe_classe$tf),],10)
dataframe_classe_ordinato

ggplot(data=dataframe_classe_ordinato) +
  geom_bar(mapping=aes(x=reorder(tokens,-Freq) , y=Freq), stat='identity')


# creazione di un progetto di annotazione
# nlpgroup.unior.it


# importare i dati annotati

#install.packages("jsonlite")

library(jsonlite)
library(dplyr)

files <- list.files(path='./materiali/annotazioni_amazon',
                    pattern='utente_paideia*',
                    full.names=TRUE)
files

readfiles <- function(filename){
	lines <- readLines(filename)
	lines <- lapply(lines, fromJSON)
	lines <- lapply(lines, unlist)
	df <- bind_rows(lines)
}

dfs <- lapply(files, readfiles)
is.na(dfs[[1]]$entities.id1)
dataframe_id1_annotatore1

dataframe_id1_annotatore1 <- dfs[[1]]$entities.id1
dataframe_id2_annotatore1 <- dfs[[2]]$entities.id1 
dataframe_id4_annotatore1 <- dfs[[4]]$entities.id1
dataframe_id5_annotatore1 <- dfs[[5]]$entities.id1
dataframe_id7_annotatore1 <- dfs[[7]]$entities.id1

dataframe_id1_annotatore1[is.na(dataframe_id1_annotatore1)] <- "None"
dataframe_id2_annotatore1[is.na(dataframe_id2_annotatore1)] <- "None"
dataframe_id4_annotatore1[is.na(dataframe_id4_annotatore1)] <- "None"
dataframe_id5_annotatore1[is.na(dataframe_id5_annotatore1)] <- "None"
dataframe_id7_annotatore1[is.na(dataframe_id7_annotatore1)] <- "None"


dataframe_id1_annotatore1
install.packages("kappam")
library(irr)
kappam.fleiss(c(
  dataframe_id1_annotatore1,
  dataframe_id2_annotatore1,
  dataframe_id4_annotatore1,
  dataframe_id5_annotatore1,
  dataframe_id7_annotatore1))

dataframe_id1_annotatore1


# analisi IAA

# 1: quali label sono stati annotati dagli annotatori
# 2: quali span sono stati annotati dagli annotatori

kappam.fleiss(df[,c("rater1", "rater2",...)])


