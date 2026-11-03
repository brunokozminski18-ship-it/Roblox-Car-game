return function(Rules,Config,Schema)
 local count=0;local function check(ok,message)assert(ok,message);count+=1 end
 check(type(Rules.trainingActive)=="function","Training state needs a single live position rule")
 local center=Vector3.new(-54,.2,30);local on=center+Vector3.new(0,3,0)
 check(Rules.trainingActive(on,center,true,false),"Enabled training on own pad is active immediately")
 check(not Rules.trainingActive(on,center,false,false),"Explicit stop is respected")
 check(not Rules.trainingActive(on,center,true,true),"Throw/meter blocks training")
 check(not Rules.trainingActive(center+Vector3.new(6,3,0),center,true,false),"Leaving pad stops rewards immediately")
 check(not Rules.trainingActive(nil,center,true,false),"Dead/missing character cannot train")
 check(not Rules.trainingActive(on,nil,true,false),"Missing own pad cannot train")
 check(type(Rules.powerText)=="function"and Rules.powerText(78.55555)=="78.555","Fractional Power remains visible and truncated")
 check(Rules.powerText(78.55555+1/18)~=Rules.powerText(78.55555),"One Suburbs tick updates the displayed Power")
 local d=Schema.default();d.Power=78.5;d.Cash=0
 local base=Rules.trainingRate(d.Power,d.Exercise)
 check(Rules.shop(d,"Exercise","focused")=="Not enough Cash!","No free training purchase")
 d.Cash=Config.Exercises[2].Price
 check(Rules.shop(d,"Exercise","focused")=="Bought Focused Training!"and d.Cash==0,"Training upgrade charges authoritative price")
 check(Rules.trainingRate(d.Power,d.Exercise)==base*2,"Purchased training doubles actual Power/s")
 check(Rules.shop(d,"Exercise","focused")=="Already owned!","Repeated purchase cannot charge twice")
 local restored=Schema.prepare({Schema=Config.Data.Schema,Data=d})
 check(restored and restored.Exercise==2 and restored.Power==78.5,"Training upgrade and fractional Power persist")
 for biome,b in Config.Biomes do for tier=2,#Config.Exercises do
  check(Rules.trainingRate(b.MinPower,tier)==2*Rules.trainingRate(b.MinPower,tier-1),"Every training tier doubles rate in every biome")
 end end
 return count.." training-fix assertions passed"
end
