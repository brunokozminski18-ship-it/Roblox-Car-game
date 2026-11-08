--!strict
-- Plays AnimData clips on the local character. Uploaded ids from Config.Animations win; in Studio an unpublished
-- clip is registered locally so it can be judged before upload. Returns nil when no clip can play (callers fall back).
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.ThrowTickets.Config)
local AnimData=require(RS.ThrowTickets.AnimData)
local M={}
local ids: {[string]: string}={}
local tracks: {[Animator]: {[string]: AnimationTrack}}={}
local function idFor(name: string): string?
 if ids[name]then return ids[name]end
 local uploaded=(Config.Animations or {})[name]
 if typeof(uploaded)=="string"and uploaded~=""then ids[name]=uploaded;return uploaded end
 if not RunService:IsStudio()then return nil end
 local seq=AnimData.build(name);if not seq then return nil end
 local ok,id=pcall(function()return game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(seq)end)
 if ok then ids[name]=id;return id end
 return nil
end
function M.track(name: string): AnimationTrack?
 local character=Players.LocalPlayer.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local animator=humanoid and humanoid:FindFirstChildOfClass("Animator")
 if not animator then return nil end
 local cache=tracks[animator];if not cache then cache={};tracks[animator]=cache;animator.AncestryChanged:Connect(function()if not animator:IsDescendantOf(game)then tracks[animator]=nil end end)end
 if cache[name]then return cache[name]end
 local id=idFor(name);if not id then return nil end
 local a=Instance.new("Animation");a.AnimationId=id
 local ok,track=pcall(function()return animator:LoadAnimation(a)end)
 if not ok then return nil end
 cache[name]=track
 return track
end
-- Starts a clip so that its "release" moment lands `untilRelease` seconds from now.
function M.playTimed(name: string,untilRelease: number): boolean
 local clip=AnimData.Clips[name];local track=M.track(name)
 if not clip or not track then return false end
 track:Play(.05)
 track.TimePosition=math.max(0,(clip.release or 0)-untilRelease)
 return true
end
return M
