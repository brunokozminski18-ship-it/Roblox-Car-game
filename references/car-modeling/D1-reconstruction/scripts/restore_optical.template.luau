-- Local, independently fitted geometry. The payload contains only the new mesh.
local encoding = game:GetService("EncodingService")
local assetService = game:GetService("AssetService")
local http = game:GetService("HttpService")
local payload = "__PAYLOAD__"

return function(model)
    model = model or script.Parent
    assert(model:GetAttribute("AuthoredFromMeasurements"), "Expected D1 reconstruction")
    local raw = encoding:DecompressBuffer(encoding:Base64Decode(buffer.fromstring(payload)), Enum.CompressionAlgorithm.Zstd)
    local rows = http:JSONDecode(buffer.tostring(raw))
    assert(#rows == 29)
    local staging = Instance.new("Folder")
    local keep = {}
    local ok, err = pcall(function()
        for _, p in rows do
            local mesh = assert(assetService:CreateEditableMesh())
            table.insert(keep, mesh)
            local ids = {}
            for _, v in p.vertices do
                table.insert(ids, mesh:AddVertex(Vector3.new(v[1], v[3], v[2])))
            end
            for i,t in p.triangles do
                local f = mesh:AddTriangle(ids[t[1]+1], ids[t[3]+1], ids[t[2]+1])
                local n = p.normals[i]
                local normal = Vector3.new(n[1], n[3], n[2])
                if normal.Magnitude > .001 then
                    local ni = mesh:AddNormal(normal.Unit)
                    mesh:SetFaceNormals(f, {ni,ni,ni})
                end
            end
            local part = assetService:CreateMeshPartAsync(Content.fromObject(mesh), {
                CollisionFidelity=Enum.CollisionFidelity.Box,
                RenderFidelity=Enum.RenderFidelity.Performance,
            })
            part.Name = string.format("%02d | %s", p.index, p.name)
            part.Anchored = true
            part.CanTouch = false
            part.CanQuery = false
            part.CanCollide = false
            part.CastShadow = false
            part.DoubleSided = true
            part.Color = Color3.fromHex(p.color)
            part.Material = Enum.Material[p.material]
            part.Reflectance = p.reflectance
            part.CFrame = model.Handle.CFrame * CFrame.new(p.centre[1], p.centre[3]-2.655180454, p.centre[2])
            part:SetAttribute("OwnGeometry", true)
            part:SetAttribute("SourcePartIndex", p.index)
            part:SetAttribute("TriangleCount", #p.triangles)
            part.Parent = staging
        end
    end)
    if not ok then
        staging:Destroy()
        for _, mesh in keep do mesh:Destroy() end
        error(err)
    end
    local replacements = {}
    for _,part in staging:GetChildren() do replacements[part:GetAttribute("SourcePartIndex")] = part end
    local previous = {}
    for _,p in model:GetChildren() do
        if p:IsA("MeshPart") and p:GetAttribute("OwnGeometry") then
            previous[p:GetAttribute("SourcePartIndex")] = p
        end
    end
    for _,weld in model.Handle:GetChildren() do
        if weld:IsA("Weld") and weld.Part1 then
            local fresh = replacements[weld.Part1:GetAttribute("SourcePartIndex")]
            if fresh then
                weld.Part1 = fresh
                weld.C0 = model.Handle.CFrame:ToObjectSpace(fresh.CFrame)
                weld.C1 = CFrame.identity
            end
        end
    end
    for _,fresh in replacements do fresh.Parent = model end
    for _,old in previous do old:Destroy() end
    staging:Destroy()
    local fallback = model:FindFirstChild("PortableDisplay")
    if fallback then fallback:Destroy() end
    return model, keep
end
