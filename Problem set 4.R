library(DBI)
library(data.table)
library(RSQLite)
library(plm)
library(broom)
library(dplyr)
library(sandwich)
library(lmtest)
library(margins)

con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')

#Fuction
tidyg <- function(model,vc=vcov(model),conf.int=FALSE,conf.level=0.95){
  dt <- tidy(model,conf.int=conf.int,conf.level=conf.level)
  se <- sqrt(diag(vc))
  dt$std.error <- se
  dt$statistic <- dt$estimate/dt$std.error
  dt$p.value <- 2*pnorm(-abs(dt$statistic))
  if(conf.int){
    dt$conf.low <- dt$estimate+qnorm((1-conf.level)/2)*dt$std.error
    dt$conf.high <- dt$estimate-qnorm((1-conf.level)/2)*dt$std.error
  }
  return(dt)
}

tidyw <- function(model,...){
  return(tidyg(model,vc=sandwich::vcovHC(model),...))
}

tidyhac <- function(model,...){
  warning('n must be much greater than T')
  return(tidyg(model,plm::vcovHC(model),...))
}


#Q1
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
hprice1 <- data.table(dbReadTable(con,'hprice1'))
head(hprice1)
model1 <- lm(price~assess+bdrms+lotsize+sqrft+colonial+I(assess+bdrms+lotsize+sqrft+colonial)^3
             +I(assess^2)+I(bdrms^2)+I(lotsize^2)+I(sqrft^2)+I(colonial^2)
             +assess:bdrms+assess:lotsize+assess:sqrft+assess:colonial+bdrms:lotsize+bdrms:sqrft
             +bdrms:colonial+lotsize:sqrft+lotsize:colonial+sqrft:colonial,data=hprice1)
model1 <- step(model1,k=log(nrow(hprice1)))
summary(model1)
BIC(model1)
#The best model I found which AIC and BIC is 674.19 and 928.3994.

#Q2
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
gpa2 <- data.table(dbReadTable(con,'gpa2'))
head(gpa2)
model2<-lm(colgpa~(sat+tothrs+athlete+hsrank+female+black)^2,data =gpa2)
model2<-step(model2,k=log(nrow(gpa2)))
summary(model2)
BIC(model2)
#The best model I found which AIC and BIC is -4799.47 and 6949.154.

#Q3
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
mlb1 <- data.table(dbReadTable(con,'mlb1'))
model<-lm(log(salary)~(teamsal+years+games+atbats+runs+hits+hruns+bavg+bb+sbases+fldperc+so+frstbase+scndbase+shrtstop+thrdbase+outfield+catcher+hispan+black+allstar)^2,data=mlb1)
step(model,k=log(nrow(mlb1)))
BIC(model)
#The best model I found which AIC and BIC is -159.72 and 1467.482.

#Q4
rental <- data.table(dbReadTable(con,'rental'))
#1
rental2 <- pdata.frame(rental,index=c('city','year'))
rental2$pcstu <- rental2$enroll/rental2$pop*100
summary(plm(log(rent)~as.factor(year)+log(pop)+log(avginc)+pcstu,data=rental2,model="pooling"))
#The p-value of y90 and pcstu are both significant in 5% level. The estimate of y90 is  0.2622267 which means
#inflation was 26.22267% over the 10 years, and The estimate of pcstu is 0.0050436 which means 
#1%  increase in student% reasult in 0.5% increase in the rent.
#2
#No, data from y90 and y80 for the same cities are  highly correlated
#3
summary(plm(log(rent)~as.factor(year)+log(pop)+log(avginc)+pcstu,data=rental2,model='fd'))
#1%  increase in student population reasult in 1.1% increase in the rent.
#4
summary(plm(log(rent)~as.factor(year)+log(pop)+log(avginc)+pcstu,data=rental2,model='within'))


#Q5
murder <- data.table(dbReadTable(con,'murder'))
#1
#B1 should be negative and B2 is unknown.
#2
murder2 <- pdata.frame(murder,index=c('id','year'))
summary(plm(mrdrte~as.factor(year)+exec+unem,data= subset(murder2,year==90 | year==93),model='pooling'))
#No, I did not find any evidence for a deterrent effect
#3
summary(plm(mrdrte~as.factor(year)+exec+unem,data= subset(murder2,year==90 | year==93),model='fd'))
#Yes, there is deterrent effect while the  model is estimated by first differences. This means 
#every one more execution increase between 1990-1993, the murder rate decrease 0.10384.
#4
model<-plm(mrdrte~as.factor(year)+exec+unem,data= subset(murder2,year==90 | year==93),model='fd')
coeftest(model,vcov = vcovHC(model))
#5
dt <- data.table(murder2)
tail(dt[year==93][order(exec),.(state,exec),])
#Texas has 3 times more execution than the second most execution state, VA
#6
summary(plm(mrdrte~as.factor(year)+exec+unem,data= subset(subset(murder2,year==90|year==93),state!="TX"),model='fd'))
# The effect become insignificant after dropping Texas from the analysis.
#7
summary(plm(mrdrte~as.factor(year)+exec+unem,data=murder2,model='within'))
#The effect is still insignificant, but it is slightly bigger


#Q6
airfare <- data.table(dbReadTable(con,'airfare'))
#1
pdairfare <- pdata.frame(airfare,index=c('id','year'))
model<- plm(log(fare)~bmktshr+log(dist)+I(log(dist)^2),model='within',effect='time',data=pdairfare)
summary(model)
#If ∆bmktshr = 0.10, the fare will change 3.6%
#2
tidy(model,conf.int=TRUE)
tidyhac(model,conf.int=TRUE)
#Without HAC errors: [0.301,0.419]; With HAC errors: [0.245,0.475]
#3
model <- plm(log(fare)~concen+log(dist)+I(log(dist)^2),model='within',effect='twoways ',data=airfare)
summary(model)
summary(model,vcov=plm::vcovHC(model,method='arellano'))
exp(0.902/2/0.103) 
#It’s quadratically increasing when the dist is greater than 79miles.
#4
#For every 0.1 increase in concentration, there is a 1.7% increase in the price.
#5
#Yes,these are highly correlated with concen.
#6
#Yes, but not very strong.


#Q7
loanapp <- data.table(dbReadTable(con,'loanapp'))
#1
model <- glm(approve~white,family=binomial(),data=loanapp)
summary(model)
predict(model,data.table(white=c(1,0)),type='response')
predict(lm(approve~white,data=loanapp),data.table(white=c(1,0)))
#The predictions are the same
#2
summary(glm(approve~white+hrat+obrat+loanprc+unem+male+married+dep+sch+cosign+
              chist+pubrec+mortlat1+mortlat2+vr,family=binomial(),data=loanapp))
#Yes, There's still  statistically significant evidence of discrimination effect.

#Q8
alcohol <- data.table(dbReadTable(con,'alcohol'))
#1
# fraction of the sample is employed
mean(alcohol$employ)
# fraction of the sample is abused alcohol
mean(alcohol$abuse)
#2
model<-lm (employ~abuse,data=alcohol) 
coeftest(model,vcov.=vcovHC(model))
#Yes, it is  as my expected. abuse is not highly statistically significant.
#3
model <- glm(employ~abuse,family=binomial(),data=alcohol) 
coeftest(model,vcov.=vcovHC(model))
margins(model)
#They are basically similar.
#4
predict(lm(employ~abuse,data=alcohol),data.table(abuse=c(0,1)))
predict(model,data.table(abuse=c(0,1)),type="response")
#they are the same
#5
tidyw(lm(employ~abuse+age+I(age^2)+educ+I(educ^2)+married+famsize+white+northeast+midwest+south+centcity+outercity+qrt1+qrt2+qrt3,data=alcohol))
#Abuse is significant at the 10% level.
#6
model <- glm(employ~abuse+age+I(age^2)+educ+I(educ^2)+married+famsize+white+northeast+midwest+
               south+centcity+outercity+qrt1+qrt2+qrt3,family=binomial(),data=alcohol)
tidyw(model)
margins(model)
#Abuse is significant at the 5% level.Abuse makes the probability of employed decrease 1.938%
#7
#No, it does not make sense to control health when we checking a health effect variable.
#8
#Abuse and unemployment may comes first in either way.If parents are alcoholics, it may
#effect the baby's health and intelligent which can also cause unemployment.


#Q9
fertil1 <- data.table(dbReadTable(con,'fertil1'))
#1
summary(glm(kids~educ+age+I(age^2)+black+east+northcen+west+farm+othrural+town+smcity+as.factor(year),family=poisson(),data=fertil1))
#The coefficient on y82 means a woman’s fertility was about 19.26076% lower in 1982than in 1972.
#2
#Black women had on average 36.03475% more kids than nonblack women
#3
modela<-(glm(kids~educ+age+I(age^2)+black+east+northcen+west+farm+othrural+town+smcity+as.factor(year)
             ,family=poisson(),data=fertil1))
modelb<-predict(modela,type="response")
cor(modelb,fertil1$kids)^2

glance(lm(kids~educ+age+I(age^2)+black+east+northcen+west+farm+othrural+town+smcity+as.factor(year),data=fertil1))
#The linear model R-squared is slightly higher than the Poisson regression, 
#which means the Poisson regression is a good model.
