--!strict
-- Wires character animations and VFX to game state (client only; rewards and rules stay on the server).
-- Local player: Train loop while training, HoldCar while a car Tool is held, Cheer when a catch is delivered.
-- Every player: catch celebration VFX; local player: per-rep training pulse and level-up burst.
local Players=game:GetService("Players")
local Anims=require(script.Parent.CharacterAnims)
local Vfx=require(script.Parent.Vfx)
local Fx={}
function Fx.mount(juice: RemoteEvent)
 local p=Players.LocalPlayer
 local cheering=false
 local function holding(): boolean
  local c=p.Character;return c~=nil and c:FindFirstChildOfClass("Tool")~=nil
 end
 local function refresh()
  local throwing=p:GetAttribute("Throwing")==true
  local training=p:GetAttribute("TrainingActive")==true and not throwing
  -- Hands are busy with the dumbbells: the held car goes back to the hotbar while training.
  if training and holding()then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h:UnequipTools()end end
  if training then Anims.play("Train")else Anims.stop("Train")end
  if holding()and not throwing and not cheering and p:GetAttribute("TrainingActive")~=true then Anims.play("HoldCar",.2)else Anims.stop("HoldCar",.15)end
 end
 for _,a in {"TrainingActive","Throwing"}do p:GetAttributeChangedSignal(a):Connect(refresh)end
 local function bindCharacter(c: Model)
  c.ChildAdded:Connect(function(x)if x:IsA("Tool")then refresh()end end)
  c.ChildRemoved:Connect(function(x)if x:IsA("Tool")then refresh()end end)
  task.defer(refresh)
 end
 p.CharacterAdded:Connect(bindCharacter);if p.Character then bindCharacter(p.Character)end
 -- Delivery (Tow -> Idle) = the catch landed on the plot: cheer and celebrate in the rarity colour.
 local function watch(player: Player)
  local last=player:GetAttribute("ThrowPhase")
  player:GetAttributeChangedSignal("ThrowPhase"):Connect(function()
   local phase=player:GetAttribute("ThrowPhase")
   if last=="Tow"and phase=="Idle"then
    local rarity=player:GetAttribute("LastRarity")
    task.delay(.25,function()Vfx.celebrate(player,if typeof(rarity)=="number"then rarity else 1)end)
    if player==p then
     local track=Anims.track("Cheer")
     if track then
      cheering=true;refresh();track:Play(.1)
      task.delay(track.Length>0 and track.Length or 1.5,function()cheering=false;refresh()end)
     end
    end
   end
   last=phase
  end)
 end
 for _,player in Players:GetPlayers()do watch(player)end
 Players.PlayerAdded:Connect(watch)
 juice.OnClientEvent:Connect(function(kind: string,data: any)
  if kind~="XP"or typeof(data)~="table"then return end
  Vfx.trainRep(p)
  if typeof(data.Levels)=="number"and data.Levels>0 then Vfx.levelUp(p)end
 end)
end
return Fx
