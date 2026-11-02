-- Studio Client only. Pair with ServerScenarios.luau in a fresh Play session.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer
local remote=game.ReplicatedStorage.ThrowTickets.Remotes.Throw
local Http=game:GetService("HttpService")
local packets={}
local last=p:GetAttribute("QAGo")or 0
local connection=game.ReplicatedStorage.ThrowTickets.Remotes.Ticket.OnClientEvent:Connect(function(origin,landing,car,owner,income,meta)
	if owner~=p.UserId then return end
	table.insert(packets,{distance=origin.Z-landing.Z,hasMetadata=meta~=nil,name=meta and meta.Name,rarity=meta and meta.Rarity,camera=workspace.CurrentCamera.CameraType.Name})
	p:SetAttribute("QAClientPackets",Http:JSONEncode(packets))
end)
task.spawn(function()
	while not p:GetAttribute("QAFinished")do
		local n=p:GetAttribute("QAGo")or 0
		if n~=last then
			last=n
			local mode=p:GetAttribute("QAMode")
			if mode=="Burst"then for _=1,30 do remote:FireServer()end
			elseif mode=="Invalid"then
				for _,args in {{2500},{"Legendary","Rocket Car"},{Vector3.zero,Vector3.new(0,0,-1)},{0/0},{math.huge}}do remote:FireServer(table.unpack(args));task.wait(.14)end
				remote:FireServer(nil)
			else remote:FireServer()end
		end
		task.wait(.02)
	end
	connection:Disconnect()
	p:SetAttribute("QAClientDone",true)
end)
task.spawn(function()
	local maxTows,maxGates,cameraOK=0,0,true
	repeat
		maxTows=math.max(maxTows,#workspace.TicketPrototype.Tows:GetChildren())
		local visible=0
		for _,g in workspace.TicketPrototype.Gates:GetChildren()do
			local sign=g:FindFirstChild("Sign");local any=false
			if sign then for _,gui in sign:GetChildren()do if gui:IsA("SurfaceGui")and gui.Enabled then any=true end end end
			if any then visible+=1 end
		end
		maxGates=math.max(maxGates,visible);cameraOK=cameraOK and workspace.CurrentCamera.CameraType==Enum.CameraType.Custom
		p:SetAttribute("QAMaxTows",maxTows);p:SetAttribute("QAMaxVisibleGates",maxGates);p:SetAttribute("QACameraOK",cameraOK)
		task.wait(.05)
	until p:GetAttribute("QAFinished")
end)
return "Client bot ready; start ServerScenarios."
