--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local J={}
function J.revealSeconds(name: string,rarity: number): number
 local rare=rarity>=3;local c=Config.Juice
 return math.max(if rare then c.RareRevealMin else c.CommonRevealMin,#name*c.LetterSeconds*(if rare then c.RareLetterMultiplier else 1)+(if rare then .65 else .35))
end
function J.selection(power: number,value: any): number?
 if not Rules.finiteNumber(value)or value<math.min(1,power)or value>power then return nil end
 return value
end
function J.distance(power: number,selection: number,bonus: number): number
 return Rules.distance(math.clamp(selection,0,power)*(1+math.clamp(bonus,Config.ThrowMeter.MinBonus,Config.ThrowMeter.MaxBonus)))
end
function J.perfect(bonus: number): boolean
 return bonus>=Config.ThrowMeter.MaxBonus-(Config.ThrowMeter.MaxBonus-Config.ThrowMeter.MinBonus)*Config.Juice.PerfectPosition
end
function J.odds(reward: any,ticketId: string): number
 local function probability(entries: any,id: any): number
  local total,weight=0,0;for i,e in entries do total+=e.Weight;if (e.Id or i)==id then weight=e.Weight end end
  return weight/total
 end
 local pool={};for _,c in Config.Biomes[reward.Biome].Cars do if c.Rarity==reward.Rarity then table.insert(pool,c)end end
 local p=probability(Rules.rarityWeights(ticketId),reward.Rarity)*probability(pool,reward.CatalogId)
 p*=probability(Rules.extraWeights(Config.Variants,ticketId),reward.Variant or "Normal")
 return math.max(1,math.floor(1/p+.5))
end
return J
