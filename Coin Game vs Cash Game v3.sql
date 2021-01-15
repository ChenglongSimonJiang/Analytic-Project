

--get slot and location data
--drop table #location
select c.slotmast_id, c.slotnumber, c.revision, min(rh.auditdate) begindt, max(rh.auditdate) enddt, min(onfloor) onfloordt, c.section, i.location, i.sublocation, c.currentrevision, c.description, c.par, calc_id, progpc, lease_id, denomination
into #location 
from cds_slotmast c (nolock)
	  inner join bb_revisionhistory rh (nolock) on c.slotmast_id = rh.slotmast_id and c.Revision = rh.revision
	  left join custom_location_information i on c.section = i.section 
group by c.slotmast_id, c.slotnumber, c.revision, c.section, i.location, i.sublocation, c.currentrevision, c.description, c.par, calc_id, progpc, lease_id, denomination

--get slot data for date range
--drop table #details
SELECT
 r.slotmast_id, 
 cast(r.auditdate as date) auditdate,
 ISNULL(r.ElecCoinIn, 0)                       ElecCoinIn,
 ISNULL(r.Jackpots +r.ActualAttPaidProg +r.ActualAttPaidCC +r.ActualAttPaidExtBonus, 0) Jackpots,
 ISNULL(r.JPPromo, 0)                            JPPromo,
 ISNULL(r.ManualTicketOut, 0)                    ManualTicketOut,
 ISNULL(r.Fills, 0)                              Fills,
 --ISNULL((r.ElecCoinIn * b.Par) / 100, 0)        Composite,
 ISNULL(r.ProgCoinIn, 0)                         ProgCoinIn,
 ISNULL(r.DaysOnLine, 0)                         DaysOnLine,
 ISNULL(rpbt.CashDownElec, 0)                    CashDownElec,
 ISNULL(rpbt.CashDownMan, 0)                     CashDownMan,
 ISNULL(rpbt.CashDownVar, 0)                     CashDownVar,
 ISNULL(rpbt.CashUpElec, 0)                      CashUpElec,
 ISNULL(rpbt.CashUpMan, 0)                       CashUpMan,
 ISNULL(rpbt.CashUpVar, 0)                       CashUpVar,
 ISNULL(rpbt.PtsCashDownElec, 0)                 PtsCashDownElec,
 ISNULL(rpbt.PtsCashDownMan, 0)                  PtsCashDownMan,
 ISNULL(rpbt.PtsCashDownVar, 0)                  PtsCashDownVar,
 ISNULL(rpbt.PtsCashUpElec, 0)                   PtsCashUpElec,
 ISNULL(rpbt.PtsCashUpMan, 0)                    PtsCashUpMan,
 ISNULL(rpbt.PtsCashUpVar, 0)                    PtsCashUpVar,
 ISNULL(rpbt.PromoDownElec, 0)                   PromoDownElec,
 ISNULL(rpbt.PromoDownMan, 0)                    PromoDownMan,
 ISNULL(rpbt.PromoDownVar, 0)                    PromoDownVar,
 ISNULL(r.ElecPromoCouponDrop, 0)                ElecProCouDrop,
 ISNULL(r.ManualPromoCouponDrop, 0)              ManProCouDrop,
 ISNULL(r.PromoCouponDropVar, 0)                 ProCouDropVar,
 ISNULL(r.ElecPromoCouponDrop, 0) + ISNULL(r.PromoCouponDropVar, 0) PromoCoupons,
 ISNULL(r.ActualBillIn, 0)                       ActualBillIn,
 ISNULL(r.MeteredBillIn, 0)                      MeteredBillIn,
 ISNULL(r.BillInVar, 0)                          BillInVar,
 ISNULL(r.ScaleDrop, 0)                          ScaleDrop,
 ISNULL(r.ElecCoinDrop, 0)                       ElecCoinDrop,
 ISNULL(r.CoinDropVar, 0)                        CoinDropVar,
 ISNULL(r.MeteredVoucherIn, 0)                   MeteredVoucherIn,
 ISNULL(r.VoucherInVar, 0)                       VoucherInVar,
 ISNULL(r.ActualVoucherIn, 0)                    ActualVoucherIn,
 ISNULL(r.ElecCoinDrop, 0) + ISNULL(r.CoinDropVar, 0)  + ISNULL(r.MeteredBillIn, 0) + ISNULL(r.BillInVar, 0)  + ISNULL(r.MeteredVoucherIn, 0) + ISNULL(r.VoucherInVar, 0)  GrossDrop,
 ISNULL(rpbt.CashDownElec, 0) + ISNULL(rpbt.CashDownVar, 0) + ISNULL(rpbt.PtsCashDownElec, 0) + ISNULL(rpbt.PtsCashDownVar, 0)  - (ISNULL(rpbt.CashUpElec, 0) + ISNULL(rpbt.CashUpVar, 0) + ISNULL(rpbt.PtsCashUpElec, 0) + ISNULL(rpbt.PtsCashUpVar, 0)) NetCashablePBT,
 (ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(r.JPPromo, 0)) PromoPBT,
 ISNULL(rpbt.NCEPOutMetered, 0)	NCEPOutMetered,
 ISNULL(rpbt.NCEPOutSystem, 0)  NCEPOutSystem,
 ISNULL(rpbt.NCEPOutVar, 0)    NCEPOutVar          
into #details
FROM dbo.bb_Revenue r (nolock)
   LEFT JOIN dbo.bb_Revenue_PBT rpbt (nolock) on r.AuditDate = rpbt.AuditDate and r.Period_Id = rpbt.Period_Id and r.SlotMast_Id = rpbt.SlotMast_ID
WHERE r.Period_Id = 4
  and r.AuditDate between '06/04/2020' and '07/14/2020'
 -- and (r.eleccoinin >= 0  or manualticketout >0 or PromoDownElec >0 or PromoDownVar >0 or NCEPOutMetered >0 or NCEPOutVar >0 or JPPromo >0)
 and r.SlotMast_ID in 
 
 (
select distinct CDS_SlotMast.SlotMast_ID
from CDS_SlotMast 
where CurrentRevision  = 'Y'
and active = 'Y'
and slotnumber not like '%9999%'
) 


  order by r.auditdate asc

  --get operator pay
  --drop table #blend
  select d.slotmast_id, l.slotnumber, d.auditdate, d.eleccoinin, d.jackpots, d.jppromo, d.manualticketout, d.fills, d.progcoinin, d.daysonline, d.cashdownelec,
		 d.cashdownman, d.cashdownvar, d.cashupman, d.cashupvar, d.ptscashdownelec, d.ptscashdownman, d.ptscashupman, d.ptscashupvar, d.promodownelec,
		 d.promodownman, d.promodownvar, d.elecprocoudrop, d.procoudropvar, d.promocoupons, d.actualbillin, d.meteredbillin, d.billinvar, d.scaledrop,
		 d.eleccoindrop, d.coindropvar,	d.meteredvoucherin,	d.voucherinvar, d.actualvoucherin, d.grossdrop, d.netcashablepbt, d.promopbt, d.ncepoutmetered,
		 d.ncepoutsystem, d.ncepoutvar,    
		 max(case when d.auditdate between l.begindt and l.enddt then l.par end) as par,
		 max(case when d.auditdate between l.begindt and l.enddt then l.denomination end) as denomination,
		 max(case when d.auditdate between l.begindt and l.enddt then l.calc_id end) as calc_id,
		 max(case when d.auditdate between l.begindt and l.enddt then l.progpc end) as progpc,
		 max(case when d.auditdate between l.begindt and l.enddt then l.lease_id end) as lease_id,
		 max(case when d.auditdate between l.begindt and l.enddt then l.section end) as section,
		 max(case when d.auditdate between l.begindt and l.enddt then l.location end) as location,
		 max(case when d.auditdate between l.begindt and l.enddt then l.sublocation end) as sublocation,
		 max(case when d.auditdate between l.begindt and l.enddt then l.description end) as description,
		 min(case when d.auditdate between l.begindt and l.enddt then l.onfloordt end) as onfloordt,
		 sum(case 
                when Calc_Id not in (3, 4) then 0
                when Lease_Id = 0 then DaysOnLine * ProgPc
                when Lease_Id = 1 then DaysOnLine * ProgPc / 30
                when Lease_Id = 2 then ElecCoinIn * ProgPc / 100
                when Lease_Id = 3 then GrossDrop * ProgPc / 100
                when Lease_Id = 4 then (GrossDrop+NetCashablePBT - (Jackpots+ManualTicketOut+Fills)) * (ProgPc/100)
                else 0
              end) OperatorPay
  into #blend
  from #details d
		left join #location l on d.slotmast_id = l.slotmast_id 
  group by d.slotmast_id, l.slotnumber, d.auditdate, d.eleccoinin, d.jackpots, d.jppromo, d.manualticketout, d.fills, d.progcoinin, d.daysonline, d.cashdownelec,
		 d.cashdownman, d.cashdownvar, d.cashupman, d.cashupvar, d.ptscashdownelec, d.ptscashdownman, d.ptscashupman, d.ptscashupvar, d.promodownelec,
		 d.promodownman, d.promodownvar, d.elecprocoudrop, d.procoudropvar, d.promocoupons, d.actualbillin, d.meteredbillin, d.billinvar, d.scaledrop,
		 d.eleccoindrop, d.coindropvar,	d.meteredvoucherin,	d.voucherinvar, d.actualvoucherin, d.grossdrop, d.netcashablepbt, d.promopbt, d.ncepoutmetered,
		 d.ncepoutsystem, d.ncepoutvar

--put results in separate table 
--drop table #slots
		 select b.slotmast_id, b.slotnumber, b.auditdate, b.eleccoinin, b.jackpots, b.jppromo, b.manualticketout, b.fills, 
		 b.progcoinin, b.daysonline, b.cashdownelec, b.cashdownman, b.cashdownvar, b.cashupman, b.cashupvar, b.ptscashdownelec, 
		 b.ptscashdownman, b.ptscashupman, b.ptscashupvar, b.promodownelec,	 b.promodownman, b.promodownvar, b.elecprocoudrop, 
		 b.procoudropvar, b.promocoupons, b.actualbillin, b.meteredbillin, b.billinvar, b.scaledrop, b.eleccoindrop, b.coindropvar,	
		 b.meteredvoucherin,	b.voucherinvar, b.actualvoucherin, b.grossdrop, b.netcashablepbt, b.promopbt, b.ncepoutmetered,	 
		 b.ncepoutsystem, b.ncepoutvar, b.operatorpay, isnull((eleccoinin*par)/100,0) as composite, b.par, b.denomination, b.section, 
		 b.location, b.sublocation, b.onfloordt, b.description, year(auditdate) audityear,  month(auditdate) auditmonth,  
		 (b.grossdrop - (b.jackpots + b.manualticketout + b.fills)) as netwintaxable, 
		 (b.grossdrop - (b.jackpots + b.manualticketout + b.fills)) + b.promopbt + b.netcashablepbt + b.promodownvar as statnetwin
into #slots
from #blend b


--Get only coin game details
select  b.SlotNumber, Max(b.description) as description, avg( b.par) as par,sum(b.ElecCoinIn) as coinin, sum(b.Fills) as fill, sum(b.netwintaxable) as netwintaxable,sum(b.PromoPBT) as promo, sum(b.statnetwin) as statnetwin ,sum(b.composite) as theo,
DATEDIFF("d",min(auditdate),max(auditdate)) as 'days'
from (
	select slotnumber, sum(fills) fills
	from #slots s
	group by slotnumber
	having sum(fills)>0 ) a 
	inner join #slots b on a.SlotNumber = b.SlotNumber

group by b. SlotNumber

--Get only cash game details
select b.SlotNumber, Max(b.description) as description, avg( b.par) as par,sum(b.ElecCoinIn) as coinin, sum(b.Fills) as fill, sum(b.netwintaxable) as netwintaxable,sum(b.PromoPBT) as promo, sum(b.statnetwin) as statnetwin ,sum(b.composite) as theo,
DATEDIFF("d",min(auditdate),max(auditdate)) as 'days'
from (
	select slotnumber, sum(fills) fills
	from #slots s
	group by slotnumber
	having sum(fills)<=0 ) a 
	inner join #slots b on a.SlotNumber = b.SlotNumber
	group by b.SlotNumber
