--!strict
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local S=require(script.Parent.Style)
local HUD={}
local function short(n: number): string
 for _,v in {{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}do
  if n>=v[1]then return string.format("%.1f%s",math.floor(n/v[1]*10)/10,v[2])end
 end
 return tostring(n)
end
function HUD.mount(parent: Instance): any
 local gui=Instance.new("ScreenGui");gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="TicketHUD",false,10
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local top=Instance.new("Frame");top.Name="TopBar";top.AnchorPoint,top.Position=Vector2.new(.5,0),UDim2.new(.5,0,0,4)
 top.Size=UDim2.new(1,-24,0,34);top.BorderSizePixel,top.BackgroundColor3,top.Active=0,Color3.new(1,1,1),false;top.Parent=gui
 S.corner(top,15);S.stroke(top,3);S.gradient(top,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local stats=S.text(top,"Stats","",18,UDim2.fromOffset(8,0),UDim2.new(1,-16,0,28));stats.TextXAlignment=Enum.TextXAlignment.Center;stats.RichText=true
 local track=Instance.new("Frame");track.Name="BiomeProgress";track.Size,track.Position=UDim2.new(1,-16,0,4),UDim2.fromOffset(8,28);track.BackgroundColor3,track.BorderSizePixel,track.Active=Color3.fromHex("0E1E55"),0,false;track.Parent=top;S.corner(track,3)
 local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(0,1);fill.BackgroundColor3,fill.BorderSizePixel,fill.Active=Color3.fromHex("FFD24A"),0,false;fill.Parent=track;S.corner(fill,3)
 local function action(name: string,width: number,height: number,right: number,colors: {string}): TextButton
  local b=S.button(gui,name,name:upper(),UDim2.fromOffset(width,height),UDim2.new(1,-right,1,-86));b.AnchorPoint=Vector2.new(1,1)
  b.TextColor3=if name=="Throw"then S.INK else Color3.new(1,1,1)
  b.TextStrokeColor3,b.TextStrokeTransparency=S.INK,if name=="Throw"then 1 else .2
  S.gradient(b,Color3.fromHex(colors[1]),Color3.fromHex(colors[2]));return b
 end
 local throw=action("Throw",132,76,12,{"FFF4A0","FFD24A"});throw.TextSize=27
 local train=action("Train",88,52,156,{"D98BFF","7B2BE6"});train.TextSize=17
 local shop=action("Shop",88,52,256,{"FF86CF","E2338C"});shop.TextSize=22
 local message=S.text(gui,"Message","",16,UDim2.new(.5,0,1,-8),UDim2.new(1,-120,0,26))
 message.AnchorPoint=Vector2.new(.5,1);message.TextXAlignment=Enum.TextXAlignment.Center;message.Visible=false
 message.BackgroundTransparency=.15;message.BackgroundColor3=Color3.fromHex("16348F");S.corner(message,13)
 local function resize()
  top.Size=UDim2.fromOffset(math.min(900,gui.AbsoluteSize.X-24),34)
  stats.TextSize=if gui.AbsoluteSize.X<600 then 16 else 18
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 return {gui=gui,top=top,throw=throw,train=train,shop=shop,message=message,
  render=function(cash: number,power: number,equipped: string?,training: boolean)
   local distance=Rules.distance(power,equipped);local b=Config.Biomes[Rules.biome(distance)]
   stats.Text=string.format('CASH <font color="#B2FFAD">$%s</font>  |  POWER <font color="#FFF2A6">%s</font>  |  %s',short(cash),short(power),b.Name:upper())
   local nextIndex,need=Rules.nextBiome(power,equipped)
   if nextIndex then
    local nextBiome=Config.Biomes[nextIndex];fill.Size=UDim2.fromScale(math.clamp((distance-b.MinPower)/(nextBiome.MinPower-b.MinPower),0,1),1)
    track:SetAttribute("NextBiome",nextBiome.Name);track:SetAttribute("NeedPower",need)
   else fill.Size=UDim2.fromScale(1,1);track:SetAttribute("NextBiome","MAX");track:SetAttribute("NeedPower",0)end
   train.Text=if training then "TRAIN ON"else string.format("TRAIN +%d",Config.TrainGain)
   local gradient=train:FindFirstChildOfClass("UIGradient")::UIGradient
   gradient.Color=if training then ColorSequence.new(Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))else ColorSequence.new(Color3.fromHex("D98BFF"),Color3.fromHex("7B2BE6"))
  end}
end
return HUD
