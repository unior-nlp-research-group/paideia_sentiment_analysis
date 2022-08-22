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
	      "rlang",
	      "hardhat",
	      "recipes",
	      "caret"
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
class(frutta)

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

frase <- "sono al corso di Sentiment Analysis, mi sta piacendo"
substr(frutta, 1, 2)
substr(frase,1,40)

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
stringhe
logici <- logical(7)
logici
numer_interi <- integer(8)
numer_interi

#vettore vuoto
x <- c()
x

#vettore personalizzato
x <- c("Mariapia", "Gennaro")
x

#aggiungere elementi
y <- c(x, "Felice")
print(y)

z <- c("Felice", x)
print(z)

#serie di numeri
serie <- 1:10
serie
#recuperare elementi dai vettori
numeri_pari <- seq(from=0, to=100, by=2)
numeri_pari[12]

frasi <- c("una mela al giorno",
           "una pera alla settimana",
           "un mirtillo al mese",
           "una Mela al giorno")

"mela" == "Mela"
sum(grepl("mela", frasi))

#dataframe

nomi <- c("Mario", "Chiara", "Simona")
anno_di_nascita <- c(1993, 1995, 1996)

?data.frame

data <- data.frame(
  "persone" = nomi,
  "anno_di_nascita" = anno_di_nascita
)

nomi <- c("Mariapia", "Gennaro", "Andrea",
          "Giacomo", "Nicola", "Maria Grazia","Luigi", "Dario")
paesi_di_nascita <- c("Napoli", "Acerra", "Catania", "Napoli",
                      "Salerno", "Lecce", "Napoli", "Salerno")

nomi[1]
paesi_di_nascita[1]


dataframe <- data.frame(
  "names" = nomi,
  "birth places" =paesi_di_nascita
)

class(dataframe)
nrow(dataframe)
ncol(dataframe)

names(dataframe)

sum(dataframe$birth.places == "Napoli")


dataframe

genere_vettore <- c("F", "M", "M", "M", "M", "F", "M", "M")
dataframe$genere <- genere_vettore

sum(
  dataframe$birth.places == "Napoli" &
    dataframe$genere == "M")

dataframe[2,1]

dataframe[3,1:2]

summary(dataframe)
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

colnames(dataframe)

#funzione

nuova_funzione <- function(a,b){
  return(a%%b)
}
nuova_funzione(2,3)
