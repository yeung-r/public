# Part 1 Advanced Regression Techniques
# Question A: Switzerland’s Gun Control Referendum

# Load the 2011 Switzerland guncontrol referendum survey dataset
load("dataset/swiss.Rda")
## Loaded as 's'

# Estimate a logistic regression to predict VoteYes
mod1 <- glm(VoteYes ~ female + age + LeftRight + trust + university + suburb + female*suburb,
            family=binomial(link="logit"), data = s)
summary(mod1)

# Average marginal effects
logitmfx(mod1,data=s,atmean = F)

# Changes in predicted probabilities

# Assessment
# Split the data into a training set and a test set
set.seed(1)
training.rows <- sample(nrow(s),(nrow(s)/2))
training.data <- s[training.rows,]
test.data <- s[-training.rows,]

mod2 <- glm(VoteYes ~ female + age + LeftRight + trust + university + suburb + female*suburb, 
            family=binomial(link="logit"), data = training.data)

# Produce predicted probabilities for the test data
logit.probs.test <- predict(mod2,test.data, type="response")

# Predict the class (0 or 1) of each observation in the test data using the ifelse() function 
# assigning 1 to all observations with a predicted probability greater than 0.5
logit.preds.test <- ifelse(logit.probs.test>0.5,1,0)

# form a confusion matrix for the classifications
x <- table(logit.preds.test,test.data$VoteYes) 

# Calculate error rate
(x[1,2]+x[2,1])/nrow(test.data)
# Calculate sensitivity
x[2,2]/(x[1,2]+x[2,2])
# Calculate specificity
x[1,1]/(x[1,1]+x[2,1])

# create roc plot and calculate area under it
rocplot <- roc(test.data$VoteYes,logit.probs.test)
rocplot$auc
