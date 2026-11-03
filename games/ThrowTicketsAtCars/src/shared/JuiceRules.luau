--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local J={}
function J.selection(power: number,value: any): number?
 if not Rules.finiteNumber(value)or value<math.min(1,power)or value>power then return nil end
 return value
end
function J.distance(power: number,selection: number,bonus: number): number
 return math.clamp(math.clamp(selection,0,power)*(1+math.clamp(bonus,Config.ThrowMeter.MinBonus,Config.ThrowMeter.MaxBonus)),0,Config.MapEnd)
end
function J.perfect(bonus: number): boolean
 return bonus>=Config.ThrowMeter.MaxBonus-(Config.ThrowMeter.MaxBonus-Config.ThrowMeter.MinBonus)*Config.Juice.PerfectPosition
end
function J.odds(reward: any,ticketId: string): number
 local weights=Rules.rarityWeights(ticketId);local total=0;for _,r in weights do total+=r.Weight end
 local carTotal,chosen=0,1;for _,c in Config.Biomes[reward.Biome].Cars do carTotal+=c.Weight;if c.Name==reward.Name then chosen=c.Weight end end
 return math.max(1,math.floor(total/weights[reward.Rarity].Weight*carTotal/chosen+.5))
end
return J
