# POLS0010 Assessment 2

library(foreign)
ca_indresp_w <- read.dta("worksheet_data/ca_indresp_w_POLS0010.dta")

# Missing data
# Remove all rows that are skipped because being non applicable
ca_indresp_w <- ca_indresp_w[!(ca_indresp_w$ca_timechcare==-8),]

# Assign all other missing (negative) values as NA
ca_indresp_w$ca_timechcare[ca_indresp_w$ca_timechcare<0] <- NA
ca_indresp_w$ca_scghq1_dv[ca_indresp_w$ca_scghq1_dv<0] <- NA
summary(ca_indresp_w$ca_timechcare)
table(ca_indresp_w$psu)

# Create a new variable by adding up the three variables of household composition
ca_indresp_w$ca_hhcomp <- ca_indresp_w$ca_hhcompa + ca_indresp_w$ca_hhcompb + ca_indresp_w$ca_hhcompc

# Impute missing values in the time variable
library(VIM)
ca_indresp_w.hotdeck<-hotdeck(ca_indresp_w, variable = "ca_timechcare", ord_var="ca_scghq1_dv")

# Turn the time variable into a categorical variable with four levels
ca_indresp_w.hotdeck$ca_timechcare <- cut(ca_indresp_w.hotdeck$ca_timechcare, 
                                          breaks=c(-Inf, 36, 72, 108, Inf), 
                                          labels=c("low", "low-middle", "middle","high"))

# Impute missing values in the subjective well-being variable
ca_indresp_w.hotdeck<-hotdeck(ca_indresp_w.hotdeck, variable = "ca_scghq1_dv", domain_var="ca_timechcare")

# Turn the time variable into a categorical variable with four levels
ca_indresp_w$ca_timechcare <- cut(ca_indresp_w$ca_timechcare, 
                                  breaks=c(-Inf, 36, 72, 108, Inf), 
                                  labels=c("low", "low-middle", "middle","high"))

# Conduct sensitivity analysis
# Time variable with table
table(ca_indresp_w$ca_timechcare)
table(ca_indresp_w.hotdeck$ca_timechcare)
# Time variable with bar chart
library(ggplot2)
ggplot(ca_indresp_w) + geom_bar(aes(x = ca_timechcare))
ggplot(ca_indresp_w.hotdeck) + geom_bar(aes(x = ca_timechcare))
# Subjective well-being variable with mean
mean(ca_indresp_w$ca_scghq1_dv)
mean(ca_indresp_w.hotdeck$ca_scghq1_dv)
# Subjective well-being with histogram
hist(ca_indresp_w$ca_scghq1_dv)
hist(ca_indresp_w.hotdeck$ca_scghq1_dv)
# Entire dataset with regression
lm1 <- lm(ca_scghq1_dv~ca_timechcare, data=ca_indresp_w)
summary(lm1)
lm2 <- lm(ca_scghq1_dv~ca_timechcare, data=ca_indresp_w.hotdeck)
summary(lm2)




# Description of dataset, Descriptive statistics

# Complex survey design
# Remove respondents without a valid weighting variable value, which are coded as non-applicable (zero)
ca_indresp_w<-subset(ca_indresp_w, ca_betaindin_xw>0) 
# Create survey design object
library(survey)
srs_design <- svydesign(id = ~pidp, nest=TRUE,data = ca_indresp_w.weighted, weights = ~ca_betaindin_xw)
clus_design <- svydesign(id = ~psu, nest=TRUE,data = ca_indresp_w.weighted, weights = ~ca_betaindin_xw)
strat_design <- svydesign(id = ~psu, strata= ~strata, nest=TRUE,data = ca_indresp_w.weighted, weights = ~ca_betaindin_xw)
options(survey.lonely.psu="adjust")

# Comparison
svytable(~ca_timechcare,srs_design)
svytable(~ca_timechcare,clus_design)
svytable(~ca_timechcare,strat_design)
svymean(~ca_scghq1_dv, srs_design)
svymean(~ca_scghq1_dv, clus_design)
svymean(~ca_scghq1_dv, strat_design)

svy.lm1 <- svyglm(formula = ca_scghq1_dv~ca_timechcare, design = srs_design)
svy.lm2 <- svyglm(formula = ca_scghq1_dv~ca_timechcare, design = clus_design)
svy.lm3 <- svyglm(formula = ca_scghq1_dv~ca_timechcare, design = strat_design)
summary(svy.lm1)
summary(svy.lm2)
summary(svy.lm3)
AIC(svy.lm1)
AIC(svy.lm2)
AIC(svy.lm3)
## As the regression done with stratified sampling data has a lower AIC score, the model fits the dataset worse
## And the values, mean and standard error does not change significantly
## The following analysis will be done correcting for clustering and without correcting for stratified sampling

summary(svy.lm2)
svy.lm4 <- svyglm(formula = ca_scghq1_dv~ca_timechcare+ca_hhcomp, design = clus_design)
summary(svy.lm4)