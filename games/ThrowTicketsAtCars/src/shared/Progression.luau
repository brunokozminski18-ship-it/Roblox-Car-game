--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local Progression={}
-- Internal awards only: at most 1,000,000 XP per call (10,000 levels),
-- finite fractional XP is supported. These bounds also keep save numbers exact.
local MAX_AWARD=1e6
local MAX_LEVEL=1e9
function Progression.levelFromPower(power: number): number
 if not Rules.finiteNumber(power)then return 1 end
 return math.clamp(math.floor(math.max(0,power-Config.StartPower)/Config.Progression.PowerPerLevel)+1,1,MAX_LEVEL)
end
function Progression.addXP(data: any,amount: any): (number,number)
 if not Rules.finiteNumber(amount)or amount<=0 or amount>MAX_AWARD then return 0,0 end
 if typeof(data)~="table"or not Rules.finiteNumber(data.TrainingLevel)or data.TrainingLevel%1~=0 or data.TrainingLevel<1 or data.TrainingLevel>MAX_LEVEL
  or not Rules.finiteNumber(data.TrainingXP)or data.TrainingXP<0 or data.TrainingXP>=Config.Progression.XPPerLevel
  or not Rules.finiteNumber(data.Power)or data.Power<0 or data.Power>Config.MaxPower then return 0,0 end
 local total=data.TrainingXP+amount
 local earned=math.floor(total/Config.Progression.XPPerLevel)
 local levels=math.min(earned,MAX_LEVEL-data.TrainingLevel)
 local power=math.min(Config.MaxPower,data.Power+levels*Config.Progression.PowerPerLevel)
 local powerGain=power-data.Power
 data.TrainingLevel+=levels
 -- At the level ceiling, discard overflow levels while retaining a valid remainder.
 data.TrainingXP=total-earned*Config.Progression.XPPerLevel
 data.Power=power
 return levels,powerGain
end
return Progression
