# scarichiamo le librerie necessarie per il corso

librerie <- c('tidyverse',
              'tokenizers',
              'udpipe',
              'tm',
              'stopwords',
              'R.utils',
              "tidytext",
              'textdata',
              "readxl",
              "parallel",
              "future.apply",
	      "irr",
	      "RTextTools",
	      "e1071",
	      "rlang"
	      "hardhat",
	      "recipes",
	      "caret",
)
librerie_nuove <- librerie[!(librerie %in% installed.packages()[,"Package"])]
if(length(librerie_nuove)>0)
  install.packages(librerie_nuove)


# le righe introdotte da un cancelletto sono commenti
# il codice eseguito in queste righe non viene letto dal programma
# i commenti sono utili a organizzare il codice e renderlo più leggibile

cat("1+1 = ", 1 + 1) 
cat("1-1 =  ",1 - 1)
cat("2*2 = ", 2*2)
cat("2/2 = ", 2/2)
cat("2^3 = ", 2^3)
cat("resto di 17/5 =", 17%%5)
cat("parte intera di 17/5 =", 17%/%5)

# variabili
x <- 5
x + 6


#controllare la classe di una variabile
class(x)

#stringhe e caratteri 
frutta <- "mela"


# numero di caratteri in una stringa
nchar(frutta)

# concatenare stringhe
m <- "m"
e <- "e"
l <- "l"
a <- "a"

paste(m,e,l,a)
paste(m,e,l,a, sep='')

#sottostringa
substr(frutta, 1, 2)

#booleani
bool1 <- TRUE
bool2 <- FALSE

# operatori logici
print("4 minore di 5?")
4 < 5
print("5 minore di 12?")
5 > 12
print("3 minore o uguale di 3?")
3 <= 3
print("3 uguale a 3?")
3 == 3
print("3 diverso da 8?")
3 != 8
print("Operazioni complesse")
!(4<5)
grepl("mela", "una mela al giorno")
!grepl("mela", "una mela al giorno")
((4<5)|(5>12))
((4<5)&(5>12))

#liste di elementi uguali

stringhe <- character(10)
logici <- logical(7)
numer_interi <- integer(8)

#vettore vuoto
x <- c()

#vettore personalizzato
x <- c("Mariapia", "Gennaro")

#aggiungere elementi
y <- c(x, "Felice")
print(y)

z <- c("Felice", x)
print(z)

#serie di numeri
serie <- 1:10

#recuperare elementi dai vettori
numeri_pari <- seq(from=0, to=100, by=2)
print(numeri_pari)
numeri_pari[12]

#dataframe

nomi <- c("Mario", "Chiara", "Simona")
anno_di_nascita <- c(1993, 1995, 1996)

data <- data.frame(
  "persone" = nomi,
  "anno_di_nascita" = anno_di_nascita
)
print("---Dataframe:---")
data
print("---Numero di righe---")
nrow(data)
print("---Prima riga---")
data[1,]
print("---Nomi delle colonne--")
colnames(data)
print("---Colonna 'persone'--")
data["persone"]

#funzione

nuova_funzione <- function(a,b){
  print(a + b)
}
nuova_funzione(2,3)
