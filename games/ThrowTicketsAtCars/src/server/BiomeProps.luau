--!strict
-- Greybox landmarks only. Final map art is NOT FINAL.
local Props={}
function Props.build(folder: Instance,b: any,part: any)
 local function block(name,x,y,z,px,py,pz,color)return part(folder,name,Vector3.new(x,y,z),Vector3.new(px,py,pz),Color3.fromHex(color))end
 for i=1,3 do
  local x=if i%2==1 then -31 else 32;local z=-b.MinPower-(b.EndPower-b.MinPower)*(i-.5)/3
  local kind=b.Prop
  if kind=="cactus"then block("Cactus",1.5,7,1.5,x,3.5,z,"4B8050");block("CactusArm",4,1,1,x+1,4,z,"4B8050");block("CactusTip",1,3,1,x+2.5,5,z,"4B8050")
  elseif kind=="towers"or kind=="neon"then
   local height=10+i*5;block("Tower",7,height,7,x,height/2,z,"525D73")
   for floor=2,height-1,3 do local p=block("WindowBand",7.2,.5,7.2,x,floor,z,if kind=="neon"then "73DDE5"else "D5DABA");if kind=="neon"then p.Material=Enum.Material.Neon end end
  elseif kind=="snow"then block("SnowBank",8,2,7,x,1,z,"ECF2F5");block("FirTrunk",.7,5,.7,x,2.5,z,"71604D");for j=1,3 do block("SnowyFir",6-j,1.8,6-j,x,2+j*1.3,z,"8DAEB0")end
  elseif kind=="houses"or kind=="villas"then block("House",8,6,7,x,3,z,if kind=="villas"then "E8DDC3"else "CDB098");block("FlatRoof",9,.5,8,x,6.3,z,"6C7186");block("FrontDoor",1.8,3,.1,x,1.5,z+3.55,"545F68")
  elseif kind=="farm"then block("HayBale",4,2,3,x,1,z,"D1B457");block("Barn",7,7,8,x,3.5,z-5,"AB5549");block("BarnRoof",8,.8,9,x,7.3,z-5,"79685C")
  elseif kind=="race"then block("RaceBarrier",9,1,2,x,1,z,"E6E7E2");for j=0,3 do block("RedStripe",1,1.1,2.1,x-3+j*2,1,z,"BC5751")end
  elseif kind=="palms"then block("PalmTrunk",1,8,1,x,4,z,"9C7A57");block("PalmCrown",9,.6,2,x,8,z,"669B67");block("PalmCrown",2,.6,9,x,8,z,"669B67")
  else block("ScrapPile",4,2,5,x,1,z,"7E6B5C");block("ScrapBlock",3,3,2,x+1,3,z,"9D795A")end
 end
end
return Props
