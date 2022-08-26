#importiamo le librerie che useremo in questa giornata
library(tidyverse)
library(ggplot2)
library(tokenizers)
library(wordcloud2)
library(RColorBrewer)
library(SnowballC)
library(udpipe)
library(readxl)
library(stopwords)
library(R.utils)
library(tm)
library(data.table)

#ricarichiamo il nostro file di testo
my_data <- read.csv("./materiali/dataset_fixed.csv")
my_data <- data.frame(my_data)

head(my_data[,1:2])



sw <- stopwords("it")

colnames(my_data)
testi <- my_data$Text

#tokenizzazione ed eliminazione stop word
tokens_full <- tokenize_words(testi)

style <- my_data$Style

#visualizzazione dei risultati

# wordcloud

tokens_positive <- tokens_full[my_data$Style=="positive"]
tokens_positive <- unlist(tokens_positive)
tokens_positive <- tokens_positive[!tokens_positive %in% sw]

install.packages("wordcloud2")
library(wordcloud2)
set.seed(1234)
wordcloud(unique(tokens_positive),
          freq = as.data.frame(table(tokens_positive))$Freq,
          min.freq = 5,
          max.words=500,
          random.order=FALSE, 
          colors=brewer.pal(8, "Accent"),
          scale=c(2.5,0.25)
          )
?wordcloud
#ggplot2

my_data$style_num <- ifelse(
  my_data$Style=='positive',
  1,
  -1
)

unique(my_data$Style)
table(my_data$Style)

my_data$style_num

ggplot(my_data) +
  geom_bar(aes(y=Style, fill=Style))

freq_tokens <- data.frame(table(unlist(tokens_full)))
freq_tokens <- freq_tokens[order(-freq_tokens$Freq),]
colnames(freq_tokens)


ggplot(head(freq_tokens)) +
  geom_bar(aes(x=Var1, y=Freq), stat="identity")

my_data$x <- rep(c(1:5), nrow(my_data)%/%5)
my_data$y <- rep(c(1:5), nrow(my_data)%/%5)

ggplot(my_data, aes(id))+
  geom_raster(aes(fill=style_num))

#**visualizziamo le valenze nel dataset estratte attraverso NRC**
#*
#*
#*
nrc_table <- as.data.frame(
  fread('../materiali/NRC-VAD-Lexicon-Aug2018Release/OneFilePerLanguage/Italian-it-NRC-VAD-Lexicon.txt'
  )
)

head(nrc_table)

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
sentiment_values_dataframe  <- sentiment_values_dataframe[
  order(-sentiment_values_dataframe$sentiment_values)
  ,]

sentiment_values_dataframe$index <- seq(
  from=1,
  to=nrow(sentiment_values_dataframe),
  by=1)


ggplot(sentiment_values_dataframe)+
  geom_bar(aes(x=seq(1:nrow(sentiment_values_dataframe)+1),
            y=sentiment_values,
            color=sentiment_values,
            ), stat='identity')

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
#valutazioni dei risultati
#correlazione tra la sentiment calcolata e le statistiche del dataset


sentiment_values_dataframe <- data.frame(
  sentiment_values, my_data$Style
)

ggplot(sentiment_values_dataframe, aes(x=style, y=sentiment_values)) +
  geom_point()

# controlliamo quali testi presentano problematiche

incongruenze <- sentiment_values_dataframe[
  sentiment_values_dataframe$style == 'negative' &
    sentiment_values_dataframe$sentiment_values >= 0.25
  ,]

incongruenze
tokens_full[67]


# **esaminare e visualizzare i risultati con un altro lessico/corpus**



#### ** esperimenti dati fake news

fake_news <- read_excel('./materiali/bufala-bufale.xlsx')
real_news <- read_excel('./materiali/notizia-vera-bufale.xlsx')

fake_news <- na.omit(fake_news)
real_news <- na.omit(real_news)

fake_news <- fake_news$Field2
real_news <- real_news$Field2

fake_news_tokens <- unlist(tokenize_words(lapply(fake_news, tolower)))
real_news_tokens <- unlist(tokenize_words(lapply(real_news, tolower)))

n_i <- length(fake_news_tokens)
n_j <- length(real_news_tokens)
alpha <- c(fake_news_tokens, real_news_tokens)
n_alpha <- n_i + n_j

francesco_totti <- function(parola){
  parola_i <- sum(fake_news_tokens == parola)
  parola_j <- sum(real_news_tokens == parola)
  
  parola_alpha <- sum(alpha == parola)
  
  num1 <- log((parola_i + parola_alpha)/(n_i + n_alpha - (parola_i + parola_alpha)))
  num2 <- log((parola_j + parola_alpha) / (n_j + n_alpha - (parola_j + parola_alpha)))
  
  num <- num1 - num2
  
  denom <- 1 / (parola_i  + parola_alpha) + 1 / (parola_j + parola_alpha)
  
  log_odd <- num / sqrt(denom)
  return(log_odd)
}

tokens_full <- unique(alpha)
log_odds_full <- lapply(tokens_full, francesco_totti)


df_logodds <- data.frame(
  "token" = tokens_full,
  "log_odds" = unlist(log_odds_full)
)

df_logodds <- df_logodds[order(-df_logodds$log_odds),]
head(df_logodds, 20)

tail(df_logodds, 20)
