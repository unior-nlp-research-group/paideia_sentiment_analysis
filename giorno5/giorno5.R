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
my_data$id <- seq(1:nrow(my_data))


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



#visualizzazione dei risultati

# wordcloud

testi_positive <- my_data[my_data$Style=="positive",]$Text
tokens_positive <- unlist(tokenize_words(testi_positive))
tokens_positive <- tokens_positive[!tokens_positive %in% sw]

set.seed(1234)
wordcloud(words = tokens_positive, freq = as.data.frame(table(tokens_positive))$Freq, min.freq = 1,
          max.words=200, random.order=FALSE, size=1.6, 
          colors=brewer.pal(8, "Dark2"))

#ggplot2

my_data$style_num <- ifelse(
  my_data$Style=='positive',
  1,
  -1
)
my_data$style_num
ggplot(my_data)+
  geom_bar(aes(y=Style, fill=Style))

ggplot(my_data, aes(id,0.5))+
  geom_tile(aes(fill=style_num))

#**visualizziamo le valenze nel dataset estratte attraverso NRC**
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


# **esaminare i risultati con un altro lessico**
# **esaminare quali parole creano le incongruenze tra i risultati**
