# Part B: A Second Referendum?

library(performance)
library(boot)
library(wesanderson)

# Load the datasets
load("dataset/bes15.Rda")
load("dataset/psw_Hanretty.Rda")
load("dataset/motionE.Rda")

# Estimate a logitistc multilevel model for support towards a second referendum
mod1 <- glmer(eurefdoOver ~ ageGroup + highed + 
                socialGrade + c_leaveHanretty_s + 
                c_whitebritish_s + (1|ccode),
              family=binomial(link="logit"),data=bes)
summary(mod1)
fixef(mod1)

# PREDICTED PROBABILITIES
# Age
inv.logit(fixef(mod1)[2]*8) - inv.logit(fixef(mod1)[2])
# University degree
inv.logit(fixef(mod1)[3])
# Social grade C1
inv.logit(fixef(mod1)[4])
# Social grade C2
inv.logit(fixef(mod1)[5])
# Social grade DE
inv.logit(fixef(mod1)[6])
# Scaled share of leave voters in the 2016 EU Referendum in the constituency
inv.logit(fixef(mod1)[7])
# Scaled percent of constituency population who are white British
inv.logit(fixef(mod1)[8])

# POST STRATIFICATION
# 1. Predict
post$prediction <- predict(mod1,newdata=post,type="response",allow.new.levels=TRUE)

# 2. Weight
post$weight.pred <- post$prediction*post$weight*100

# 3. Post-stratify
results <- aggregate(weight.pred~ccode, data=post,sum)

# COMPARISON
# extract the needed columns
remain <- motionE[,c(1,5)]
# merge the two together by constituency codes
comparison <- merge(results, remain, by="ccode")
# calculate the difference in average
mean(comparison$c_remainHanretty) - mean(comparison$weight.pred)

palette <- wes_palette("FantasticFox1")
vals <- c('‘remain’ voters in 2016'=palette[5],'estimates of "support" for second ref'=palette[3])

# Create scatter plot for comparison
ggplot(comparison,aes(x=ccode)) +
  geom_point(aes(y=weight.pred,col='‘remain’ voters in 2016')) +
  geom_point(aes(y=c_remainHanretty,col='estimates of "support" for second ref')) +
  scale_y_continuous("share (in %)",
                     limits=c(0,100),
                     breaks = seq(0,100,by=10)) +
  xlab("UK parliamentary constituency code, from E14000530 to W07000080") +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        legend.position = "bottom") +
  scale_color_manual("",values = vals)

# extract needed columsn
mpvote <- motionE[,c(1,4)]

# merge by code
comparison2 <- merge(results, mpvote, by="ccode")

# create plot
ggplot(comparison2, aes(x=ccode)) +
  geom_point(aes(y=weight.pred,col=voteOn2Ref)) +
  scale_y_continuous("estimated share of second ref supporters (in %)",
                     limits=c(0,100),
                     breaks = seq(0,100,by=10)) +
  xlab("UK parliamentary constituency code, from E14000530 to W07000080") +
  theme(axis.text.x=element_blank(),
        legend.position = "bottom")

