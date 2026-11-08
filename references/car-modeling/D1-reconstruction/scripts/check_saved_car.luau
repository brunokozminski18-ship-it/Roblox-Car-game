-- Read-only verification after reopening a locally saved D1 project.
local model = workspace:FindFirstChild("D1_Rebuilt_From_Analysis")
assert(model and model:GetAttribute("AuthoredFromMeasurements"))
local count, welds, visible = 0, 0, 0
local ids = {}
for _, part in model:GetChildren() do
    if part:IsA("MeshPart") and part:GetAttribute("OwnGeometry") then
        local index = part:GetAttribute("SourcePartIndex")
        assert(not ids[index], "Duplicate part index")
        ids[index] = true
        count += 1
        if part.Transparency < 1 then visible += 1 end
    end
end
for _, joint in model.Handle:GetChildren() do
    if joint:IsA("Weld") then
        assert(joint.Part1 and joint.Part1.Parent == model, "Missing rebuilt weld target")
        welds += 1
    end
end
assert(count == 29 and welds == 29)
local display = model:FindFirstChild("PortableDisplay")
if display then assert(#display:GetChildren() == 29) else assert(visible == 29) end
return {meshParts=count, welds=welds, visibleMeshParts=visible, displayGroups=display and #display:GetChildren() or 0}
