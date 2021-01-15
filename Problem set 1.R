library(DBI)
library(data.table)
library(RSQLite)
library(blscrapeR)
library(ggplot2)

con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')


#Q1
wage1 <- data.table(dbReadTable(con,'wage1'))

#1
mean(wage1$educ)## The average eduaction level 
min(wage1$educ)## The lowest years of eductaion level 
max(wage1$educ)## The highest years of eductaion level 

#2
mean(wage1$wage)##The average hourly wage, It seems low.

#3
df <- bls_api("CUSR0000SA0")
head(df, 5)
da <- inflation_adjust(1976)
tail(da)
dc <- inflation_adjust(2010)
tail(dc)
dc <- data.table(dc)
head(dc)

#4
mean(dc$avg_cpi)## average hourly wage in 2010

#5
sum(wage1$female == 1)##women
sum(wage1$female == 0)##men



#Q2
meap01 <- data.table(dbReadTable(con,'meap01'))

#1.
min(meap01$math4)## The largest values of math4
max(meap01$math4)## The smallest values of math4
#Does the range make sense? 
#The largest and smallest values are the highest and lowest score, so this result does not make sense.

#2
#Assume the pass score for math is 60
sum(meap01$math4==100)
sum(meap01$math4>=0)##Amount of all samples
38/1823
##What percentage is this of the total samples

#3
sum(meap01$math4==50)##Math pass rates of exactly 50%

#4
summary(meap01$math4)
summary(meap01$read4)
#The mean and median scores of math both are higher than read, so read test is harder to pass.

#5
cor(meap01$math4, meap01$read4)##The correlation between math4 and read4

#6
mean(meap01$exppp)##Average of exppp
sd(meap01$exppp)##Standard deviation of exppp

#7
(6000-5500)/5500##What percentage does School A's spending exceed School B's
log_percentage<-100*(log(6000)-log(5500))
summary(log_percentage)
(0.091-0.087)/0.087
#Approximation percentage difference



#Q3
r401k <- data.table(dbReadTable(con,'401k'))

#1
mean(r401k$prate)
mean(r401k$mrate)

#2
r401kreg <- lm(data = r401k, prate~mrate)
summary(r401kreg)

#3
#the intercept means when mrate=0, the participaton rate will still be 83.07%. 
#The coefficient means that whenever the match rate increase 1, the paticipation rate will increase 5.86%

#4
#since y=ax+b, when mrate=3.5, prate=
83.0755 + 5.6*(3.5)
# it is not a reasonable prediction since the maximum of prate is 100
#this is caused by a dependent variable are bounded, the regression model may produce an unreasonable number for the independent variable

#5
#the mrate explains around 0.075 of prate.



#Q4
ceosal2 <- data.table(dbReadTable(con,'ceosal2'))

#1
mean(ceosal2$salary)#average salary
mean(ceosal2$ceoten)#average tenure

#2
nrow(filter(ceosal2, ceoten==0))# first year as CEO 
max(ceosal2$ceoten)#e longest tenure as a CEO

#3
summary(lm(log(salary) ~ ceoten, data=ceosal2))
# the (approximate) predicted percentage increase in salary is  given one more year as a CEO




#Q5
wage2 <- data.table(dbReadTable(con,'wage2'))

#1
mean(wage2$wage)#average salary
mean(wage2$IQ)#average IQ 
sd(wage2$IQ)#standard deviation of IQ

#2
summary(lm(data = wage2, wage~IQ))# simple regression model
8.30*15#the predicted increase in wage for an increase in IQ of 15 points is
#R-squared=0.09554
#IQ can explain 9.5% variation in wage

#3
summary(lm(data = wage2, log(wage)~IQ))#model
15*0.0088
#IQ increases by 15 points, 13.2% increase in predicted wage



#Q6
meap93 <- data.table(dbReadTable(con,'meap93'))

#1
cor(meap93$math10, meap93$expend)##The correlation between math10 pass rate and expend.
#The expend with math pass rate have positive correlation relationship, but it's not strong.

#2
#B1 is a log, and present as percentage form, math10 also have a percentage form. so B1*(10/100)

#3
summary(lm(data = meap93, math10~log(expend)))

#4
summary(lm(data = meap93, math10~log(expend)))##line model between math10 and expend
#This relationship means when math10 increases 11.164%, the expend will increase by 100%.
(0.11164*0.1)*100
#If give a 10% increase in spending,the math10 will increase by 1.1164%.

#5
summary(meap93$math10)
#In this data set,this is not much a worry since except math10 there also have two other variables improves. That will be a balance. 



#Q7
hprice1 <- data.table(dbReadTable(con,'hprice1'))

#1
summary( lm(price ~ sqrft + bdrms, data=hprice1))
#Equation: price=-19.315+0.12844(sqrft)+15.19819(bdrms)+u

#2 
#The estimated increase in price when holding square footage constant and a house with one more bedroom is:
15.19819*1000


#3
# the estimated increase in price for a house with an additional bedroom that is 140 square feet in size
(0.12844 * 140 + 15.19819 * 1) *1000




#Q8
ceosal2 <- data.table(dbReadTable(con,'ceosal2'))

#1
summary(lm(log(salary)~log(sales)+log(mktval), data=ceosal2))
#Equation:
#log(salary)=4.62092+0.16213(sales)+0.10671(mktval)

#2
summary(lm(log(salary)~log(sales)+log(mktval)+profits, data=ceosal2))
#profits cannot be included in logarithmic form, because log of a negative value because it is undefined
#I would not say that these firm performance variables explain most of the variation in CEO salaries
#because R-squared is 0.2993 and there are around 70% of salary are unexplained

#3
summary(lm(log(salary)~log(sales)+log(mktval)+profits+ceoten, data=ceosal2))
#log(salary) = 4.558 + 0.1622log(sales) + 0.1018log(mktval) + 0.00prof its +0.01168ceoten 
0.01168*100
#the estimated percentage return for another year of CEO tenure is 1.168%  holding other factors fixed

#4
cor(log(ceosal2$mktval),ceosal2$profits)
#The sample correlation coefficient between the variables log(mktval) and profits is 77.68976%.they are highly correlated.
#both of these variable should be included in the equation in order to avoid omitted-variable bias
#4 
#R-squared=0.6319. So 63.19% of the variation in price is explained by square footage and number of bedrooms

#5
# the predicted selling price for this house from the OLS regression line is:
(-19.315 + 0.12844 * 2438 + 15.19819 * 4)*1000

#6
#the residual for this house is:
(300-(-19.32 + 0.12844 * 2438 + 15.19819 * 4))*1000
#it does suggest that the buyer underpaid for the house






#Q9
attend <- data.table(dbReadTable(con,'attend'))

#1
summary(attend$atndrte)##Min6.25; Max100; Mean81.71
summary(attend$priGPA)##Min0.857; Max3.930; Mean2.587
summary(attend$ACT)##Min13; Max32; Mean22.51

#2
#priGPA/termGPA?
summary(lm(data = attend, atndrte~priGPA+ACT))
#In equation form, atndrte=75.7+17.261priGPA-1.717ACT
#In this data set I believe this have not a useful meaning.  
#The attend rate will be 75.7% if the priGPA and ACT both are 0 that have not universal because almost no student will have priGPA=0, and ACT=0.

#3
#When ACT score goes up, the attend rate goes down. That make me surprises.

#4
priGPA<-3.65
ACT<-20
atndrte<-75.7+17.261*priGPA-1.717*ACT
atndrte
#There no student with these values.

#5
priGPA_a<-3.1
ACT_a<-21
atndrte_a<-75.7+17.261*priGPA_a-1.717*ACT_a
priGPA_b<-2.1
ACT_b<-26
atndrte_b<-75.7+17.261*priGPA_b-1.717*ACT_b
atndrte_a-atndrte_b



#Q10
htv <- data.table(dbReadTable(con,'htv'))

#1
#The educ range is:
max(htv$educ)-min(htv$educ)
#percentage of men completed 12th grade is but no higher grade:
mean(htv$educ==12)
#men have, on average, higher levels of education than their parents:
summary(htv[,.(educ,motheduc,fatheduc)])

#2
summary(lm(educ~motheduc+fatheduc,data=htv))
#educ= 6.96435 + 0.30420motheduc+ 0.19029fatheduc
#The sample variation in educ is explained by parents' education is:
#R-squared:  0.2493*100%=24.93%
#Every one year of motheduc increase 1, their sone get 0.30420*100=30.42% more year of education

#3
summary(lm(educ~motheduc+fatheduc+abil,data=htv))
#Educ=  8.44869 + 0.18913motheduc+ 0.11109fatheduc+ 0.50248abil
#R-squared increase from 0.2493 to 0.4275. Ability does help to explain variations in education

#4
abil.sq <- htv$abil^2
model<-lm(educ~motheduc+fatheduc+abil+abil.sq,data=htv)
summary(model)
#The equation is:
#educ=8.240226+0.190126motheduc+0.108939fatheduc+0.401462abil+0.050599abil^2
# the value of abil where educ is minimized which is 0.
#0=0+0+0+0.401462abil+0.050599abil^2
#0=0.401462+0.050599abil*2=
abil.min<--0.401462/0.050599/2
abil.min

#5
mean(htv$abil<=abil.min)
#only 1.2% of men in the sample have ability less than -3.967094.
#It is important, because only a small amount of men have the ability level between -3.967094 to 0.

#6
htv2 <- htv
htv2$motheduc <- as.double(htv2$motheduc)
htv2$fatheduc <- as.double(htv2$fatheduc)
htv2$motheduc <- 12.18
htv2$fatheduc <- 12.45
ggplot(htv, aes(x=abil,y=educ))+geom_point()+geom_line(aes(y=predict(model,htv2)),color="Red")+scale_x_continuous('Ability measure')+scale_y_continuous('Years of education')

