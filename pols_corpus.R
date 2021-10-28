library(quanteda)
library(glmnet)
library(ggplot2)
library(ggthemes)
library(tidytext) 
library(wesanderson)

# SETUP
# Load the data and turn it into a corpus with metadata
load("dataset/tweets.Rda")
tweetCorpus <- corpus(tweets$text, docvars = tweets)

# Turn the corpus into a document-term matrix
# To lowercase, remove numbers, punctuations and stopwords
dfm_air <- dfm(tweetCorpus,
              tolower=T,
              remove_numbers=T,
              remove_punct=T,
              remove_symbols = T,
              remove = stopwords("en"))

# Check how many unique words there are
dim(dfm_air)
## 13065

# Remove words with @, e.g. @USAirways
dfm_air <- dfm_select(dfm_air, pattern = c("@*"), selection = "remove")

# Remove very rare words that are used in only one or two tweets
doc_freq <- docfreq(dfm_air)
dfm_air <- dfm_air[,doc_freq>2]

# Remove special symbols and single letters
dfm_air <- dfm_remove(dfm_air,c("�","=","|","<",">","^","+","~","amp",letters))

# Remove place and airline names and the generic "flight" word
dfm_air <- dfm_remove(dfm_air, 
                      c("bos","boston","fll","lax","jfk","dfw","aa",
                        "sfo","gt","phl","dc","charlotte","philly",
                        "dallas","ewr","dca","atl","la","iah","houston",
                        "denver","las","bwi","ord","pdx","clt","luv",
                        "austin","southwest","sw","virgin","va","vx",
                        "united","jetblue","us","jet","blue","american",
                        "usair","flight"))
dim(dfm_air)
## 3658 unique words

textstat_frequency(dfm_air)[1:10]


# IDENTIFYING WORDS ASSOCIATED WITH POSITIVE OR NEGATIVE SENTIMENT
# Turn the document-term matrix into a matrix 
dfm_air_posneg <- as.matrix(dfm_air)
# Adding the labeled classifications from the tweets dataset as the first column
dfm_air_posneg <- cbind(tweets$sentiment, dfm_air_posneg)

# Use the cross-validation set to train a classifier using logit lasso
lasso.air0 <- cv.glmnet(x=dfm_air_posneg[,2:3615],y=dfm_air_posneg[,1],
                       family="binomial",type.measure="class")

# Identifying the words associated to positive or negative sentiment
lasso.coef <- as.matrix(coef(lasso.air0)[coef(lasso.air0)[,1]!=0,])
lasso.coef <- as.matrix(lasso.coef[order(lasso.coef[,1],decreasing = T),])
# Most negative
lasso.coef[1:40,]
# Most positive
lasso.coef[(nrow(lasso.coef)-40):nrow(lasso.coef),]

# COMPARISON AMONG AIRLINES
# Remove generic and commonly-used words that are not removed by quanteda’s stopwords algorithm
dfm_air_tfidf <- dfm_tfidf(dfm_air)

# Create charts plotting the frequencies of the 15 most-used words
comparison <- textstat_frequency(dfm_air_tfidf,15,groups="airline",force=T)

airlines <- comparison[comparison$group%in%c("United", "JetBlue", "American", "US Airways", 
                                             "Virgin America", "Southwest"),]

ggplot(airlines,
       aes(x=frequency,
           y=reorder_within(feature,frequency,group))) +
  facet_wrap(~group,scales="free_y") +
  scale_y_reordered() +
  geom_point() +
  labs(title ="Plots showing the frequencies of the 15 most-used words in tweets, grouped by airline", x = "Frequency (TF-IDF Weighted)", y = "")
  theme_calc()

# Group the texts according to airlines
dfm_air_stem <- dfm_group(dfm_air, groups = "airline")

# Compare differences in word use between the six airlines using a comparative wordcloud
pal <- wesanderson::wes_palette("FantasticFox1")
textplot_wordcloud(dfm_air_stem,
                   max_size=3,
                   comparison=TRUE,
                   max_words=150,
                   color = pal)

# DICTIONARY-BASED CLASSIFICATION
# Create a dictionary called mydict that contains negative and positive categories
neg.words <- c("ruining","subpar","dissatisfied","worst","#worstflightever",
               "canned","robotic","unfortunately","wasting","annoying",
               "crashing","screwed","rude","anymore","delayed")
pos.words <- c("love","admiral","excited","pleasantly","greatest","praise",
               "rock","favorite","thanks","#bestairline","props",
               "amazing","comfortable","exceptional","wonderful")
mydict <- dictionary(list(negative = neg.words, positive = pos.words))

# Turn the corpus into a document-term matrix weighted by document length, removing numbers, punctuation and stopwords
# with  mydict as dictionary
tweet.sent <- dfm_weight(dfm(tweetCorpus,
                             remove_numbers=T,
                             remove = stopwords("en"),
                             remove_punct=T,
                             remove_symbols = T,
                             dictionary = mydict),
                         scheme="prop")

# Remove very rare words that are used in only one or two tweets
doc_freq <- docfreq(tweet.sent)
tweet.sent <- tweet.sent[,doc_freq>2]

# Remove words with @, e.g. @USAirways
tweet.sent <- dfm_select(tweet.sent, pattern = c("@*"), selection = "remove")

# Remove special symbols and single letters
tweet.sent <- dfm_remove(tweet.sent,c("�","=","|","<",">","^","+","~","amp",letters))
# Remove place and airline names and the generic "flight" word
tweet.sent <- dfm_remove(tweet.sent, 
                         c("bos","boston","fll","lax","jfk","dfw","aa",
                           "sfo","gt","phl","dc","charlotte","philly",
                           "dallas","ewr","dca","atl","la","iah","houston",
                           "denver","las","bwi","ord","pdx","clt","luv",
                           "austin","southwest","sw","virgin","va","vx",
                           "united","jetblue","us","jet","blue","american",
                           "usair","flight"))

# Turn the document-term matrix into a data frame
tweet.sent <- convert(tweet.sent,to="data.frame")

# Classify the reviews as negative or positive, 
# assigning 1 (negative) to tweets with more negative words/phrases than positive, and 0 (positive) otherwise
tweet.sent$score <- ifelse((tweet.sent$negative - tweet.sent$positive)>0,1,0)

# MODEL WITH MODEL-BASED (SUPERVISED) CLASSIFICATION
# Turn the corpus into a document-term matrix weighted by document length, removing numbers, punctuation and stopwords
dfm_air_weighted <- dfm_weight(dfm(tweetCorpus,
                          remove_numbers=T,
                          remove = stopwords("en"),
                          remove_punct=T,
                          remove_symbols = T,),
                      scheme="prop")

# Remove very rare words that are used in only one or two tweets
doc_freq <- docfreq(dfm_air_weighted)
dfm_air_weighted <- dfm_air_weighted[,doc_freq>2]

# Remove words with @, e.g. @USAirways
dfm_air_weighted <- dfm_select(dfm_air_weighted, pattern = c("@*"), selection = "remove")

# Remove special symbols and single letters
dfm_air_weighted <- dfm_remove(dfm_air_weighted,c("�","=","|","<",">","^","+","~","amp",letters))
# Remove place and airline names and the generic "flight" word
dfm_air_weighted <- dfm_remove(dfm_air_weighted, 
                      c("bos","boston","fll","lax","jfk","dfw","aa",
                        "sfo","gt","phl","dc","charlotte","philly",
                        "dallas","ewr","dca","atl","la","iah","houston",
                        "denver","las","bwi","ord","pdx","clt","luv",
                        "austin","southwest","sw","virgin","va","vx",
                        "united","jetblue","us","jet","blue","american",
                        "usair","flight"))

# Adding the labeled classifications from the tweets dataset as the first column
dfm_air_weighted <- as.matrix(cbind(tweets$sentiment, dfm_air_weighted))

# Divide the matrix randomly in half into a cross-validation set and a test set
set.seed(1)
cv.rows <- sample(nrow(dfm_air_weighted),(nrow(dfm_air_weighted)/2))
cv.data1 <- dfm_air_weighted[cv.rows,]
test.data1 <- dfm_air_weighted[-cv.rows,]

# Use the cross-validation set to train a classifier using logit lasso
lasso.rev1 <- cv.glmnet(x=cv.data1[,2:3595],y=cv.data1[,1],
                       family="binomial",type.measure="class")

# Use the predict() function to classify the test set
tweet.preds <- predict(lasso.rev1,
                       test.data1[,2:3595],
                       type='class')

# MODEL ASSESMENT
model.assessment <- function(x,y){
  # x = predicted values 
  # y = actual outcomes 
  if (length(x)!=length(y)) return("x and y have differing length")
  if (is.factor(x)) x <- as.character(x)
  if (is.factor(y)) y <- as.character(y)
  if (!is.numeric(x)) x <- as.numeric(x)
  if (!is.numeric(y)) y <- as.numeric(y)
  if (min(x)!=0|max(x)!=1|min(y)!=0|max(y)!=1) return("x or y are not correctly coded as either 0 or 1")
  # Total error rate 
  error.rate <- round(length(x[y!=x])/length(x),4)
  # Sensitivity 
  true1 <- x[y==1]
  sens <- round(mean(true1),4)
  # Specificity
  true0 <- x[y==0]
  spec <- round(1-mean(true0),4)
  
  return(c("Error rate"=error.rate*100,"Sensitivity"=sens*100,"Specificity"=spec*100))
}
# calculate the test error rate sensitivity and specificity of the dictionary-based classifier for the entire set
model.assessment(tweet.sent$score, tweets$sentiment)
# calculate the test error rate, sensitivity and specificity of the model-based classifier for test set created
model.assessment(tweet.preds,test.data1[,1])
