--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local Meter={}
function Meter.position(elapsed: number): number
 return math.abs((elapsed/Config.ThrowMeter.Period%1)*2-1)
end
function Meter.bonus(position: number): number
 local c=Config.ThrowMeter
 return math.clamp(c.MaxBonus+(c.MinBonus-c.MaxBonus)*math.clamp(position,0,1),c.MinBonus,c.MaxBonus)
end
function Meter.tap(start: number,tap: any,now: number,ping: number): number?
 if not Rules.finiteNumber(tap)then return nil end
 local tolerance=math.min(Config.ThrowMeter.MaxPingTolerance,math.max(.06,ping+.06))
 if tap<start or tap>now+.03 or tap<now-tolerance or tap>start+Config.ThrowMeter.Timeout then return nil end
 return Meter.bonus(Meter.position(math.max(0,math.min(now,tap)-start)))
end
return Meter
