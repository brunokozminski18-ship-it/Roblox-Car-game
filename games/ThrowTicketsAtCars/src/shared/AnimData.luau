--!strict
-- Character animations as data (R15 joint rotations in degrees, joint space). Built into KeyframeSequences:
-- in Studio they play straight away (KeyframeSequenceProvider), in a published game they need an uploaded id in
-- Config.Animations (owner publishes via the Animation Editor). Angle convention measured 08.11.2026 on the R15 rig:
-- shoulder +X = arm forward/up (>180 = up and back), elbow +X = flex, torso -Y = right shoulder back.
-- NOT FINAL: angles tuned by eye from contact sheets.
local Anim={}
export type Frame={t: number,marker: string?,p: {[string]: {number}}}
Anim.Clips={
 -- Overhand ticket throw, 0.95 s; "Release" at 0.42 s matches the ticket leaving the hand.
 Throw={priority=Enum.AnimationPriority.Action,loop=false,release=.42,frames={
  {t=0,p={}},
  {t=.3,p={LowerTorso={0,-20,0},UpperTorso={-12,-25,0},Head={6,35,0},RightUpperArm={200,0,15},RightLowerArm={75,0,0},RightHand={-20,0,0},LeftUpperArm={85,0,-10},LeftLowerArm={10,0,0},LeftUpperLeg={30,0,0},LeftLowerLeg={-28,0,0},RightUpperLeg={-14,0,0},RightLowerLeg={-18,0,0}}},
  {t=.42,marker="Release",p={LowerTorso={0,12,0},UpperTorso={12,20,0},Head={-6,-22,0},RightUpperArm={150,0,5},RightLowerArm={15,0,0},RightHand={15,0,0},LeftUpperArm={30,0,-25},LeftLowerArm={35,0,0},LeftUpperLeg={34,0,0},LeftLowerLeg={-32,0,0},RightUpperLeg={-20,0,0},RightLowerLeg={-22,0,0}}},
  {t=.62,p={LowerTorso={0,22,0},UpperTorso={24,25,0},Head={-14,-28,0},RightUpperArm={50,0,-25},RightLowerArm={20,0,0},LeftUpperArm={-12,0,-22},LeftLowerArm={25,0,0},LeftUpperLeg={30,0,0},LeftLowerLeg={-28,0,0},RightUpperLeg={-20,0,0},RightLowerLeg={-25,0,0}}},
  {t=.95,p={}},
 }},
}
local TREE={HumanoidRootPart={LowerTorso={UpperTorso={Head={},RightUpperArm={RightLowerArm={RightHand={}}},LeftUpperArm={LeftLowerArm={LeftHand={}}}},
 RightUpperLeg={RightLowerLeg={RightFoot={}}},LeftUpperLeg={LeftLowerLeg={LeftFoot={}}}}}}
function Anim.build(name: string): KeyframeSequence?
 local clip=Anim.Clips[name];if not clip then return nil end
 local seq=Instance.new("KeyframeSequence");seq.Name=name;seq.Loop=clip.loop;seq.Priority=clip.priority
 for _,frame in clip.frames do
  local kf=Instance.new("Keyframe");kf.Time=frame.t
  local function add(parent: Instance,joint: string,children: any)
   local pose=Instance.new("Pose");pose.Name=joint
   local r=frame.p[joint];pose.CFrame=if r then CFrame.Angles(math.rad(r[1]),math.rad(r[2]),math.rad(r[3]))else CFrame.identity
   pose.EasingStyle=Enum.PoseEasingStyle.Cubic;pose.EasingDirection=Enum.PoseEasingDirection.InOut
   pose.Weight=if joint=="HumanoidRootPart"then 0 else 1;pose.Parent=parent
   for child,grand in children do add(pose,child,grand)end
  end
  for joint,children in TREE do add(kf,joint,children)end
  if frame.marker then local m=Instance.new("KeyframeMarker");m.Name=frame.marker;m.Parent=kf end
  kf.Parent=seq
 end
 return seq
end
return Anim
