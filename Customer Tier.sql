USE winoasis
GO


DECLARE 
	@vAsofDate			CHAR(15),
	@PlayMonths			INT,
	@NewPlayerMonths	INT,
	@RecentPlayMonths   INT,
	@KickUpDownMonths	INT
	,@WTheo float
	,@WAct  float

Set @WTheo = 0.3
Set @WAct = 0.7

 

--drop table #main , #play3mo, #comps, #freeplay, #work, #recentplay, #kickplay, #top, #output
SET @vAsofDate = '2020-01-16'
SET @PlayMonths = 8
SET @NewPlayerMonths = 4
SET @RecentPlayMonths = 3
SET @KickUpDownMonths = 2


--Create main table
SELECT 
	p.player_id,
	p.LastName,
	p.FirstName, 
	MAX(s.GamingDate) AS LastPlayed, 
	COUNT(DISTINCT s.GamingDate) AS Days, 
	SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay) AS TotalIn, 
	SUM(s.TWin) AS Theo, 
	(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) AS Actual, 
	SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) AS ADT, 
	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) AS ADA, 

	/*addition of fields begin */-----------------------------------------------------------

	case when SUM(s.TWin) > (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) then SUM(s.TWin) else (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) end as GTA,
	@WTheo * (SUM(s.TWin)) + @WAct * ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + SUM(s.JackPot)) )AS WTA,

	case when ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) > SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) then 
	             ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	               + SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) else         SUM(s.TWin)/COUNT(DISTINCT s.GamingDate)  end as GDTA, 
   
    case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (SUM(s.TWin)/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as theopct,
	

	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)))/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as actualpct,

	sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinpit,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinpitpct,

	sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinslot,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinslotpct,

	/*addition of fields end */--------------------------------------------------------------
	    
	SUM(s.PtsEarned) AS Points, 
	a.Address1A Address1, 
	a.Address1B Address2, 
	a.City1 City, 
	a.State1 STATE, 
	a.Zip1 Zip, 
	a.local,
	eff_rank = CASE WHEN ISNULL(t.manualrankid,0) > ISNULL(t.rankid,0) THEN t.manualrankid ELSE t.rankid END,
	a.badaddress1,
	p.CustomFlag2 AS Uni,
	p.CustomFlag4 as UnP,
	p.CustomFlag1 as ShootToWin,
	p.customflag5 AS gogreen,
	p.email,
	p.entrydate,
	newplayer = CASE WHEN p.entrydate >= DATEADD(MONTH, 0-@NewPlayerMonths, @vAsofDate) THEN 'Y' ELSE 'N' END,
	'N' AS unprof,
	'00' AS origtier,
	'00' AS tier,
	' '  as  qt4,  ' '  as qt3,  ' '  as  qt2,  ' '  as  qt1,  ' '  as  qt1a, 
	' '  as  npa1,  ' '  as npa2,  ' '  as  kd1, ' '  as kd2, ' '  as kd3,  ' '  as  ku1, ' '  as ku2, ' '  as ku3, 
	 ' '  as  q2x, ' '  as q3a, ' '  as q3b, ' '  as m1, ' ' as m2, ' ' as m3, ' ' as ama1, ' ' as ama2, ' ' as ama3, ' ' as ama4
INTO 
	#main
FROM 
	playeraddress a (NOLOCK) INNER JOIN
    dbo.CDS_PLAYER p (NOLOCK) ON a.player_id = p.player_id INNER JOIN
    playerrank t (NOLOCK) ON p.Player_ID = t.PlayerID INNER JOIN
    dbo.CDS_STATDAY s (NOLOCK) ON p.Player_ID = s.Meta_ID

WHERE     
	(a.local = 'Y') AND
	(p.MailFlag <> 'N') AND 
	(s.GamingDate BETWEEN DATEADD(MONTH, 0-@PlayMonths, @vAsOfDate) AND @vAsOfDate) AND
	--(t.Template_ID = 4) AND 
	(s.IDType = 'P')AND 
	(s.StatType IN ('PIT', 'SLOT')) AND
	(p.accountstatus_id = 'A')

GROUP BY 
	p.player_id, p.LastName, p.FirstName, a.Address1A, a.Address1B, a.City1, a.State1, a.Zip1,
	a.badaddress1,a.local, p.customflag5, p.email, p.entrydate, p.CustomFlag2, p.CustomFlag4, p.CustomFlag1, 
	CASE WHEN ISNULL(t.manualrankid,0) > ISNULL(t.rankid,0) THEN t.manualrankid ELSE t.rankid END
HAVING 
	SUM(s.twin) >=10
	AND MAX(s.GamingDate) >= DATEADD(Month, 0-@PlayMonths, @vAsofDate)

ORDER BY p.player_id


--select * from #main where player_id = 4854
--select * from cds_player where player_id = 4854
--select * from playeraddress where player_id = 4854


--Recent month play
SELECT 
	s.meta_id,
	COUNT(DISTINCT s.GamingDate) AS Days, 
	SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay) AS TotalIn, 
	SUM(s.TWin) AS Theo, 
	(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) AS Actual, 
	SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) AS ADT, 
	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) AS ADA,

	/*addition of fields begin */-----------------------------------------------------------

	case when SUM(s.TWin) > (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) then SUM(s.TWin) else (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) end as GTA,

	-------------------------WTA--------------------------------------
	@WTheo * (SUM(s.TWin)) + @WAct * ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + SUM(s.JackPot)) )AS WTA,


	case when ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) > SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) then 
	             ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	               + SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) else         SUM(s.TWin)/COUNT(DISTINCT s.GamingDate)  end as GDTA, 
   
    case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (SUM(s.TWin)/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as theopct,
	

	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)))/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as actualpct,

	sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinpit,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinpitpct,

	sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinslot,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinslotpct

	/*addition of fields end */--------------------------------------------------------------
	    
INTO 
	#recentplay
FROM 
	cds_statday s (NOLOCK) 
	INNER JOIN #main m ON s.meta_id = m.player_id
WHERE 
	s.idtype = 'P' 
	AND s.stattype IN ('PIT','SLOT') 
	AND s.gamingdate BETWEEN DATEADD(MONTH,0-@RecentPlayMonths,@vAsofDate) AND @vAsofDate
GROUP BY 
	s.meta_id

--Kick up/down month play
SELECT 
	s.meta_id,
	COUNT(DISTINCT s.GamingDate) AS Days, 
	@KickUpDownMonths noofmonths,
	SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay) AS TotalIn, 
	SUM(s.TWin) AS Theo, 
	(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) AS Actual, 
	SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) AS ADT, 
	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) AS ADA,

	/*addition of fields begin */-----------------------------------------------------------

	case when SUM(s.TWin) > (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) then SUM(s.TWin) else (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)) end as GTA,



	@WTheo * (SUM(s.TWin)) + @WAct * ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + SUM(s.JackPot)) )AS WTA,





	case when ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) > SUM(s.TWin)/COUNT(DISTINCT s.GamingDate) then 
	             ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	               + SUM(s.JackPot))) / COUNT(DISTINCT s.GamingDate) else         SUM(s.TWin)/COUNT(DISTINCT s.GamingDate)  end as GDTA, 

	SUM(s.TWin)/@KickUpDownMonths AS AMT, 
	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / @KickUpDownMonths AS AMA,

	case when ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	+ SUM(s.JackPot))) / @KickUpDownMonths > SUM(s.TWin)/@KickUpDownMonths then 
	             ((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) 
	               + SUM(s.JackPot))) / @KickUpDownMonths else         SUM(s.TWin)/@KickUpDownMonths  end as AMGTA, 

   
    case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (SUM(s.TWin)/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as theopct,
	

	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
    (	((SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)) - (SUM(s.CashOut) + 
	SUM(s.JackPot)))/(SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100 end as actualpct,

	sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinpit,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'PIT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinpitpct,

	sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) as totalinslot,
	
	case when SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)=0 then 0 else 
	(sum(case when stattype = 'SLOT' then s.CashIn + s.FrontIn + s.ChipsIn + s.CreditIn + s.MoneyPlay else 0 end ) / (SUM(s.CashIn) + SUM(s.FrontIn) + SUM(s.ChipsIn) + SUM(s.CreditIn) + SUM(s.MoneyPlay)))*100  end as totalinslotpct

	/*addition of fields end */--------------------------------------------------------------
	    
INTO #kickplay
FROM 
	cds_statday s (NOLOCK) 
	--INNER JOIN #main m ON s.meta_id = m.player_id
WHERE 
	s.idtype = 'P' 
	AND s.stattype IN ('PIT','SLOT') 
	AND s.gamingdate BETWEEN DATEADD(MONTH,0-@KickUpDownMonths,@vAsofDate) AND @vAsofDate
GROUP BY 
	s.meta_id



-- comps redeemed
SELECT 
	DISTINCT 
	r.player_id, 
	/*SUM(ISNULL(r.points,0)) AS Points_Redeemed,
	SUM(ISNULL(r.dollars,0)) AS Cash_Back,
	SUM(ISNULL(r.comp,0)) AS Comp_redeem,*/

	sum(case when r.PrizeType_ID = 'PTRDM' then r.points else 0 end)/500 as Points_Redeemed,
	sum(case when r.PrizeType_ID = 'CASH' then r.dollars else 0 end) as Cash_back,
	sum(case when r.PrizeType_ID = 'COMP' then r.comp else 0 end) as Comp_redeem

INTO 
	#comps
FROM 
	#main p, cds_redemption r
WHERE 
	r.player_id = p.player_id
	AND r.issuegamingdate BETWEEN DATEADD (mm,0-@RecentPlayMonths,@vAsOfDate) AND @vAsOfDate 
	AND r.voiddatetime IS NULL
GROUP BY r.player_id

--Free Play Downloaded--
SELECT 
DISTINCT
	pbt.playerid player_id,
	SUM(0-ISNULL(pbt.amount,0)) AS free_play
INTO 
	#freeplay
FROM 
	eftpromotransaction pbt (NOLOCK) INNER JOIN #main p ON p.player_id = pbt.playerid
WHERE 
	pbt.transactiondatetime BETWEEN DATEADD(hh,2,DATEADD(mm,-@RecentPlayMonths,@vAsofDate)) AND DATEADD(hh,26,@vAsofDate)
	AND pbt.efttype = 7
GROUP BY pbt.playerid
ORDER BY pbt.playerid

--Create #work table 
SELECT 
	m.*,
	ISNULL(p3.days,0) AS days_recent,
	ISNULL(p3.totalin,0) AS totalin_recent,
	ISNULL(p3.theo,0) AS theo_recent,
	ISNULL(p3.actual,0) AS actual_recent,
	ISNULL(p3.adt,0) AS adt_recent,
	ISNULL(p3.ada,0) AS ada_recent,
		
	/*addition of fields begin */-----------------------------------------------------------

	ISNULL(p3.gta,0) AS GTA_recent,
	ISNULL(p3.WTA,0) as WTA_recent,
	ISNULL(p3.gdta,0) AS GDTA_recent,
	ISNULL(p3.theopct,0) AS theopct_recent,
	ISNULL(p3.actualpct,0) AS actualpct_recent,
	ISNULL(p3.totalinpit,0) AS totalinpit_recent,
	ISNULL(p3.totalinpitpct,0) AS totalinpitpct_recent,
	ISNULL(p3.totalinslot,0) AS totalinslot_recent,
	ISNULL(p3.totalinslotpct,0) AS totalinslotpct_recent,
	
	/*addition of fields end */--------------------------------------------------------------

	ISNULL(c.cash_back,0) AS cash_back,
	ISNULL(c.comp_redeem,0) AS comps,
	ISNULL(f.free_play,0) AS freeplay,

	/*addition of fields begin */-----------------------------------------------------------
	ISNULL(k.days,0) AS days_kick,
	ISNULL(k.totalin,0) AS totalin_kick,
	ISNULL(k.theo,0) AS theo_kick,
	ISNULL(k.actual,0) AS actual_kick,
	ISNULL(k.adt,0) AS adt_kick,
	ISNULL(k.ada,0) AS ada_kick,
	ISNULL(k.gta,0) AS GTA_kick,
	ISNULL(k.WTA,0) as WTA_kick,
	ISNULL(k.gdta,0) AS GDTA_kick,
	ISNULL(k.amt,0) AS AMT_kick,
	ISNULL(k.ama,0) AS AMA_kick,
	ISNULL(k.AMGTA,0) AS AMGTA_kick,
	ISNULL(k.theopct,0) AS theopct_kick,
	ISNULL(k.actualpct,0) AS actualpct_kick,
	ISNULL(k.totalinpit,0) AS totalinpit_kick,
	ISNULL(k.totalinpitpct,0) AS totalinpitpct_kick,
	ISNULL(k.totalinslot,0) AS totalinslot_kick,
	ISNULL(k.totalinslotpct,0) AS totalinslotpct_kick

INTO 
	#WORK
FROM 
	#main m LEFT JOIN #recentplay p3 ON p3.meta_id = m.player_id
	 LEFT JOIN #kickplay k on k.meta_id = m.player_id
	LEFT JOIN #comps c ON c.player_id = m.player_id
	LEFT JOIN #freeplay f ON f.player_id = m.player_id

--Update email address
UPDATE #WORK
SET email = '' WHERE email LIKE '%decline%' OR email LIKE '%noemail%' OR email LIKE '%no.com%'OR email NOT LIKE '%@%'

--Set all records to 00 as placeholder
UPDATE #WORK 
SET origtier = '00', tier = '00'

--Set Unprofitable
UPDATE #WORK
SET unprof = 'Y' WHERE theo_recent - freeplay /*- cash_back- comps*/< 0

--Diamond and Rubies get at least tier 4
UPDATE #WORK
SET origtier = 4, qt4 = 'Y'  
WHERE (eff_rank = 2 OR eff_rank = 3)



-- Tier 3 
UPDATE #WORK
SET origtier = 3,  qt3 = 'Y'
WHERE
	(
	(days >=3 AND ADT >=50) OR 
	(days >= 3 AND ADT >=25 AND ADA>= 50) OR
	(Theo >= 750) OR --750
	(Actual >= 250)  --250
--	or (eff_rank = 2)
	OR ( ADA_recent > 75 OR ADT_recent > 75 )
		-----------------------------///////////////////////////-------------------------------------------
	OR (actual_kick>=100)
	OR (AMA_kick >= 200)

	)


-- Tier 2 
UPDATE #WORK
SET origtier = 2, qt2 = 'Y'
WHERE 
	(
	(days >=3 AND ADT >= 75) OR 
	(days >=3 AND ADT >= 50 AND ADA >= 75) OR 
	(days >=2 AND ADA >=100) OR 
	(Theo >= 2500) OR --2500
	(Actual >= 1750) --1750
	--or (eff_rank = 3)
	OR ( ADA_recent > 150 OR ADT_recent > 150 )
		-----------------------------///////////////////////////-------------------------------------------

	OR (ada_kick >= 100 and totalin_kick >=1000)
	)


-- Tier 1 
UPDATE #WORK 
SET origtier = 1, qt1 = 'Y' 
WHERE 
	(
	(days >=25 AND (ADT>=120 OR ADA >= 75)) OR
	(days >=10 AND (ADT >=150 OR ADA >=100)) OR
	(days >=3 AND ADT >=300) OR
	(days >=2 AND ADA >=200) OR
	(Theo >= 8000) OR  --7000
	(Actual >= 4000)  --4000
	OR ( ADA_recent > 225 OR ADT_recent > 300 )
	-----------------------------///////////////////////////-------------------------------------------
	OR (ada_kick >= 200 and adt_kick >= 150)
	OR (ada_kick >= 100 and totalin_kick >=50000)
	)
	AND	Uni <> 'Y'
	AND UnP <> 'Y'
	AND ShootToWin <> 'Y'


--Tier 1A 
--select * from #top 
--drop table #top
SELECT 
	w.player_id, gta_recent
INTO #Top
FROM 
	#WORK w
WHERE 
	--w.GTA_kick >= 4000 
	(w.WTA_kick >= 3000 or w.actual_kick>= 3000 or w.theo_kick >= 7000)
	and w.Uni <> 'Y'
	AND w.UnP <> 'Y'
	AND w.ShootToWin <> 'Y'
	

UPDATE #WORK 
SET origtier = '1A', qt1a = 'Y' 
WHERE 
	Player_id in 
	(SELECT Player_id FROM #TOP )


UPDATE #WORK
SET tier = origtier


/*new kickdowns */--------------------------------------------------------------

UPDATE #WORK
SET tier = 2, kd1 = 'Y'
where tier = 1 
 and GDTA_kick < 50
 and days_kick >=1
 and origtier <> '1A'


UPDATE #WORK
SET tier = 2, kd1 = 'Y'
where tier = 1 
 and amgta_kick < 200 
 and amgta_kick <> 0
 and gdta_kick < 100
 and origtier <> '1A'


UPDATE #WORK
SET tier = 3, kd2 = 'Y'
where tier = 2  
 and GDTA_kick < 40 
 and days_kick >=1
 and origtier <> '1A'


UPDATE #WORK
SET tier = 4, kd3 = 'Y'
where tier = 3 
 and GDTA_kick < 20
 and days_kick >=1 
 and origtier <> '1A'
  --make sure player is only kicked down no more than twice
 and not (kd2 = 'Y' and kd1 = 'Y')
 
/*new kickups */--------------------------------------------------------------

UPDATE #WORK
SET tier = 3, ku1 = 'Y'
where tier = 4  
 and GDTA_kick > 50 and GDTA_kick <= 99
 and days_kick >=2
 and origtier <> '1A'


UPDATE #WORK
SET tier = 2, ku2 = 'Y'
where tier = 3  
 and GDTA_kick > 99 and GDTA_kick <= 199
 and days_kick >=2
 and origtier <> '1A'


UPDATE #WORK
SET tier = 1, ku3 = 'Y'
where tier = 2  
 and GDTA_kick > 199
 and days_kick >=2
 and origtier <> '1A'


--ama kicks
UPDATE #WORK
SET tier = '1', ama1 = 'Y'
where ama_kick >= 800
  and origtier <> '1A'

UPDATE #WORK
SET tier = '2', ama2 = 'Y'
where ama_kick >= 500 
  and ama_kick < 800
  and origtier <> '1A'
  and tier <> '1'

UPDATE #WORK
SET tier = '3', ama3 = 'Y'
where ama_kick >=300
  and ama_kick < 500
  and origtier <> '1A'
  and tier not in ('1','2')

UPDATE #WORK
SET tier = '3B', ama4 = 'Y'
where ama_kick >=200
  and ama_kick < 300
  and origtier <> '1A'
  and tier not in ('1','2')
  
/*mailing exeptions */--------------------------------------------------------------
UPDATE #WORK
SET tier = me.break_tier, m1 = 'Y'
FROM 
	#WORK w, kw_mktg_mailers_exceptions me
WHERE  me.break_action = 'D' AND me.player_id = w.Player_ID
and tier <> '1A' 
and tier <> '3B'
and cast(tier as int) - break_tier < 0

UPDATE #WORK
SET tier = me.break_tier, m1 = 'Y'
FROM 
	#WORK w, kw_mktg_mailers_exceptions me
WHERE  me.break_action = 'D' AND me.player_id = w.Player_ID
and tier <> '1A' 
and tier = '3B'
and break_tier > 3

 
--example:  if I qualify as 2, but am on the list to downgrade to 3, 2-3 = -1, <0 true, keep 3
--example:  if I qualify as 4, but am on the list to downgrade to 3, 4-3 = 1, <0 false, keep 4


UPDATE #WORK
SET tier = me.break_tier, m2 = 'Y' 
FROM #WORK w, kw_mktg_mailers_exceptions me
WHERE me.break_action = 'U' AND me.player_id = w.player_id 
and tier <> '1A'
and tier <> '3B'
and (cast(tier as int) >= break_tier)

UPDATE #WORK
SET tier = me.break_tier, m2 = 'Y' 
FROM #WORK w, kw_mktg_mailers_exceptions me
WHERE me.break_action = 'U' AND me.player_id = w.player_id 
and tier <> '1A'
and tier = '3B'
and break_tier <= 3


--example:  if I qualify as a 1, but am on the list to upgrade to 2, 1>=2 false, keep 1
--example:  if I quality as a 2, but am on the list to upgrade to 1, 2>=1 true, keep 1


UPDATE #WORK
SET tier = 'NO', m3 = 'Y'
FROM #WORK w, kw_mktg_mailers_exceptions me
WHERE me.break_action = 'X' AND me.player_id = w.Player_ID




/*one day GDTA rule */--------------------------------------------------------------
UPDATE #WORK
SET tier = '2', q2x = 'Y'  
where GDTA_kick > 125 
 and days_kick = 1
 and tier in ('00','3','4')

/*Split Tier 3 into 3A and 3B */--------------------------------------------------------------
UPDATE #WORK
SET tier = '3A', q3a = 'Y'
where ((GDTA_kick > 25) 
	-----------------------------///////////////////////////-------------------------------------------
	OR (AMA_kick >= 300)
)
 and tier = '3'
 
UPDATE #WORK
SET tier = '3B', q3b = 'Y'  
where tier = '3'
and tier <> '1A'

/*current table */--------------------------------------------------------------

DROP TABLE kw_current_trifold
SELECT * INTO kw_current_trifold
FROM #WORK 


/*get output */--------------------------------------------------------------

SELECT 
	w.tier,
	 COUNT(*) AS tiercnt
	, SUM(CASE WHEN unprof = 'Y' THEN 1 ELSE 0 END) AS unprofs 
FROM 
	#WORK w
WHERE w.tier <> '0' AND w.tier <> '00' 
GROUP BY w.tier
ORDER BY w.tier


SELECT 
w.player_id,
w.LastName,
w.FirstName,
w.LastPlayed,
w.Days,
w.TotalIn, 
w.Theo,
w.Actual,
w.ADT,
w.ADA ,
w.origtier	AS OrigTier,
w.tier AS Tier,
/*addition of fields begin */
w.GTA,
w.WTA,
w.GDTA,
w.theopct,
w.actualpct,
w.totalinpitpct,
w.totalinslotpct,
/*addition of fields end */
w.Days_recent,
w.Totalin_recent,
w.Theo_recent,
w.Actual_recent,
w.adt_recent,
w.ada_recent,
/*addition of fields begin */
w.GTA_recent,
w.WTA_Recent,
w.GDTA_recent,
w.theopct_recent,
w.actualpct_recent,
w.totalinpitpct_recent,
w.totalinslotpct_recent,
/*addition of fields end */
w.Cash_back,
w.Comps,
w.Freeplay,
/*addition of fields begin */
w.Days_kick,
w.Totalin_kick,
w.Theo_kick,
w.Actual_kick,
w.adt_kick,
w.ada_kick,
w.GTA_kick,
w.WTA_kick,
w.GDTA_kick,
w.AMT_kick,
w.AMA_kick,
w.AMGTA_kick,
w.theopct_kick,
w.actualpct_kick,
w.totalinpitpct_kick,
w.totalinslotpct_kick

INTO #OUTPUT 
FROM
	#Work w 
WHERE tier <> '00' and tier <> 'NO'



SELECT * FROM #Output ORDER BY tier,player_id

SELECT 'T1A - $50'
SELECT * FROM #Output WHERE tier = '1A' ORDER BY 
player_id
SELECT 'T1 - $25'
SELECT * FROM #Output WHERE tier = '1' ORDER BY 
player_id
SELECT 'T2 - $10'
SELECT * FROM #Output WHERE tier = '2' ORDER BY  
player_id
SELECT 'T2X'
SELECT * FROM #Output WHERE tier = '2X' ORDER BY 
 player_id
SELECT 'T3A'
SELECT * FROM #Output WHERE tier = '3A' ORDER BY 
 player_id
SELECT 'T3B'

SELECT * FROM #Output WHERE tier = '3B' ORDER BY 
 player_id
SELECT 'T4 - Point Multiplier'
SELECT * FROM #Output WHERE tier = '4' ORDER BY 
 player_id
SELECT 'T1A - group PIDs'
SELECT player_id FROM #Output WHERE tier = '1A' ORDER BY player_id
SELECT 'T1 - group PIDs'
SELECT player_id FROM #Output WHERE tier = '1' ORDER BY player_id
SELECT 'T2 - group PIDs'
SELECT player_id FROM #Output WHERE tier = '2' ORDER BY player_id
SELECT 'T2X - group PIDs'
SELECT player_id FROM #Output WHERE tier = '2X' ORDER BY player_id
SELECT 'T3A - group PIDs'
SELECT player_id FROM #Output WHERE tier = '3A' ORDER BY player_id
SELECT 'T3B - group PIDs'
SELECT player_id FROM #Output WHERE tier = '3B' ORDER BY player_id
SELECT 'T4 - group PIDs'
SELECT player_id FROM #Output WHERE tier = '4' ORDER BY player_id



DROP TABLE #main, #recentplay, #comps, #freeplay, #WORK, #top, #kickplay, #OUTPUT


