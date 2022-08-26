library(readxl)
library(tokenizers)


bufale <- read_excel('./materiali/bufala-bufale-xlsx')
vere <- read_excel('./materiali/notizia-vera-bufale.xlsx')

set_labels <- c("bufale", "vere")

text_bufale <- bufale$Field2
text_vere <- vere$Field2

text_full <- c(text_bufale, text_vere)
corpus <- paste(text_full, collapse=' ')
tokens_all <- tokenize_words(corpus)[[1]]
tokens_unique <- unique(tokens_all)

corpus_bufale <- tokenize_words(text_bufale)
corpus_vere <- tokenize_words(text_vere)

log_odds <- function(token, corpus_i, corpus_j, background_corpus){
  w_i <- length(which(corpus_i == token))
  w_j <- length(which(corpus_j == token))
  alpha_w <- length(which(background_corpus == token))
  n_i <- length(corpus_i)
  n_j <- length(corpus_j)
  alpha_zero <- length(background_corpus)
  
  num <- log((w_i + alpha_w) / (n_i + alpha_zero - w_i - alpha_w)) - log((w_j + alpha_w) / (n_j + alpha_zero - w_j - alpha_w))
  dirichlet_prior <- (1/(n_i + alpha_w)) + (1/(n_j + alpha_w))
  
  denum <- sqrt(dirichlet_prior)
  
  lodd <- num / denum
  
  return(lodd)
}


all_lodds <- data.frame(matrix(ncol=2, nrow=0))
x <- c(
       "bufale",
       "notizie_vere"
      )
colnames(all_lodds) <- x

for (token in tokens_unique){
  lodd_token_bufale <- log_odds(token, corpus_bufale, 
				corpus_vere, tokens_all)
  row <- c(token,
           lodd_token_bufale
	   )
  all_lodds[nrow(all_lodds)+1,] = row
}


head(all_lodds)

write.csv(all_lodds, "lodds_texts_bufale.csv", row.names = FALSE)


