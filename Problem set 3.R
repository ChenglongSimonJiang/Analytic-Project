library(DBI)
library(data.table)
library(RSQLite)
library(blscrapeR)
library(ggplot2)
library(dplyr)
library(tseries)
library(lmtest)
library(sandwich)
library(TSA)
library(vars)
library(gtable)
library(grid)
library(forecast)
library(broom)

con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')

#Q1
mlb1 <- data.table(dbReadTable(con,'mlb1'))
#1
#H0: β13=0
#H1: β13≠0
summary(lm(log(salary)~years+gamesyr+bavg+hrunsyr+rbisyr+runsyr+fldperc+allstar+frstbase+scndbase+thrdbase+shrtstop+catcher,data=mlb1))
#log(salary)=11.13+0.058*years+0.0098*gamesyr+0.0005*bavg+0.0191*hrunsyr+0.0018*rbisyr+0.0119*runsyr
#+0.00028*fldperc+0.0063*allstar-0.1328frstbase-0.161*scndbase+0.0145*thrdbase-0.0606*shrtstop+0.2536*catcher
#catcher is significant on 10%,and estimated salary differential is 25.35592%

#2
#H0: β9 = β10 + β11 = β12 = β13=0
m1<-lm(log(salary)~years+gamesyr+bavg+hrunsyr+rbisyr+runsyr+fldperc+allstar+frstbase+scndbase+thrdbase+shrtstop+catcher,data=mlb1)
m2<-lm(log(salary)~years+gamesyr+bavg+hrunsyr+rbisyr+runsyr+fldperc+allstar,data=mlb1)
anova(m2,m1)
#p-value is 0.1168, do not reject on 10%

#3
#The results are inconsistent On 10%  significant level. It is  not indicative positional differences in salaries



#Q2
gpa2 <- data.table(dbReadTable(con,'gpa2'))
#1
#β1< 0 (because with increase in the size of the high school graduating class hsize, the cumulative college grade point average colgpa would decrease.) 
#β3< 0 (because with the increase in the academic percentile in graduating class hsperc, the cumulative college grade point average colgpa would decrease.) 
#β4> 0 (because with the increase in the academic percentile in graduating class hsperc, the cumulative college grade point average colgpa would increase.) 
#β6< 0 (because with the increase in the academic percentile in graduating class hsperc, the cumulative college grade point average colgpa would decrease) 
#β2 and β5 are unsure

#2
summary(lm(colgpa~hsize+I(hsize^2)+hsperc+sat+female+athlete,data=gpa2))
#The differential is around 0.1693 higher than nonathletes. , it is significant at 5% level of significance.

#3
summary(lm(colgpa~hsize+I(hsize^2)+hsperc+female+athlete,data=gpa2))
#The coefficient of athlete is 0.0054<0.17(part2),which because in this model, we do not control for SAT scores, 
#and athletes score lower on average than nonathletes. Part(b) shows that, 
#once we account for SAT differences, athletes do better than nonathletes. Even if we do not control for SAT score, there is no difference.

#4
gpa2$math <- (1-gpa2$female)*gpa2$athlete
gpa2$fath <- gpa2$female*gpa2$athlete
gpa2$mnon <- (1-gpa2$female)*(1-gpa2$athlete)
gpa2$fnon <- gpa2$female*(1-gpa2$athlete)
summary(lm(colgpa~hsize+I(hsize^2)+hsperc+sat+math+fath+mnon,data=gpa2))
#The difference is 0.1751 and is significant only at the 5% level.

#5
summary(lm(colgpa~hsize+I(hsize^2)+hsperc+sat+female+athlete+female:sat,data=gpa2))
#No,  the effect of sat on colgpa does not differ by gender. it is not even significant at 10% level


#Q3
loanapp <- data.table(dbReadTable(con,'loanapp'))
#1
#β1>0 (because a white individual is expected to have a greater probability of getting a loan approved.)

#2
summary(lm(approve~white,data=loanapp))
# white individual has 20.06% higher probability of loan approval and it is significant at the 5% level 

#3
summary(lm(approve~white+hrat+obrat+loanprc+unem+male+married+dep+sch+cosign+chist+pubrec+mortlat1+mortlat2+vr,data=loanapp))
#The coefficient of white is 0.1288, which means 12.88% higher possibility of loan approval. This number is lower than part 2, 
#However, there is still discrimination

#4
summary(lm(approve~white+hrat+obrat+loanprc+unem+male+married+dep+sch+cosign+chist+pubrec+mortlat1+mortlat2+vr+white:obrat,data=loanapp))
#The interaction is significant.

#5
confint(lm(approve~white+hrat+obrat+loanprc+unem+male+married+dep+sch+cosign+chist+pubrec+mortlat1+mortlat2+vr+I(white*(obrat-32)),data=loanapp))
#the probability of approval of being white is around  7.32% to 15.24%


#Q4
hprice1 <- data.table(dbReadTable(con,'hprice1'))
#1
summary(lm(price~lotsize+sqrft+bdrms,data=hprice1))
coeftest(lm(price~lotsize+sqrft+bdrms,data=hprice1),vcov=vcovHC)
#The robust standard error on lotsize is almost twice as large as the homoskedastic-only
#standard error, making lotsize much less significant,The t-statistic on sqrft also falls, but it is still very significant. 
#The variable bdrms actually becomes somewhat more significant but is still barely significant. The most important
#change is in the significance of lotsize. 

#2
summary(lm(log(price)~log(lotsize)+log(sqrft)+bdrms,data=hprice1))
coeftest(lm(log(price)~log(lotsize)+log(sqrft)+bdrms,data=hprice1),vcov=vcovHC)
#for this model, the heteroscedasticity-robust standard error is always slightly greater than the
#corresponding usual standard error, but the differences are relatively small.
#log(lotsize) and log(sqrft) still have very large t-statistics, and the t-statistic on bdrms is not significant at the 5% level

#3
#The use of logarithmic can reduces the heteroskedasticity in some case； 
#the heteroskedasticity-robust errors  are consistently higher than the usual OLS standard error.



#Q5
gpa1 <- data.table(dbReadTable(con,'gpa1'))
#1
model1 <- lm(colGPA~hsGPA+ACT+skipped+PC,data=gpa1)
summary(model1)
coeftest(model1,vcov=vcovHC)
#The equation estimated by OLS is:
#colGPA=1.35651+0.41295hsGPA+0.01334ACT-0.07103skipped+0.12444PC

#2
res <- residuals(model1)
fit <- predict(model1)
model2 <- lm(I(res^2)~fit+I(fit^2))
h <- predict(model2)

#3
summary(h)
summary(lm(colGPA~hsGPA+ACT+skipped+PC,weights=(1/h),data=gpa1))
#The smallest fitted value from the regression in part 2 is about 0.027, while the largest is about 0.165
#There is not much different between coefficient on PC, and the OLS t statistic and WLS t statistic.
#Also, they are statistically significant.

#4
coeftest(lm(colGPA~hsGPA+ACT+skipped+PC,weights=(1/h),data=gpa1),vcov=vcovHC)
#The heteroskedasticity-robust standard errors do not have much different from part 3. it is slightly higher.
#and all variables are statistically significant.


#Q6
#3
setwd("C:/R")
library(readr)
bitcoin <- read_csv("bitcoin.csv", col_types = cols(date = col_date(format = "%m/%d/%Y")))
summary(bitcoin)

#4
p1 <- ggplot(bitcoin,aes(x=date,y=bitcoin)) + geom_line()
p2 <- ggplot(bitcoin,aes(x=date,y=sp500)) + geom_line()
p3 <- ggplot(bitcoin,aes(x=date,y=gold)) + geom_line()
p4 <- ggplot(bitcoin,aes(x=date,y=oil)) + geom_line()
p5 <- ggplot(bitcoin,aes(x=date,y=euro)) + geom_line()
g1 <- ggplotGrob(p1)
g2 <- ggplotGrob(p2)
g3 <- ggplotGrob(p3)
g4 <- ggplotGrob(p4)
g5 <- ggplotGrob(p5)
g <- rbind(g1, g2, g3, g4, g5, size = "first")
g$widths <- unit.pmax(g1$widths, g2$widths, g3$widths, g4$widths,
                      g5$widths)
grid.newpage()
grid.draw(g)

#5
summary(lm(bitcoin~sp500+gold+oil+euro,data=bitcoin))

#6
rep.kpss <- function(series,alpha=0.05,dmax=5){
  diff <- 0
  for(i in 1:dmax){
    suppressWarnings(pval <- kpss.test(series,null="Level")$p.value
    )
    if(pval>=alpha){
      return(c(diff,0,pval))
    }
    suppressWarnings(pval <- kpss.test(series,null="Trend")$p.value
    )
    if(pval>=alpha){
      return(c(diff,1,pval))
    }
    diff <- diff + 1
    series <- diff(series)
  }
  return(NULL)
}
rep.kpss(bitcoin$bitcoin)
rep.kpss(bitcoin$sp500)
rep.kpss(bitcoin$gold)
rep.kpss(bitcoin$oil)
rep.kpss(bitcoin$euro)
n <- nrow(bitcoin)
summary(lm(diff(bitcoin)~diff(sp500)+diff(gold)+diff(oil)+diff(euro)+as.numeric(date)[2:n],data=bitcoin))

#7
model0 <- lm(diff(bitcoin)~diff(sp500)+diff(gold)+diff(oil)+diff(euro)+as.numeric(date)[2:n],data=bitcoin)
coeftest(model0,vcov=NeweyWest(model0,lag=10))

#8
bitcoin <- bitcoin[date>=as.Date('2017-01-03')]
p1 <- ggplot(bitcoin,aes(x=date,y=bitcoin)) + geom_line()
p2 <- ggplot(bitcoin,aes(x=date,y=sp500)) + geom_line()
p3 <- ggplot(bitcoin,aes(x=date,y=gold)) + geom_line()
p4 <- ggplot(bitcoin,aes(x=date,y=oil)) + geom_line()
p5 <- ggplot(bitcoin,aes(x=date,y=euro)) + geom_line()
g1 <- ggplotGrob(p1)
g2 <- ggplotGrob(p2)
g3 <- ggplotGrob(p3)
g4 <- ggplotGrob(p4)
g5 <- ggplotGrob(p5)
g <- rbind(g1, g2, g3, g4, g5, size = "first")
g$widths <- unit.pmax(g1$widths, g2$widths, g3$widths, g4$widths,
                      g5$widths)
grid.newpage()
grid.draw(g)

#9
#ACF
acf(diff(bitcoin$bitcoin))
acf(diff(bitcoin$sp500))
acf(diff(bitcoin$gold))
acf(diff(bitcoin$oil))
acf(diff(bitcoin$euro))
#PACF
pacf(diff(bitcoin$bitcoin))
pacf(diff(bitcoin$sp500))
pacf(diff(bitcoin$gold))
pacf(diff(bitcoin$oil))
pacf(diff(bitcoin$euro))

#10
auto.arima(bitcoin$bitcoin,d=1,max.p=10,max.q=10)

#11
model1 <- stats::arima(bitcoin$bitcoin, c(0,1,0))
forecast1 <- forecast(model1,h=30)
plot(forecast1)

#12
periodogram(diff(bitcoin$bitcoin))

#13
bitcoin$weekday <- as.factor(weekdays(bitcoin$date))
n <- nrow(bitcoin)
summary(lm(diff(bitcoin)~weekday[2:n],data=bitcoin))
bitcoin$res[2:n] <- residuals(lm(diff(bitcoin)~weekday[2:n],data=bitcoin))
periodogram(bitcoin$res[2:n])

#14
diff_jp <- function(x){
  n <- nrow(x)
  return(x[2:n,]-x[1:n-1,])
}
x <- bitcoin %>% dplyr::select(bitcoin,sp500,gold,oil,euro) %>%
  diff_jp
VAR(x,p=1,type="both") %>% AIC
VAR(x,p=2,type="both") %>% AIC
VAR(x,p=3,type="both") %>% AIC
VAR(x,p=4,type="both") %>% AIC
VAR(x,p=5,type="both") %>% AIC
model2 <- VAR(x,p=2,type="both")
summary(model2)

#15
n <- nrow(bitcoin)
forecast2 <- predict(model2,n.ahead=30)$fcst$bitcoin
forecast2 <- forecast2[,1]
forecast2 <- bitcoin$bitcoin[n] + cumsum(forecast2)
cbind(forecast1$mean,forecast2)
bitcoin$bitcoin[n]+cumsum(predict(model2,n.ahead=30)$fcst$bitcoin[,1])