-- Acceptance targets for iteration11's active-play simulation, not a human playtest.
return function(runs)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(#runs>=5,"At least five deterministic seeds")
 for _,r in runs do
  check(not r.Incomplete and #r.Biomes==10,"All ten biomes reached")
  local t=r.Biomes
  for i=2,10 do check(t[i].Seconds>t[i-1].Seconds,"Biome arrival times strictly increase")end
  check(t[2].Seconds>=120 and t[2].Seconds<=180,"Suburbs target 2-3 minutes")
  check(t[5].Seconds>=1800 and t[5].Seconds<=2700,"Desert Highway target 30-45 minutes")
  check(t[10].Seconds>=6*3600 and t[10].Seconds<=10*3600,"Future City target 6-10 hours")
  if r.Purchases then for _,p in r.Purchases do
   check(p.PriceMinutes>=0 and p.Price>=0,"Every purchase is priced in income minutes")
   if p.Kind=="Exercise"then check(p.TrainingRateAfter>p.TrainingRateBefore,"Exercise produces sawtooth rate improvement")end
  end end
 end
 return n.." pacing assertions passed"
end
