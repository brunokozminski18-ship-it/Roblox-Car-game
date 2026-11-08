-- Edit-time round trip for an independently authored MeshPart. No cloud upload.
return function(part)
    assert(part:IsA("MeshPart") and part:GetAttribute("OwnGeometry"), "Choose an authored test part")
    local serializer = game:GetService("SerializationService")
    local data = serializer:SerializeInstancesAsync({part})
    local copies = serializer:DeserializeInstancesAsync(data)
    local copy = copies[1]
    local result = {
        class = copy.ClassName,
        before = tostring(part.MeshContent.SourceType),
        after = tostring(copy.MeshContent.SourceType),
        bytes = buffer.len(data),
    }
    for _,item in copies do item:Destroy() end
    return result
end
