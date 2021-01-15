declare @begdate date,
		@enddate date,
		@begyear date,
		@endyear date


select	@begdate='2020-06-04'
select	@enddate='2020-07-21'
select	@begyear='2020-01-01'
select	@endyear='2020-12-31'

-----------------------current-----------------------------
select top 150 PlayerID, FirstName,LastName,City1,State1,sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn)as [slot Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [slot Actual],
				sum(twin) as [slot Theo Win],
				--sum(promoplay) as [slot Freeplay]
					   rank () over(ORDER BY (SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) DESC) AS top_player
				into #Slotcurrent
				from CDS_StatDetail inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
									inner join PlayerAddress on CDS_StatDetail.PlayerID=PlayerAddress.Player_ID
				where GamingDate between @begdate and @enddate 
				and StatType='slot'and FirstName not like'%Black Jack%'
				group by PlayerID ,FirstName,LastName, City1,State1

-------------------------Year-------------------------------------
select PlayerID, isnull(sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn),0)as [YTD slot Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [YTD slot Actual],
				sum(twin) as [YTD slot Theo Win]
				--sum(promoplay) as [YTD slot Freeplay],
				into #Slotytd
				from CDS_StatDetail
				 --inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
				where GamingDate between @begyear and @endyear
				and StatType='slot'
				group by PlayerID 

--------------------------LTD------------------------------------------		
select PlayerID,sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn)as [ LTD slot Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [LTD slot Actual],
				sum(twin) as [LTD slot Theo Win]
				--sum(promoplay) as [LTD slot Freeplay] 
				into #Slotltd
				from CDS_StatDetail 
				--inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
				where StatType='slot'
				group by PlayerID 

select 'slot'
select * from #Slotcurrent left join #Slotytd on #Slotcurrent.PlayerID=#Slotytd.PlayerID 
						   left join #Slotltd on #Slotcurrent.PlayerID=#Slotltd.PlayerID 
							order by #Slotcurrent.top_player

--------------------------------------------Pit---------------------------------------------

-----------------------current-----------------------------
select top 150 PlayerID, FirstName,LastName,City1,State1,sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn)as [Pit Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [Pit Actual],
				sum(twin) as [Pit Theo Win],
				--sum(promoplay) as [slot Freeplay]
					   rank () over(ORDER BY (SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) DESC) AS top_player
				into #Pitcurrent
				from CDS_StatDetail inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
									inner join PlayerAddress on CDS_StatDetail.PlayerID=PlayerAddress.Player_ID
				where GamingDate between @begdate and @enddate 
				and StatType='Pit'and FirstName not like'%Black Jack%'
				group by PlayerID ,FirstName,LastName, City1,State1

-------------------------Year-------------------------------------
select PlayerID, isnull(sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn),0)as [YTD Pit Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [YTD Pit Actual],
				sum(twin) as [YTD Pit Theo Win]
				--sum(promoplay) as [YTD slot Freeplay],
				into #Pitytd
				from CDS_StatDetail
				 --inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
				where GamingDate between @begyear and @endyear
				and StatType='Pit'
				group by PlayerID 

--------------------------LTD------------------------------------------		
select PlayerID,sum(FrontIn+MoneyPlay+CashIn+ChipsIn+CreditIn)as [ LTD Pit Total in],
				(SUM(CashIn) + SUM(FrontIn) + SUM(ChipsIn) + SUM(CreditIn) + SUM(MoneyPlay)) - (SUM(CashOut) + 
				SUM(JackPot)) AS [LTD Pit Actual],
				sum(twin) as [LTD Pit Theo Win]
				--sum(promoplay) as [LTD slot Freeplay] 
				into #Pitltd
				from CDS_StatDetail 
				--inner join CDS_Player on CDS_StatDetail.PlayerID=CDS_Player.Player_ID
				where StatType='Pit'
				group by PlayerID 

select 'Pit'
select * from #Pitcurrent left join #Pitytd on #Pitcurrent.PlayerID=#Pitytd.PlayerID 
						   left join #Pitltd on #Pitcurrent.PlayerID=#Pitltd.PlayerID 
							order by #Pitcurrent.top_player




drop table #Slotcurrent
drop table #Slotytd
drop table #Slotltd
drop table #Pitcurrent
drop table #pitytd
drop table #Pitltd