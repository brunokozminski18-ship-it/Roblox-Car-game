--!strict
-- Explicit schema<=6 identities from this project's original six-biome catalog.
local Config=require(script.Parent.Config)
local M={BiomeMap={1,2,3,7,8,9}}
local legacy={{"Rusty Sedan","Old Van","Broken Pickup"},{"Family Car","Minivan","Hatchback"},{"Taxi","Police Cruiser","Limo"},{"Sports Coupe","Rally Car","Muscle Car"},{"Vintage Roadster","Gold-Trim Classic"},{"Hypercar","Golden Hypercar","Rocket Car"}}
function M.target(oldBiome: number,rarity: number,ordinal: number): any
 local index=M.BiomeMap[oldBiome];if not index or not Config.Rarities[rarity]then return nil end
 local pool={};for _,c in Config.Biomes[index].Cars do if c.Rarity==rarity then table.insert(pool,c)end end
 return pool[(ordinal-1)%#pool+1],index
end
function M.id(id: any): string?
 if typeof(id)~="string"then return nil end
 local bi,style=id:match("^b(%d+)_car(%d+)$");bi,style=tonumber(bi),tonumber(style)
 if not bi or not style or style<1 or style>8 then return nil end
 local rarity=if style<=3 then 1 elseif style<=5 then 2 elseif style<=7 then 3 else 4
 local ordinal=style-(if rarity==1 then 0 elseif rarity==2 then 3 elseif rarity==3 then 5 else 7)
 local c=M.target(bi,rarity,ordinal);return if c then c.Id else nil
end
function M.car(c: any): any
 if typeof(c)~="table"or typeof(c.Biome)~="number"or c.Biome%1~=0 or typeof(c.Rarity)~="number"or c.Rarity%1~=0 then return nil end
 local id=M.id(c.CatalogId)
 local target,index
 if id then
  index=M.BiomeMap[c.Biome];if not index then return nil end
  for _,candidate in Config.Biomes[index].Cars do if candidate.Id==id and candidate.Rarity==c.Rarity then target=candidate;break end end
 elseif c.CatalogId==nil then
  for ordinal,name in legacy[c.Biome]or {} do if name==c.Name then target,index=M.target(c.Biome,c.Rarity,ordinal);break end end
 end
 if not target then return nil end
 local copy=table.clone(c);copy.Biome=index;copy.CatalogId=target.Id;copy.Name=target.Name;copy.Variant=copy.Variant or "Normal"
 return copy
end
return M
