-- Edit-only MCP fallback; consumes the output of Rojo, never a second source tree.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local Http = game:GetService("HttpService")
local snapshot = Http:JSONDecode(Http:GetAsync("http://127.0.0.1:34874/assets/snapshot.json"))
assert(game.PlaceId == snapshot.placeId, "Wrong place")
local count = 0
local function sync(parent, node)
	local object = parent:FindFirstChild(node.name)
	if object then assert(object.ClassName == node.className, "Class mismatch: " .. node.name)
	else object = Instance.new(node.className); object.Name = node.name; object.Parent = parent end
	for property,value in node.properties do object[property] = value end
	if node.source then
		object.Source = node.source
		assert(object.Source == node.source, "Source mismatch: " .. node.name)
		count += 1
	end
	for _,child in node.children do sync(object, child) end
end
for _,service in snapshot.roots do
	local target = game:GetService(service.className)
	for property,value in service.properties do target[property] = value end
	for _,node in service.children do sync(target, node) end
end
return "Synced " .. count .. " scripts from Rojo build; unmanaged world preserved."
