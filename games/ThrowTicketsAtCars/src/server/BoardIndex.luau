--!strict
-- Ordered stores are indexes. Budgeted, coalesced writes; last good reads survive failures.
local Index={}
local Codec=require(script.Parent.BoardCodec)
function Index.new(stores: any,budget: (string) -> number,reserve: number,monotonic: any?,versioned: any?): any
 local api={cache={},pending={},written={},writtenGeneration={},inFlight={}};local nextWrite=0
 function api.queue(userId: number,scores: any,generation: number?)
  for name,value in scores do
   local key=name..":"..userId
   local integer=math.clamp(math.floor(value),0,9007199254740991)
   local version=generation or 0
   if api.written[key]~=integer or(versioned and versioned[name]and api.writtenGeneration[key]~=version)or api.inFlight[key]then
    api.pending[key]={Name=name,Id=userId,Value=integer,Generation=version}
   else api.pending[key]=nil end
  end
 end
 function api.write(now: number): boolean
  if now<nextWrite or budget("write")<=reserve then return false end
  local key,item=next(api.pending);if not item then return false end
  local isRecord=monotonic and monotonic[item.Name]
  local isVersioned=versioned and versioned[item.Name]
  if (isRecord or isVersioned)and budget("read")<=reserve then return false end
  nextWrite=now+1 -- stagger requests, never a burst for all players/boards
  api.inFlight[key]=item
  local ok=pcall(function()
   if isVersioned then
    local packed=Codec.pack(item.Name,item.Value,item.Generation)
    stores[item.Name]:UpdateAsync("u_"..item.Id,function(old)
     if typeof(old)=="number"then local _,generation=Codec.unpack(item.Name,old);if generation>item.Generation then return nil end end
     return packed
    end)
   elseif isRecord then
    stores[item.Name]:UpdateAsync("u_"..item.Id,function(old)return math.max(if typeof(old)=="number"then old else 0,item.Value)end)
   else stores[item.Name]:SetAsync("u_"..item.Id,item.Value)end
  end)
  api.inFlight[key]=nil
  if ok then
   api.written[key]=item.Value
   api.writtenGeneration[key]=item.Generation
   if api.pending[key]and api.pending[key].Value==item.Value and api.pending[key].Generation==item.Generation then api.pending[key]=nil end
  else nextWrite=now+10 end
  return ok
 end
 function api.reconcile(userId: number,scores: any,count: number,generation: number?)
  -- Reuse the minute's global read to repair an out-of-order write from an old server.
  -- No per-player GetAsync. Only discrepancies that can affect the visible top N write again.
  for name,value in scores do
   local rows=api.cache[name]
   if rows then
    local found=nil;for _,row in rows do if row.UserId==userId then found=row.Value;break end end
    local tolerance=if name=="TopMoney"and value>1e6 then value*.000003 else 0
    if (found~=nil and math.abs(found-value)>tolerance)or(found==nil and value>0 and(#rows<count or value>rows[#rows].Value))then
     api.written[name..":"..userId]=nil;api.queue(userId,{[name]=value},generation)
    end
   end
  end
 end
 function api.read(name: string,count: number): (any,boolean)
  if budget("list")<=reserve then return api.cache[name],false end
  local ok,rows=pcall(function()
   local entries=stores[name]:GetSortedAsync(false,count):GetCurrentPage();local clean={}
   for _,e in entries do
    local id=tonumber(string.match(e.key,"^u_(%d+)$"))
    if id and id>0 and typeof(e.value)=="number"and e.value>=0 then
     local value,_,approximate=e.value,0,false
     if versioned and versioned[name]then value,_,approximate=Codec.unpack(name,e.value)end
     table.insert(clean,{UserId=id,Value=value,Approximate=approximate})
    end
   end
   return clean
  end)
  if ok then api.cache[name]=rows end
  return api.cache[name],ok
 end
 return api
end
return Index
