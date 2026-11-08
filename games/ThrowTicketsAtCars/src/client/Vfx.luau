--!strict
-- Client-only character VFX (LihFolk VFX rules): one-shot Emit bursts, anchored non-colliding holders destroyed by
-- Debris, built-in particle sprite only (no uploads), rings skipped under Reduced Motion. Bursts aim forward, away
-- from the torso; the character itself stays clean (rims and trails, no washes).
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local JuiceRules=require(game.ReplicatedStorage.ThrowTickets.JuiceRules)
local V={}
local WHITE=Color3.new(1,1,1)
local GOLD=Color3.fromRGB(255,214,70)
local MINT=Color3.fromRGB(178,255,173)
local RARITY_COLORS={Color3.fromRGB(200,200,200),Color3.fromRGB(80,170,255),Color3.fromRGB(190,90,255),Color3.fromRGB(255,200,40)}
local function calm(): boolean return GuiService.ReducedMotionEnabled end
local function holder(cf: CFrame,life: number): Part
 local p=Instance.new("Part");p.Name="TT_Vfx";p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
 p.Transparency=1;p.Size=Vector3.new(.2,.2,.2);p.CFrame=cf;p.Parent=workspace
 Debris:AddItem(p,life);return p
end
local function emitter(parent: Instance,props: {[string]: any}): ParticleEmitter
 local e=Instance.new("ParticleEmitter");e.Enabled=false;e.LightEmission=1;e.LightInfluence=0;e.ZOffset=1
 for k,v in props do (e::any)[k]=v end
 e.Parent=parent;return e
end
-- Expanding Neon ring (flat at the feet, or facing forward) that fades as it grows.
local function ring(cf: CFrame,color: Color3,from: number,to: number,life: number,thick: number?)
 if calm()then return end
 local w=thick or .15
 local r=Instance.new("Part");r.Name="TT_Ring";r.Shape=Enum.PartType.Cylinder;r.Material=Enum.Material.Neon;r.Color=color
 r.Anchored=true;r.CanCollide=false;r.CanQuery=false;r.CanTouch=false;r.CastShadow=false;r.Transparency=.25
 r.Size=Vector3.new(w,from,from);r.CFrame=cf*CFrame.Angles(0,0,math.rad(90));r.Parent=workspace
 TweenService:Create(r,TweenInfo.new(life,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(w,to,to),Transparency=1}):Play()
 Debris:AddItem(r,life+.1)
end
local function rootOf(player: Player): BasePart?
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 return if root and root:IsA("BasePart")then root else nil
end
function V.ticketColor(player: Player): Color3
 local id=player:GetAttribute("EquippedTicket")
 for _,t in Config.AllTickets do if t.Id==id then return t.Color end end
 return Color3.fromRGB(255,244,180)
end
-- Throw: a hand trail through the swing, then a forward spark burst and a forward ring at release (gold on PERFECT).
function V.throw(player: Player,untilRelease: number)
 local character=player.Character
 local hand=character and character:FindFirstChild("RightHand")
 local root=rootOf(player)
 if not hand or not hand:IsA("BasePart")or not root then return end
 local color=V.ticketColor(player)
 local a0=Instance.new("Attachment");a0.Name="TT_TrailA";a0.Position=Vector3.new(0,.35,0);a0.Parent=hand
 local a1=Instance.new("Attachment");a1.Name="TT_TrailB";a1.Position=Vector3.new(0,-.45,0);a1.Parent=hand
 local trail=Instance.new("Trail");trail.Attachment0=a0;trail.Attachment1=a1;trail.Lifetime=.16;trail.MinLength=.05
 trail.LightEmission=1;trail.FaceCamera=true;trail.WidthScale=NumberSequence.new(1,.2)
 trail.Color=ColorSequence.new(WHITE,color);trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(1,1)})
 trail.Parent=hand
 for _,x in {a0,a1,trail}do Debris:AddItem(x,untilRelease+.6)end
 task.delay(untilRelease,function()
  if not hand.Parent then return end
  local bonus=player:GetAttribute("LastThrowBonus")
  local perfect=JuiceRules.perfect(if typeof(bonus)=="number"then bonus else 0)
  local forward=root.CFrame.LookVector
  local at=hand.Position
  local h=holder(CFrame.lookAt(at,at+forward+Vector3.new(0,.35,0)),1.2)
  local tint=if perfect then GOLD else color
  emitter(h,{Color=ColorSequence.new(WHITE,tint),Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(1,0)}),
   Lifetime=NumberRange.new(.18,.36),Speed=NumberRange.new(22,38),SpreadAngle=Vector2.new(22,22),Drag=7,EmissionDirection=Enum.NormalId.Front,
   Transparency=NumberSequence.new(0,1)}):Emit(if perfect then 26 else 12)
  ring(CFrame.lookAt(at+forward*1.2,at+forward*3),tint,.6,if perfect then 7 else 4,.24,.1)
  if perfect then ring(CFrame.lookAt(at+forward*2.4,at+forward*4),WHITE,.4,5,.3,.06)end
  task.delay(.12,function()trail.Enabled=false end)
 end)
end
-- Catch celebration: confetti fountain in rarity colours plus a foot ring; Epic+ adds a second ring and a light pillar.
function V.celebrate(player: Player,rarity: number)
 local root=rootOf(player);if not root then return end
 local big=rarity>=3;local main=RARITY_COLORS[rarity]or WHITE
 local feet=root.Position-Vector3.new(0,2.9,0)
 local h=holder(CFrame.lookAt(root.Position+Vector3.new(0,1.5,0),root.Position+Vector3.new(0,10,0)),3)
 for i,c in {main,WHITE,GOLD}do
  emitter(h,{Color=ColorSequence.new(c),Size=NumberSequence.new(.32),Lifetime=NumberRange.new(1.1,1.8),Speed=NumberRange.new(20,34),
   SpreadAngle=Vector2.new(38,38),Acceleration=Vector3.new(0,-38,0),Drag=1.5,EmissionDirection=Enum.NormalId.Front,
   Rotation=NumberRange.new(0,360),RotSpeed=NumberRange.new(-300,300),LightEmission=.4,
   Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.8,0),NumberSequenceKeypoint.new(1,1)})}):Emit(if big then 22 else 10-(i-1)*2)
 end
 ring(CFrame.new(feet),main,2,if big then 18 else 11,.55)
 if big then
  task.delay(.18,function()ring(CFrame.new(feet+Vector3.new(0,.1,0)),WHITE,1.5,14,.5,.1)end)
  if not calm()then
   local pillar=Instance.new("Part");pillar.Name="TT_Pillar";pillar.Shape=Enum.PartType.Cylinder;pillar.Material=Enum.Material.Neon;pillar.Color=main
   pillar.Anchored=true;pillar.CanCollide=false;pillar.CanQuery=false;pillar.CanTouch=false;pillar.CastShadow=false;pillar.Transparency=.35
   -- Starts above the head so the character stays clean (no wash over the body).
   pillar.Size=Vector3.new(22,1.4,1.4);pillar.CFrame=CFrame.new(feet+Vector3.new(0,18,0))*CFrame.Angles(0,0,math.rad(90));pillar.Parent=workspace
   TweenService:Create(pillar,TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=Vector3.new(22,.1,.1),Transparency=1}):Play()
   Debris:AddItem(pillar,1)
  end
 end
end
-- Training: a faint foot pulse and a few rising motes per rep.
function V.trainRep(player: Player)
 local root=rootOf(player);if not root then return end
 ring(CFrame.new(root.Position-Vector3.new(0,2.9,0)),MINT,1,5,.4,.08)
 local h=holder(CFrame.lookAt(root.Position,root.Position+Vector3.new(0,1,0)),1.2)
 emitter(h,{Color=ColorSequence.new(MINT),Size=NumberSequence.new(.22,0),Lifetime=NumberRange.new(.5,.8),Speed=NumberRange.new(4,7),
  SpreadAngle=Vector2.new(60,60),EmissionDirection=Enum.NormalId.Front,Transparency=NumberSequence.new(.2,1)}):Emit(4)
end
-- Level up: two escalating gold/white rings and a sparkle fountain.
function V.levelUp(player: Player)
 local root=rootOf(player);if not root then return end
 local feet=root.Position-Vector3.new(0,2.9,0)
 ring(CFrame.new(feet),GOLD,2,12,.5)
 task.delay(.12,function()ring(CFrame.new(feet+Vector3.new(0,.1,0)),WHITE,1.5,9,.45,.08)end)
 local h=holder(CFrame.lookAt(root.Position+Vector3.new(0,1,0),root.Position+Vector3.new(0,10,0)),2)
 emitter(h,{Color=ColorSequence.new(WHITE,GOLD),Size=NumberSequence.new(.4,0),Lifetime=NumberRange.new(.7,1.1),Speed=NumberRange.new(14,22),
  SpreadAngle=Vector2.new(25,25),Acceleration=Vector3.new(0,-14,0),EmissionDirection=Enum.NormalId.Front,Transparency=NumberSequence.new(0,1)}):Emit(18)
end
return V
