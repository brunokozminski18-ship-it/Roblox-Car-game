return function(Config,Rules,Schema,Garage,Builder)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(#Config.Biomes==10,"Ten active biomes required")
 check(#Config.ComingSoon==2,"Two separately locked coming-soon biomes")
 local total=0;local seen={}
 for bi,b in Config.Biomes do
  local tiers={0,0,0,0}
  for _,c in b.Cars do total+=1;tiers[c.Rarity]+=1;check(not seen[c.Id]and #c.Description>5,"Unique catalog identity and authored description");seen[c.Id]=true end
  for i=1,4 do check(tiers[i]>0,"Each biome supports every rarity")end
  if bi>1 then check(b.MinPower>Config.Biomes[bi-1].MinPower and b.BaseIncome>Config.Biomes[bi-1].BaseIncome,"Monotonic biome thresholds and incomes")end
 end
 check(total==80,"Exactly 80 collectible cars at launch (8 per released biome)")
 check(Rules.rollCar(11,"paper",Random.new(1))==nil and Rules.rollCar(12,"paper",Random.new(1))==nil,"Coming soon cannot grant cars")
 check(Rules.biome(Rules.distance(1e9))==10,"All server landing distances clamp to active map")
 local oldToNew={1,2,3,7,8,9}
 for old=1,6 do for style=1,8 do
  local rarity=if style<=3 then 1 elseif style<=5 then 2 elseif style<=7 then 3 else 4
  local d=Schema.default();d.Cars={{Id="old-instance",Biome=old,Rarity=rarity,Name="Old display",CatalogId=string.format("b%d_car%d",old,style),Variant="Gold",Ticket="paper",Slot=1}}
  d.Discovered={[d.Cars[1].CatalogId]=true}
  local migrated,err=Schema.prepare({Schema=6,Data=d})
  check(migrated~=nil,"Old catalog migrates: "..tostring(err))
  local c=migrated.Cars[1];check(c.Id=="old-instance"and c.Slot==1 and c.Variant=="Gold"and c.Biome==oldToNew[old]and c.Rarity==rarity,"Identity, parking, variant and semantic biome retained")
  check(migrated.Discovered[c.CatalogId]and Rules.savedReward(c)~=nil,"Discovery and car remain usable")
  local again=Schema.prepare({Schema=Config.Data.Schema,Data=migrated});check(again and again.Cars[1].CatalogId==c.CatalogId,"Migration is stable on next save/load")
 end end
 for _,bi in {1,5,10}do
  local counts={0,0,0,0};local rng=Random.new(11000+bi)
  for i=1,10000 do local r=Rules.rollCar(bi,"paper",rng);counts[r.Rarity]+=1;assert(r.Biome==bi and seen[r.CatalogId])end
  for rarity,c in counts do check(math.abs(c/10000-Config.Rarities[rarity].Weight/100)<.018,"Ten thousand roll rarity distribution")end
 end
 local container=Instance.new("Folder")
 for bi,b in Config.Biomes do for i,c in b.Cars do
  local m=Builder.create(container,"Check",Rules.reward(bi,c.Rarity,i,"paper"),Vector3.zero)
  local _,size=m:GetBoundingBox();local count=0
  for _,p in m:GetDescendants()do if p:IsA("BasePart")then count+=1;check(p.Anchored and not p.CanCollide and not p.CanTouch,"Safe cosmetic geometry")end end
  check(m.PrimaryPart and m:FindFirstChild("Windshield")and count>=8 and count<=150 and size.Magnitude<24,"Bounded recognizable vehicle with transport anchors")
  local offset=Builder.ticketOffset(m);local target=Vector3.new(7,Config.CarHeight+offset.Y,-6000);m:PivotTo(m:GetPivot()+target-offset-m.PrimaryPart.Position)
  check((m.Windshield.Position-target).Magnitude<.001,"Ticket lands at each model's real anchor")
  local lowest=math.huge
  for _,p in m:GetDescendants()do if p:IsA("BasePart")and p.Transparency<1 then
   local cf=p.CFrame;local extent=(math.abs(cf.RightVector.Y)*p.Size.X+math.abs(cf.UpVector.Y)*p.Size.Y+math.abs(cf.LookVector.Y)*p.Size.Z)/2
   lowest=math.min(lowest,p.Position.Y-extent)
  end end
  check(math.abs(m.PrimaryPart.Position.Y-Config.CarHeight)<.001 and lowest>-.35 and lowest<.35,"Vehicle wheels stay on road during catch")
  m:Destroy()
 end end
 container:Destroy()
 return n.." iteration11 assertions passed, 30000 deterministic rolls and 80 model checks"
end
