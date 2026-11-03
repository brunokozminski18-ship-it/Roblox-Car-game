return function(runs,phone)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 local targets={2.5,15,52.5,150,480}
 for _,r in runs do
  check(not r.Incomplete and #r.Biomes==6 and #r.Purchases==10,"Every seeded run completes the ladder")
  check(math.abs(r.Purchases[1].Seconds/75-1)<=.25,"First purchase within 25 percent")
  for i,target in targets do check(math.abs(r.Biomes[i+1].Seconds/60/target-1)<=.25,"Biome target within 25 percent")end
  for _,p in r.Purchases do
   if p.Kind=="Exercise"then check(math.abs(p.TrainingRateAfter/p.TrainingRateBefore-2)<1e-8,"Training milestone halves training time")
   else check(p.PaybackMinutes>0 and p.PaybackMinutes<=120,"Ticket is within the modeled payback horizon")end
  end
 end
 local first,suburbs
 for _,e in phone.Events do if e.Name=="Bought focused"then first=e.Seconds elseif e.Name=="Suburbs"then suburbs=e.Seconds end end
 check(phone.Complete and phone.NoGrants and first>=60 and first<=90,"Real phone first purchase 60-90 seconds")
 check(suburbs>=120 and suburbs<=180,"Real phone Suburbs 2-3 minutes")
 return n.." pacing acceptance assertions passed"
end
