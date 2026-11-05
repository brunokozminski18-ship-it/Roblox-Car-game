--!strict
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local S=require(script.Parent.Style)
local UI={}
local titles={MostCars="Most Cars",TopMoney="Top Money",LuckiestCatch="Luckiest Catch"}
local cache={};local cacheCount=0
local function short(n: number): string
 for _,u in {{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}do if n>=u[1]then return string.format("%.1f%s",math.floor(n/u[1]*10)/10,u[2])end end
 return tostring(math.floor(n))
end
function UI.mount(world: Instance)
 local folder=world:WaitForChild("Leaderboards")
 for name,title in titles do
  task.spawn(function()
   local part=folder:WaitForChild(name)
   local gui=Instance.new("SurfaceGui");gui.Name="BoardDisplay";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(650,850);gui.LightInfluence=0;gui.MaxDistance=110;gui.Parent=part
   local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BorderSizePixel=0;bg.BackgroundColor3=Color3.new(1,1,1);bg.Parent=gui;S.gradient(bg,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"));S.corner(bg,24);S.stroke(bg,5)
   local heading=S.text(bg,"Title",title,46,UDim2.fromOffset(16,12),UDim2.new(1,-32,0,60));heading.TextXAlignment=Enum.TextXAlignment.Center
   local subtitle=S.text(bg,"Refresh","Updates every minute",24,UDim2.fromOffset(16,74),UDim2.new(1,-32,0,30));subtitle.TextXAlignment=Enum.TextXAlignment.Center
   local status=S.text(bg,"Status","",18,UDim2.new(0,16,1,-32),UDim2.new(1,-32,0,24));status.TextXAlignment=Enum.TextXAlignment.Center
   local rows={}
   for i=1,10 do
    local row=Instance.new("Frame");row.Name="Rank"..i;row.Position=UDim2.fromOffset(18,114+(i-1)*68);row.Size=UDim2.new(1,-36,0,62);row.BackgroundColor3=Color3.fromHex("112B70");row.BackgroundTransparency=.25;row.BorderSizePixel=0;row.Parent=bg;S.corner(row,12)
    local rank=S.text(row,"Rank",tostring(i),27,UDim2.fromOffset(6,0),UDim2.fromOffset(42,62));rank.TextColor3=if i<=3 then Color3.fromHex("FFD24A")else Color3.new(1,1,1)
    local avatar=Instance.new("ImageLabel");avatar.Name="Avatar";avatar.Size=UDim2.fromOffset(54,54);avatar.Position=UDim2.fromOffset(48,4);avatar.BackgroundTransparency=1;avatar.Parent=row
    local player=S.text(row,"Player","—",25,UDim2.fromOffset(112,0),UDim2.new(.55,-100,1,0));player.TextTruncate=Enum.TextTruncate.AtEnd
    local value=S.text(row,"Value","",26,UDim2.new(.55,12,0,0),UDim2.new(.45,-22,1,0));value.TextXAlignment=Enum.TextXAlignment.Right;value.TextColor3=Color3.fromHex("FFF4A0")
    rows[i]={Avatar=avatar,Player=player,Value=value}
   end
   local revision=0
   local function refresh()
    revision+=1;local version=revision
    local ok,data=pcall(Http.JSONDecode,Http,part:GetAttribute("Rows")or "[]");if not ok or typeof(data)~="table"then return end
    status.Text=part:GetAttribute("Mode")or ""
    for i,row in rows do
     local entry=data[i];row.Avatar.Image="";row.Player.Text=if entry then "Player "..entry.UserId else "—";row.Value.Text=""
     if entry then
      row.Value.Text=(if entry.Approximate then "≈"else "")..(if name=="TopMoney"then "$"elseif name=="LuckiestCatch"then "1 in "else "")..short(entry.Value)
      task.spawn(function()
       local info=cache[entry.UserId]
       if not info then
        local thumbOk,url,ready=pcall(Players.GetUserThumbnailAsync,Players,entry.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        local nameOk,playerName=pcall(Players.GetNameFromUserIdAsync,Players,entry.UserId)
        info={Image=if thumbOk then url else "",Name=if nameOk then playerName else "Player "..entry.UserId}
        if thumbOk and ready and nameOk then
         if cacheCount>=256 then table.clear(cache);cacheCount=0 end
         cache[entry.UserId]=info;cacheCount+=1
        end
       end
       if gui.Parent and version==revision then row.Avatar.Image=info.Image;row.Player.Text=info.Name end
      end)
     end
    end
   end
   part:GetAttributeChangedSignal("Rows"):Connect(refresh);part:GetAttributeChangedSignal("Mode"):Connect(refresh);refresh()
  end)
 end
end
return UI
