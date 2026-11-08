--!strict
-- Character animations as data (R15, joint space). Each joint value: {rx, ry, rz [, ox, oy, oz]} degrees / studs.
-- Built into KeyframeSequences: Studio plays them straight away (KeyframeSequenceProvider); a published game needs
-- uploaded ids in Config.Animations (owner publishes from ServerStorage.TT_Animations with the Animation Editor).
-- Angle convention measured 08.11.2026 on the R15 rig: shoulder +X = arm forward/up (>180 = up and back),
-- right shoulder +Z = out to the side (left shoulder -Z), elbow +X = flex, torso -Y = right shoulder back.
-- NOT FINAL: tuned by eye from contact sheets.
local Anim={}
Anim.Clips={
 -- Overhand ticket throw, 1.15 s: anticipation dip, coil, release at 0.42 s, overshoot, settle.
 Throw={priority=Enum.AnimationPriority.Action,loop=false,release=.42,frames={
  {t=0,p={}},
  {t=.12,p={LowerTorso={0,-6,0,0,-.25,0},UpperTorso={8,-8,0},RightUpperArm={40,0,10},RightLowerArm={40,0,0},LeftUpperArm={40,0,-5},LeftLowerArm={20,0,0},
   LeftUpperLeg={15,0,0},LeftLowerLeg={-20,0,0},RightUpperLeg={15,0,0},RightLowerLeg={-20,0,0}}},
  {t=.3,p={LowerTorso={0,-22,0,0,-.15,.2},UpperTorso={-14,-28,0},Head={6,38,0},RightUpperArm={205,0,15},RightLowerArm={80,0,0},RightHand={-25,0,0},
   LeftUpperArm={88,0,-10},LeftLowerArm={8,0,0},LeftUpperLeg={32,0,0},LeftLowerLeg={-30,0,0},RightUpperLeg={-14,0,0},RightLowerLeg={-18,0,0}}},
  {t=.42,marker="Release",p={LowerTorso={0,14,0,0,-.1,-.3},UpperTorso={14,22,0},Head={-6,-24,0},RightUpperArm={152,0,5},RightLowerArm={12,0,0},RightHand={18,0,0},
   LeftUpperArm={30,0,-28},LeftLowerArm={40,0,0},LeftUpperLeg={36,0,0},LeftLowerLeg={-34,0,0},RightUpperLeg={-22,0,0},RightLowerLeg={-28,0,0}}},
  {t=.6,p={LowerTorso={0,26,0,0,-.25,-.45},UpperTorso={28,30,0},Head={-16,-32,0},RightUpperArm={30,0,-38},RightLowerArm={25,0,0},RightHand={10,0,0},
   LeftUpperArm={-15,0,-25},LeftLowerArm={30,0,0},LeftUpperLeg={34,0,0},LeftLowerLeg={-32,0,0},RightUpperLeg={-26,0,0},RightLowerLeg={-52,0,0}}},
  {t=.82,p={LowerTorso={0,10,0,0,-.05,-.2},UpperTorso={10,10,0},Head={-4,-10,0},RightUpperArm={15,0,-10},RightLowerArm={15,0,0},
   LeftUpperArm={5,0,-8},LeftLowerArm={10,0,0},LeftUpperLeg={10,0,0},LeftLowerLeg={-10,0,0},RightUpperLeg={-6,0,0},RightLowerLeg={-12,0,0}}},
  {t=1.15,p={}},
 }},
 -- Catch celebration, 1.5 s: dip, jump with arms in a V, land, two fist pumps.
 Cheer={priority=Enum.AnimationPriority.Action,loop=false,frames={
  {t=0,p={}},
  {t=.15,p={LowerTorso={0,0,0,0,-.6,0},UpperTorso={15,0,0},RightUpperArm={-20,0,10},LeftUpperArm={-20,0,-10},
   LeftUpperLeg={35,0,0},LeftLowerLeg={-55,0,0},RightUpperLeg={35,0,0},RightLowerLeg={-55,0,0}}},
  {t=.36,p={LowerTorso={0,0,0,0,1.3,0},UpperTorso={-8,0,0},Head={12,0,0},RightUpperArm={170,0,32},RightLowerArm={10,0,0},LeftUpperArm={170,0,-32},LeftLowerArm={10,0,0},
   LeftUpperLeg={25,0,0},LeftLowerLeg={-40,0,0},RightUpperLeg={10,0,0},RightLowerLeg={-25,0,0}}},
  {t=.56,p={LowerTorso={0,0,0,0,-.35,0},UpperTorso={8,0,0},RightUpperArm={165,0,30},LeftUpperArm={165,0,-30},
   LeftUpperLeg={22,0,0},LeftLowerLeg={-35,0,0},RightUpperLeg={22,0,0},RightLowerLeg={-35,0,0}}},
  {t=.8,p={LowerTorso={0,-10,0},UpperTorso={0,-12,0},Head={8,10,0},RightUpperArm={155,0,12},RightLowerArm={55,0,0},LeftUpperArm={25,0,-12},LeftLowerArm={30,0,0}}},
  {t=1,p={LowerTorso={0,-10,0,0,-.15,0},UpperTorso={6,-12,0},RightUpperArm={95,0,12},RightLowerArm={125,0,0},LeftUpperArm={25,0,-12},LeftLowerArm={30,0,0}}},
  {t=1.2,p={LowerTorso={0,-10,0},UpperTorso={-4,-12,0},Head={10,10,0},RightUpperArm={165,0,12},RightLowerArm={35,0,0},LeftUpperArm={25,0,-12},LeftLowerArm={30,0,0}}},
  {t=1.5,p={}},
 }},
 -- Training loop, 1.25 s: alternating dumbbell curls with a small knee bounce on each curl.
 Train={priority=Enum.AnimationPriority.Action,loop=true,frames={
  {t=0,p={RightUpperArm={-5,0,8},LeftUpperArm={-5,0,-8},RightLowerArm={15,0,0},LeftLowerArm={15,0,0}}},
  {t=.31,p={LowerTorso={0,0,0,0,-.2,0},UpperTorso={6,0,0},RightUpperArm={10,0,8},RightLowerArm={135,0,0},RightHand={20,0,0},LeftUpperArm={-5,0,-8},LeftLowerArm={15,0,0},
   LeftUpperLeg={12,0,0},LeftLowerLeg={-18,0,0},RightUpperLeg={12,0,0},RightLowerLeg={-18,0,0}}},
  {t=.62,p={RightUpperArm={-5,0,8},LeftUpperArm={-5,0,-8},RightLowerArm={15,0,0},LeftLowerArm={15,0,0}}},
  {t=.94,p={LowerTorso={0,0,0,0,-.2,0},UpperTorso={6,0,0},LeftUpperArm={10,0,-8},LeftLowerArm={135,0,0},LeftHand={20,0,0},RightUpperArm={-5,0,8},RightLowerArm={15,0,0},
   LeftUpperLeg={12,0,0},LeftLowerLeg={-18,0,0},RightUpperLeg={12,0,0},RightLowerLeg={-18,0,0}}},
  {t=1.25,p={RightUpperArm={-5,0,8},LeftUpperArm={-5,0,-8},RightLowerArm={15,0,0},LeftLowerArm={15,0,0}}},
 }},
 -- Carrying a caught car: both arms forward under it. Arms only, so walking still animates the legs.
 HoldCar={priority=Enum.AnimationPriority.Action,loop=true,partial={"RightUpperArm","RightLowerArm","LeftUpperArm","LeftLowerArm"},frames={
  {t=0,p={RightUpperArm={88,0,-12},RightLowerArm={18,0,0},LeftUpperArm={88,0,12},LeftLowerArm={18,0,0}}},
  {t=1,p={RightUpperArm={92,0,-12},RightLowerArm={14,0,0},LeftUpperArm={92,0,12},LeftLowerArm={14,0,0}}},
 }},
}
local TREE={HumanoidRootPart={LowerTorso={UpperTorso={Head={},RightUpperArm={RightLowerArm={RightHand={}}},LeftUpperArm={LeftLowerArm={LeftHand={}}}},
 RightUpperLeg={RightLowerLeg={RightFoot={}}},LeftUpperLeg={LeftLowerLeg={LeftFoot={}}}}}}
function Anim.build(name: string): KeyframeSequence?
 local clip=Anim.Clips[name];if not clip then return nil end
 local only: {[string]: boolean}?=nil
 if clip.partial then local set={};for _,j in clip.partial do set[j]=true end;only=set end
 local seq=Instance.new("KeyframeSequence");seq.Name=name;seq.Loop=clip.loop;seq.Priority=clip.priority
 for _,frame in clip.frames do
  local kf=Instance.new("Keyframe");kf.Time=frame.t
  local function add(parent: Instance,joint: string,children: any)
   local pose=Instance.new("Pose");pose.Name=joint
   local r=frame.p[joint]
   pose.CFrame=if r then CFrame.new(r[4]or 0,r[5]or 0,r[6]or 0)*CFrame.Angles(math.rad(r[1]),math.rad(r[2]),math.rad(r[3]))else CFrame.identity
   pose.EasingStyle=Enum.PoseEasingStyle.Cubic;pose.EasingDirection=Enum.PoseEasingDirection.InOut
   pose.Weight=if joint=="HumanoidRootPart"or(only and not only[joint])then 0 else 1;pose.Parent=parent
   for child,grand in children do add(pose,child,grand)end
  end
  for joint,children in TREE do add(kf,joint,children)end
  if frame.marker then local m=Instance.new("KeyframeMarker");m.Name=frame.marker;m.Parent=kf end
  kf.Parent=seq
 end
 return seq
end
return Anim
