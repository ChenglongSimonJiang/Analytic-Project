 
 ------------------------This Year----------------------
 select
 b.SlotNumber, b.Description,  c.location, b.par ,
 sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))  GrossDrop, 
 sum(a.ElecCoinOut) as coin_out,
 sum(a. Jackpots) as JackPot, 
 sum(a.Fills) as fills,
 (sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - 
 (sum(a. Jackpots) +  sum(ISNULL(a.ManualTicketOut, 0) ) + sum(a.Fills)) + sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + 
 ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0))) +  sum(ISNULL(rpbt.CashDownElec, 0) + ISNULL(rpbt.CashDownVar, 0) + ISNULL(rpbt.PtsCashDownElec, 0) + ISNULL(rpbt.PtsCashDownVar, 0)  
 - (ISNULL(rpbt.CashUpElec, 0) + ISNULL(rpbt.CashUpVar, 0) + ISNULL(rpbt.PtsCashUpElec, 0) + ISNULL(rpbt.PtsCashUpVar, 0))) + sum(ISNULL(rpbt.PromoDownVar, 0) )) as statnetwin,
(sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills))) as netwintaxable, 
 sum(isnull((eleccoinin*par)/100,0) )as theo,
 sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0)) )as promo, 
 sum(a.ElecCoinIn) as coin_in,
  case when b.Lease_ID=0 then ProgPC* sum(a.DaysOnLine)
	  when b.Lease_ID=1 then ProgPC* sum(a.DaysOnLine)/30
	  when b.Lease_ID=2 then ProgPC* sum(a.ElecCoinIn)/100
	  when b.Lease_ID=3 then ProgPC* sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))/100
	  when b.Lease_ID=4 then ProgPC* (sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills)))/100
	  else 0
	  end as lease_fee,
 DATEDIFF("d",min(a.auditdate),max(a.auditdate)) as 'days_onfloor'
 from BB_REVENUE a 
 inner join CDS_SlotMast b on a.SlotMast_ID=b.SlotMast_ID 
 inner JOIN dbo.bb_Revenue_PBT rpbt (nolock) on a.AuditDate = rpbt.AuditDate and a.Period_Id = rpbt.Period_Id and a.SlotMast_Id = rpbt.SlotMast_ID
 inner join custom_location_information c on b.Section=c.section
 where a.AuditDate between '2020-06-04' and '2020-07-01'
and b.Active='Y'
and b.CurrentRevision='Y'
and a.Period_ID='4'
and b.SlotNumber not like'%9999'
group by b.SlotNumber, b.Description,b.Par, Lease_ID,ProgPC,location



-----------------------Piror Year------------------------------------

 select
 b.SlotNumber, b.Description,  c.location, b.par ,
 sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))  GrossDrop, 
 sum(a.ElecCoinOut) as coin_out,
 sum(a. Jackpots) as JackPot, 
 sum(a.Fills) as fills,
 (sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - 
 (sum(a. Jackpots) +  sum(ISNULL(a.ManualTicketOut, 0) ) + sum(a.Fills)) + sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + 
 ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0))) +  sum(ISNULL(rpbt.CashDownElec, 0) + ISNULL(rpbt.CashDownVar, 0) + ISNULL(rpbt.PtsCashDownElec, 0) + ISNULL(rpbt.PtsCashDownVar, 0)  
 - (ISNULL(rpbt.CashUpElec, 0) + ISNULL(rpbt.CashUpVar, 0) + ISNULL(rpbt.PtsCashUpElec, 0) + ISNULL(rpbt.PtsCashUpVar, 0))) + sum(ISNULL(rpbt.PromoDownVar, 0) )) as statnetwin,
(sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills))) as netwintaxable, 
 sum(isnull((eleccoinin*par)/100,0) )as theo,
 sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0)) )as promo, 
 sum(a.ElecCoinIn) as coin_in,
  case when b.Lease_ID=0 then ProgPC* sum(a.DaysOnLine)
	  when b.Lease_ID=1 then ProgPC* sum(a.DaysOnLine)/30
	  when b.Lease_ID=2 then ProgPC* sum(a.ElecCoinIn)/100
	  when b.Lease_ID=3 then ProgPC* sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))/100
	  when b.Lease_ID=4 then ProgPC* (sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills)))/100
	  else 0
	  end as lease_fee,
 DATEDIFF("d",min(a.auditdate),max(a.auditdate)) as 'days_onfloor'
 from BB_REVENUE a 
 inner join CDS_SlotMast b on a.SlotMast_ID=b.SlotMast_ID 
 inner JOIN dbo.bb_Revenue_PBT rpbt (nolock) on a.AuditDate = rpbt.AuditDate and a.Period_Id = rpbt.Period_Id and a.SlotMast_Id = rpbt.SlotMast_ID
 inner join custom_location_information c on b.Section=c.section
 where a.AuditDate between '2019-06-04' and '2019-07-01'
and b.CurrentRevision='Y'
and a.Period_ID='4'
and b.SlotNumber not like'%9999'
group by b.SlotNumber, b.Description,b.Par, Lease_ID,ProgPC,location
having sum(a.ElecCoinIn)<>0 
--and    DATEDIFF("d",min(a.auditdate),max(a.auditdate))>='26'