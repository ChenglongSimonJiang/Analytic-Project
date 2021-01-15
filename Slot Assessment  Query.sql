
 select distinct b.SlotNumber ,
 sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))  GrossDrop, 
 sum(a.ElecCoinOut) as coin_out,
(sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - (sum(a. Jackpots) +  sum(ISNULL(a.ManualTicketOut, 0) ) + sum(a.Fills)) + sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0))) +  sum(ISNULL(rpbt.CashDownElec, 0) + ISNULL(rpbt.CashDownVar, 0) + ISNULL(rpbt.PtsCashDownElec, 0) + ISNULL(rpbt.PtsCashDownVar, 0)  - (ISNULL(rpbt.CashUpElec, 0) + ISNULL(rpbt.CashUpVar, 0) + ISNULL(rpbt.PtsCashUpElec, 0) + ISNULL(rpbt.PtsCashUpVar, 0))) + sum(ISNULL(rpbt.PromoDownVar, 0) )) as statnetwin,
(sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills))) as netwintaxable, 
 sum(a. Jackpots) as JP, 
 sum(a.Fills) as fills,
 sum(isnull((eleccoinin*par)/100,0) )as theo,
 sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0)) )as promo, 
 sum(a.ElecCoinIn) as coin_in,
 sum(ISNULL(rpbt.CashDownElec, 0) + ISNULL(rpbt.CashDownVar, 0) + ISNULL(rpbt.PtsCashDownElec, 0) + ISNULL(rpbt.PtsCashDownVar, 0)  - (ISNULL(rpbt.CashUpElec, 0) + ISNULL(rpbt.CashUpVar, 0) + ISNULL(rpbt.PtsCashUpElec, 0) + ISNULL(rpbt.PtsCashUpVar, 0))) NetCashablePBT,
 sum((ISNULL(rpbt.PromoDownElec, 0) + ISNULL(rpbt.PromoDownVar, 0)) - (ISNULL(rpbt.NCEPOutMetered,0) + ISNULL(rpbt.NCEPOutVar,0) + ISNULL(a.JPPromo, 0))) PromoPBT,
 sum(ISNULL(rpbt.NCEPOutMetered, 0)	)NCEPOutMetered ,
 sum(ISNULL(a.ManualTicketOut, 0) )    as               ManualTicketOut,
 sum(ISNULL(rpbt.PromoDownVar, 0)     ) as              PromoDownVar,
 sum(a.DaysOnLine) as 'days',
 b.Lease_ID, b.ProgPC,  isnull (BB_Lease.LeaseDesc,'Owned')as Lease_status,BB_Mfr.Manufacturer,BB_Style.StyleDesc,
 case when datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate)<3 then'0-3 year'
	  when (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))>=3 and (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))<5 then'3-5 year'
	  when (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))>=5 and (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))<7  then'5-7 year'
	  when (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))>=7 and (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))<10 then'7-10 year'
	  when (datepart(yyyy,GETDATE()) - datepart(yyyy,b.EntryDate))>=10 then'10+ year'
   end as machine_age,
 case when b.Lease_ID=0 then ProgPC* sum(a.DaysOnLine)
	  when b.Lease_ID=1 then ProgPC* sum(a.DaysOnLine)/30
	  when b.Lease_ID=2 then ProgPC* sum(a.ElecCoinIn)/100
	  when b.Lease_ID=3 then ProgPC* sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0))/100
	  when b.Lease_ID=4 then ProgPC* (sum(ISNULL(a.ElecCoinDrop, 0) + ISNULL(a.CoinDropVar, 0)  + ISNULL(a.MeteredBillIn, 0) + ISNULL(a.BillInVar, 0)  + ISNULL(a.MeteredVoucherIn, 0) + ISNULL(a.VoucherInVar, 0)) - ( sum(a. Jackpots)  + sum(ISNULL(a.ManualTicketOut, 0) )  + sum(a.Fills)))/100
	  else 0
	  end as lease_fee
	  ,
case when sum(isnull(a.Fills,0))<=0 then 'N'
else 'Y'	end as coin_machine
from BB_REVENUE a
 inner join CDS_SlotMast b on a.SlotMast_ID=b.SlotMast_ID 
 inner JOIN dbo.bb_Revenue_PBT rpbt (nolock) on a.AuditDate = rpbt.AuditDate and a.Period_Id = rpbt.Period_Id and a.SlotMast_Id = rpbt.SlotMast_ID
 left join BB_Lease on BB_Lease.Lease_ID=b.Lease_ID
 left join BB_Mfr on BB_Mfr.Mfr_ID=b.Mfr_ID
 left join BB_Style on BB_Style.Style_ID=b.Style_ID
 where a.AuditDate between '2020-06-04' and '2020-06-30' and a.period_id='4' and Active='y' and CurrentRevision='y' and SlotNumber not like'%9999%'
 group by b.SlotNumber, b.Lease_ID,b.ProgPC,b.Lease_ID, BB_Lease.LeaseDesc, BB_Mfr.Manufacturer, BB_Style.StyleDesc,b.EntryDate

