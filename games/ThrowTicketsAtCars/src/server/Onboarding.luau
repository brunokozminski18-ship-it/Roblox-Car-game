--!strict
-- First 60 seconds: wires the vendored LihFolk tutorial into THROW TICKETS (profile slice, signals, rewards).
-- Progress lives in profile.Data.Tutorial (step ids, never indices). Server owns every completion and reward.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.ThrowTickets.Config)
local Tutorial=require(RS.ThrowTickets.LihFolkTutorial)
local Steps=require(RS.ThrowTickets.TutorialSteps)
local Onboarding={}
-- ctx: states, mutable(s), mirror(p,s), touch(s), saveSoon(p,s), result(p,text), celebrate(p,kind)
function Onboarding.new(ctx: any): any
 local remote=Instance.new("RemoteEvent");remote.Name="Tutorial";remote.Parent=RS.ThrowTickets:WaitForChild("Remotes")
 local function state(p: Player): any local s=ctx.states[p];return if s and ctx.mutable(s)then s else nil end
 local steps=table.clone(Steps)
 for i,step in steps do
  local copy=table.clone(step);steps[i]=copy
  if copy.id=="park"then
   -- Shown only once the tow has delivered the car (no objective over the reveal).
   copy.trigger=function(p: Player): boolean local s=state(p);return s~=nil and s.phase=="Idle"end
   copy.isComplete=function(p: Player): boolean
    local s=state(p);if not s then return false end
    for _,c in s.data.Cars do if c.Slot>0 then return true end end;return false
   end
  elseif copy.id=="buy"then
   copy.isComplete=function(p: Player): boolean local s=state(p);return s~=nil and s.data.Exercise>=2 end
  end
 end
 local tutorial=Tutorial.Server.new({
  steps=steps,remote=remote,funnelName="Onboarding_v1",
  load=function(p: Player)
   local deadline=os.clock()+60
   while p.Parent==Players and os.clock()<deadline do
    local s=ctx.states[p];if s and p:GetAttribute("DataReady")==true then return s.data.Tutorial end
    task.wait(.2)
   end
   error("profile not ready") -- the module pauses instead of treating this as a new player
  end,
  save=function(p: Player,saved: any)
   local s=ctx.states[p];if s and ctx.mutable(s)then s.data.Tutorial=saved;ctx.touch(s)end
  end,
  reward=function(p: Player,id: string)
   local s=state(p);if not s or id~="FirstExerciseCash"then return end
   local price=Config.Exercises[2].Price
   if s.data.Exercise<2 and s.data.Cash<price then s.data.Cash=price;ctx.mirror(p,s);ctx.saveSoon(p,s)end
  end,
  isReturning=function(p: Player): boolean local s=ctx.states[p];return s~=nil and #s.data.Cars>0 end,
  onFinished=function(p: Player,skipped: boolean)
   if not skipped then ctx.celebrate(p)end
   local nextBiome=Config.Biomes[2]
   if nextBiome then ctx.result(p,"Train to "..nextBiome.MinPower.." Power to reach "..nextBiome.Name:upper().."!")end
  end,
 })
 tutorial:Start()
 return tutorial
end
-- Profile slice for Schema 9. Existing players (Schema < 9) never see the tutorial.
function Onboarding.default(): any return {v=1,done={},rewarded={},progress={},skipped=false,finished=false}end
function Onboarding.finishedSlice(): any
 local t=Onboarding.default();t.finished=true
 for _,step in Steps do t.done[step.id]=true;t.rewarded[step.id]=true end
 return t
end
function Onboarding.clean(raw: any): any?
 if typeof(raw)~="table"then return nil end
 local known={};for _,step in Steps do known[step.id]=true end
 local out=Onboarding.default()
 for _,key in {"done","rewarded","progress"}do
  local map=raw[key];if map~=nil and typeof(map)~="table"then return nil end
  for id,v in map or {} do
   if typeof(id)=="string"and #id<=48 then
    if key=="progress"then if typeof(v)=="number"and v==v and v>=0 and v<1e6 then out.progress[id]=math.floor(v)end
    elseif v==true then out[key][id]=true end
   end
  end
 end
 out.skipped=raw.skipped==true;out.finished=raw.finished==true
 -- Unknown ids from an older step list are dropped; the module maps renamed ids itself.
 for id in out.done do if not known[id]then out.done[id]=nil end end
 return out
end
return Onboarding
