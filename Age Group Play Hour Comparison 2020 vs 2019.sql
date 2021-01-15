DECLARE @year date
        ,@yearstart date

SELECT @year = '2020-06-17'
SELECT @yearstart = '2020-06-04'

select 
    --   a.gamingdate,
	   --'',
	 --  slotnumber,
	   case when datepart(yyyy,@year) - datepart(yyyy,p.birthday) < 21 then 'Under 21'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 21 and 24 then '21-24'
	        when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 25 and 34 then '25-34'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 35 and 44 then '35-44'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 45 and 54 then '45-54'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 55 and 64 then '55-64'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 65 and 74 then '65-74'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 75 and 84 then '75-84'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 85 and 94 then '85-94'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) >= 95 then '95+'
                            else 'Unknown' end as [Age Group],
							count(DISTINCT player_id) as [Player Count],
						--	'' as [Count%],
	--   datepart(hh,starttime) starthour,
       sum(cashin + frontin + chipsin + creditin + MoneyPlay) [Total In],
	  -- '' as [Total In %],
	   	(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
			SUM(JackPot)) AS Actual,
		    sum(twin) as [Theo Win],
			sum(promoplay) as [Freeplay],
       sum(cashout) as [Total Cash Out],
     --  sum(jackpot) total_jackpots,
       sum(ptsearned) as [Total Points Earned],
	   sum(dollarsearned) as [Total Dollars Earned],
       sum(promoptsearned) [Promo Points Earned],
       sum(promodollarsearned) [Points $ Earned],
       sum(compearned) as [Comp Earned],
	   sum(jackpot) as [Jackpots]
from CDS_StatDay a (nolock)    
 inner join cds_player p (nolock)  on a.PlayerID = p.Player_ID
where 
idtype = 'P' 
  and stattype in ( 'SLOT', 'PIT')
  --and datepart(yyyy,gamingdate)='2017'
  --and datepart(mm,gamingdate) in (4,5,6)
  and (gamingdate between @yearstart and @year)
  AND p.Birthday <> '1900-01-01'
    AND p.LastName <> '%Unknown%'
	and a.PlayerID not in (500000,512872)
--  and slotnumber in (40883,40884,40885,40886,40887,40888,40889)
group by  case when datepart(yyyy,@year) - datepart(yyyy,p.birthday) < 21 then 'Under 21'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 21 and 24 then '21-24'
	        when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 25 and 34 then '25-34'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 35 and 44 then '35-44'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 45 and 54 then '45-54'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 55 and 64 then '55-64'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 65 and 74 then '65-74'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 75 and 84 then '75-84'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) between 85 and 94 then '85-94'
            when datepart(yyyy,@year) - datepart(yyyy,p.birthday) >= 95 then '95+'
                            else 'Unknown' end  
order by [Age Group]
