library(data.table)
library(RSQLite)

##Q1
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
vote1 <- data.table(dbReadTable(con,'vote1'))
summary(vote1)
##1
##when every other factors is fixed, every one percentage of campaign expenditure change, 
##the vote will change B1/100percentage points
##2
##The null hypothesis means when expenditures A and B increase the same amount, voteA's number will not change.
##which means B1+B2=0 and B1=- B2
##3
summary(lm(voteA~log(expendA)+log(expendB)+prtystrA,data=vote1))
##The formula is:
##voteA = 45.08788 + 6.08136*ln[expendA] - 6.61563* ln[expendB] + 0.15201
##Both expendA and expendB  will affect the outcome.
##However, we won't able to test the hypothesis with this alone, 
##because we don't have the Std. Error of B1+B2
##4
##β1 = θ1 − β2
##voteA = B0 + O1 ln[expendA] + B2(ln[expendB] − ln[expendA]) + B3prystrA + u,
summary(lm(voteA~log(expendA)+I(log(expendB)-log(expendA))+prtystrA,data=vote1))
##5
## O1=-0.53427, it is insignificant in 10% level 

##Q2
##1
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
lawsch85 <- data.table(dbReadTable(con,'lawsch85'))
model1 <- lm(log(salary)~LSAT+GPA+log(libvol)+log(cost)+rank,data=lawsch85) 
summary(model1)
##The coefficient on rank is -0.003, so that shows the rank of law schools has no ceteris paribus effect on median starting salary.
##2
model <- lm(log(salary)~log(libvol)+log(cost)+rank,data=lawsch85[!is.na(LSAT)]) 
anova(model,model1)
##Yes，tehy are individually significant for salary.
##3
model1 <- lm(log(salary)~LSAT+GPA+log(libvol)+log(cost)+rank,data=lawsch85)
model2 <- lm(log(salary)~LSAT+GPA+log(libvol)+log(cost)+rank+clsize+faculty,data=lawsch85)
c(AIC(model1),BIC(model1))
c(AIC(model2),BIC(model2))
##From the result of two models, the variables are no need to add in. 
##4
##Such as location, student's family income.



##Q3
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
hprice1 <- data.table(dbReadTable(con,'hprice1'))
##1
summary(lm(log(price)~sqrft+bdrms,data=hprice1))
##θ1=
150*3.794e-04+2.888e-02
##2
##B2=θ1-150B1
##ln[price]= B0 + B1sqrf t + (θ1-150B1)bdrms + u.
##ln[price]= B0 + B1*(sqrf-150bdrms)+θ1bdrmS+U
##3
summary(lm(log(price)~I(sqrft-150*bdrms)+bdrms,data=hprice1))
confint(lm(log(price)~I(sqrft-150*bdrms)+bdrms,data=hprice1))
##confidence interval range is [0.0325803714,0.1390223618]
#Therefore, interval = [3.26%, 13.90%]


##Q4
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
wage2 <- data.table(dbReadTable(con,'wage2'))
##1
##The null hypothesis is B2=B3
##Because a year of general workforce experienc and 
##a year of tenure has the  same effect on ln[wage] 
##2
#B2=O1+B3
##ln[wage] = B0 + B1educ + O1exper + B3(tenure + exper) + u.
summary(lm(log(wage)~educ+exper+I(tenure+exper),data=wage2))
##O1's =0.001954 which is insignificance at 5% level.



##Q5
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
table401 <- data.table(dbReadTable(con,'401ksubs'))
##1
summary(table401)
nrow(table401[fsize==1])
##2
summary(lm(nettfa~inc+age,data=table401[fsize==1]))
##nettfa = −43.03981 + 0.79932inc + 0.84266age + u
##The formula means every one more dollar of income ,
##it will have around 80 cents more in wealth,
##his/her age increase 1 year, there wealth will increase 842.66 in wealth.
##There is no surprises in the slope estimates.
##3
##If we keep inc=0(no income), age=0(just born), then,B0=-43.03981=nettfa
##4
##H0:O1+1=B2
##nettfa  = B0 + B1inc + O1age + age + u,
##nettfa - age= B0 + B1inc + O1age + u,
summary(lm(I(nettfa-age)~inc+age,data=table401[fsize==1]))
##H0: P value=0.0874/2=0.0437
##Therefore, the null hypothesis rejected at 1% level of significance.
##5
##part2:
summary(lm(nettfa~inc+age,data=table401[fsize==1]))
##part5
summary(lm(nettfa~inc,data=table401[fsize==1]))
## On part 2, the income's estimated coefficient is 0.79932 and 
##on part 5the income's estimated coefficient is 0.8207. it is not much different.
##because it has a low correlation between income and age for single-person households 


##Q6
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
kielmc <- data.table(dbReadTable(con,'kielmc'))
##1
##Since the presence of the incinerator depresses housing prices
##so I expect a larger distance a higher price the house is, which means B1>0
summary(lm(log(price)~log(dist),data=kielmc[year==1981]))
##ln[price] = 8.04716 + 0.36488 ln[dist]
##This means every 1% increase in distance the house price with increase 0.36488%
##2
summary(lm(log(price)~log(dist)+log(intst)+log(area)+log(land)+rooms+baths+age,data=kielmc[year==1981]))
##The coefficient of log(dist) drops from 0.36488 to 0.055389.
##it  is not significant, because there are a lot more other factors in the formula
##which makes distance is not as important as part1.
##3
summary(lm(log(price)~log(dist)+log(intst)+I(log(intst)^2)+log(area)+log(land)+rooms+baths+age,data=kielmc[year==1981]))
##After adding [intst]^2 to the formula every factor gets more significant
##[intst]^2 performs a important job in the functional form.
##which means further away from interstate lower the price of the house.
##4
summary(lm(log(price)~log(dist)+I(log(dist)^2)+log(intst)+I(log(intst)^2)+log(area)+log(land)+rooms+baths+age,data=kielmc[year==1981]))
##the coefficient of (dist)^2 is -0.036418 and t value is -0.331,
##it is not significant in the formula.


##Q7
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
wage1 <- data.table(dbReadTable(con,'wage1'))
##1
model<-lm(log(wage)~educ+exper+I(exper^2),data=wage1)
summary(model)
##ln[wage] = 0.1263226 + 0.0906207educ + 0.0409731exper -0.0007121exper2 + u
##2
##Yes, exper^2 is statistically significant at the 1% level.
##3
0.0409731-2*(0.0007121)*5
0.0409731-2*(0.0007121)*20
##4
-0.0409731/(2*(0.0007121))
nrow(wage1[exper>28.7692])
##The experience is 28.7692, 121people have more than 28.7692 years experience.



##Q8
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
wage2 <- data.table(dbReadTable(con,'wage2'))
##1
##holding experience fixed
##log(wage) = B1educ + B3educ × exper=(B1 + B3exper)educ
##log(wage)/educ=(B1 + B3exper)
##2
## H0:B3=0, since more experience should have a positive effect on wages
##Therefore, the appropriate alternative should be H1:B3>0
##3
summary(lm(log(wage)~educ+exper+educ:exper,data=wage2))
## p lower than 0.05. Therefore, The we reject H0 against H1 on 5% level.
##4
##The formula is:
##log(wage) = B0 + O1educ + B2exper + B3(educ × exper − 10educ) + u.
summary(lm(log(wage)~educ+exper+I(educ*exper-10*educ),data=wage2))
##O1=0.076080  and confidence interval is 
0.0760795 - 0.0066151 * 1.96
0.0760795 + 0.0066151 * 1.96
##[0.063, 0.089].



##Q9
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
gpa2 <- data.table(dbReadTable(con,'gpa2'))
##1
summary(lm(sat~hsize+I(hsize^2),data=gpa2))
##sat = 997.981 + 19.814hsize − 2.131(hsize^2) + u
##2
##sat = 997.981 + 19.814hsize − 2.131(hsize^2)
##hsize =
19.814/(2*(2.131))
##since hsize is in 100s. the “optimal" high school size will be 465
##3
## This analysis does not representative all high school seniors, 
##it is only representing the high school senior in the table
##4
summary(lm(log(sat)~hsize+I(hsize^2),data=gpa2))
##hsize =
0.0196029/(2*(0.0020872))
##The optimal high school size is 470. it has 5  people difference with part 2.



##Q10
con <- dbConnect(RSQLite::SQLite(),'wooldridge2.db')
hprice1 <- data.table(dbReadTable(con,'hprice1'))
##1
summary(lm(log(price)~log(lotsize)+log(sqrft)+bdrms,data=hprice1))
##The formula will be:
##ln[price] = −1.29704 + 0.16797 ln[lotsize] + 0.70023 ln[sqrft] + 0.03696bdrms + û
##2
##ln[price]=
−1.29704 + 0.16797 *log(20000) + 0.70023 *log(2500) + 0.03696*4
##ln[price]=5.992921, price=400.574
## the predicted value of price is $400574
##3
##Part 1 model:
summary(lm(log(price)~log(lotsize)+log(sqrft)+bdrms,data=hprice1))
##Part 3 model:
summary(lm(price~lotsize+sqrft+bdrms,data=hprice1))
##Part 3 has the high R-squared=0.6724, which means it is a better model.