--!strict
-- Car Index rewards (user decision 08.11.2026, research/Progression18.md):
-- 4/8 cars of a biome discovered -> one free car from that biome; 8/8 -> +2% income, additive per biome.
local Config=require(script.Parent.Config)
local Index={}
function Index.count(data: any,biome: number): (number,number)
 local b=Config.Biomes[biome];if not b then return 0,0 end
 local n=0;for _,c in b.Cars do if data.Discovered[c.Id]==true then n+=1 end end
 return n,#b.Cars
end
function Index.completed(data: any): number
 local done=0
 for i in Config.Biomes do local n,total=Index.count(data,i);if total>0 and n>=total then done+=1 end end
 return done
end
function Index.incomeMultiplier(data: any): number
 return 1+Config.Index.CompleteBonus*Index.completed(data)
end
-- Biomes whose half-collection free car is earned but not yet granted, lowest biome first.
function Index.due(data: any): {number}
 local out={}
 for i in Config.Biomes do
  local n=Index.count(data,i)
  if n>=Config.Index.FreeCarAt and data.IndexClaims[tostring(i)]~=true then table.insert(out,i)end
 end
 return out
end
function Index.markClaimed(data: any,biome: number)
 data.IndexClaims[tostring(biome)]=true
end
return Index
