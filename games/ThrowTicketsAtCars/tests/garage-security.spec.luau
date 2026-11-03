-- Real instances, isolated profile; no live player's data is touched.
return function(Service,Garage,Rules)
 local character=Instance.new("Model");local actor={Character=character,UserId=123}
 local tool=Instance.new("Tool");tool:SetAttribute("CarId","owned");tool.Parent=character
 local root=Instance.new("Part");local folder=Instance.new("Folder");folder:SetAttribute("OwnerId",actor.UserId)
 local data={Cars={},Cash=0};Garage.add(data,Rules.reward(1,1,1),"owned",false)
 local s={profile={Status="active"},data=data,folder=folder,positions={root.Position},tools={owned=tool}}
 local api=Service.new({mutable=function()return true end,rootOf=function()return root end,result=function()end,publish=function()end,atPlot=function()return true end})
 api.act(actor,s,"Place","owned",1,false)
 local slot=data.Cars[1].Slot
 character:Destroy();root:Destroy();folder:Destroy()
 assert(slot==0,"Direct Place cannot bypass server prompt hold")
 return "1 garage security assertion passed"
end
