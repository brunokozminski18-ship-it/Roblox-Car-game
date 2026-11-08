--!strict
-- LihFolk Vault V2 (CC BY 4.0): OrderedDataStores and Leaderboards.
local DS=game:GetService("DataStoreService")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local R=require(RS.ThrowTickets.ReturnRules)
local Config=require(RS.ThrowTickets.Config)
local Index=require(script.Parent.BoardIndex)
local Boards={}
local names={"MostCars","TopMoney","LuckiestCatch"}
function Boards.new(world: Instance,states: any): any
 local folder=Instance.new("Folder");folder.Name="Leaderboards";folder.Parent=world
 -- On the left cliff face, facing the plaza (map v5).
 for i,name in names do
  local part=Instance.new("Part");part.Name=name;part.Size=Vector3.new(13,17,.6);part.CFrame=CFrame.new(-140+(i-1)*15,14,.8)*CFrame.Angles(0,math.pi,0);part.Anchored=true;part.Color=Color3.fromHex("214EAB");part.Parent=folder
  local post=Instance.new("Part");post.Name=name.."Post";post.Size=Vector3.new(1,5.5,.8);post.Position=Vector3.new(-140+(i-1)*15,2.75,.8);post.Anchored=true;post.Parent=folder
 end
 local studio=Run:IsStudio();local qaKey=game.ServerStorage:GetAttribute("TestProfileKey")
 local suffix=if studio then "_STUDIO_"..(if typeof(qaKey)=="string"then qaKey else "TEST")else ""
 local stores={};for _,name in names do stores[name]=DS:GetOrderedDataStore(Config.Boards.StorePrefix..suffix.."_"..name)end
 local index=Index.new(stores,function(kind)
  return DS:GetRequestBudgetForRequestType(if kind=="list"then Enum.DataStoreRequestType.OrderedList elseif kind=="read"then Enum.DataStoreRequestType.OrderedRead else Enum.DataStoreRequestType.OrderedWrite)
 end,Config.Boards.BudgetReserve,{LuckiestCatch=true},{MostCars=true,TopMoney=true})
 local function scores(s)
  if s.profile.Status~="active"and s.profile.Status~="closing"then return nil end
  return R.scores(s.data)
 end
 local function queue(p,s)
  if s.rewardBusy or s.rewardFailed then return end
  if studio and not string.match(s.profile.Key,"^QA_")then return end
  local values=scores(s);if values then index.queue(p.UserId,values,s.profile.Generation)end
 end
 local function fallback(name)
  local rows={};for p,s in states do local v=scores(s);if v and not s.rewardFailed then table.insert(rows,{UserId=p.UserId,Value=v[name]})end end
  table.sort(rows,function(a,b)return if a.Value==b.Value then a.UserId<b.UserId else a.Value>b.Value end)
  while #rows>Config.Boards.Count do table.remove(rows)end;return rows
 end
 local function show(name,rows,mode)
  local part=folder[name];part:SetAttribute("Rows",Http:JSONEncode(rows));part:SetAttribute("Mode",mode)
 end
 local api={};local writeAt={};local due={};local boot=os.clock()+math.random()*3
 for i,name in names do due[name]=boot+(i-1)*20;show(name,{},"Loading rankings...")end
 function api.leaving(p,s)queue(p,s);writeAt[p]=nil end
 function api.qa(fixtures)
  if not studio or typeof(qaKey)~="string"then return false end
  if fixtures=="Refresh"then for _,name in names do due[name]=os.clock()end;return true end
  if typeof(fixtures)~="table"then return false end
  for _,row in fixtures do
   if typeof(row)=="table"and typeof(row.UserId)=="number"and row.UserId>0 then
    local valid=true;for _,name in names do local v=row[name];if typeof(v)~="number"or v~=v or v<0 or v>Config.MaxCash then valid=false end end
    if valid then index.queue(row.UserId,{MostCars=row.MostCars,TopMoney=row.TopMoney,LuckiestCatch=row.LuckiestCatch},0)end
   end
  end;return true
 end
 task.spawn(function()
  while folder.Parent do
   local now=os.clock()
   for p,s in states do if now>=(writeAt[p]or 0)and p:GetAttribute("DataReady")==true then queue(p,s);writeAt[p]=now+Config.Boards.WriteSeconds end end
   index.write(now)
   for _,name in names do if now>=due[name]then
    due[name]=now+Config.Boards.RefreshSeconds
    local rows,ok=index.read(name,Config.Boards.Count)
    show(name,rows or fallback(name),if ok then "Global ranking"elseif rows then "Cached ranking"else "This server • global ranking unavailable")
    if ok then for p,s in states do if p:GetAttribute("DataReady")==true and not s.rewardBusy and not s.rewardFailed then
     local values=scores(s);if values then index.reconcile(p.UserId,{[name]=values[name]},Config.Boards.Count,s.profile.Generation)end
    end end end
    -- Reads start twenty seconds apart; no per-player or per-row store calls.
   end end
   task.wait(1)
  end
 end)
 return api
end
return Boards
