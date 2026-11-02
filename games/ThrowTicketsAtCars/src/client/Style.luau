--!strict
-- Shared primitives for the shop sample and its matching HUD.
local Tween=game:GetService("TweenService")
local INK=Color3.fromHex("14102A")
local FONT=Enum.Font.FredokaOne
local Motion={press=TweenInfo.new(.12),open=TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),pulse=TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true)}
local function corner(o: Instance,r: number)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=o end
local function stroke(o: Instance,n: number,color: Color3?)local s=Instance.new("UIStroke");s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Thickness,s.Color=n,color or INK;s.Parent=o;return s end
local function gradient(o: Instance,a: Color3,b: Color3)local g=Instance.new("UIGradient");g.Rotation,g.Color=90,ColorSequence.new(a,b);g.Parent=o;return g end
local function text(parent: Instance,name: string,value: string,size: number,pos: UDim2,dim: UDim2): TextLabel
 local t=Instance.new("TextLabel");t.Name,t.Text,t.TextSize=name,value,size;t.Font=FONT
 t.Size,t.Position,t.BackgroundTransparency=dim,pos,1;t.TextColor3=Color3.new(1,1,1);t.TextStrokeColor3,t.TextStrokeTransparency=INK,.15
 t.TextXAlignment=Enum.TextXAlignment.Left;t.Active=false;t.Parent=parent;return t
end
local function button(parent: Instance,name: string,caption: string,size: UDim2,pos: UDim2): TextButton
 local b=Instance.new("TextButton");b.Name,b.Text,b.Size,b.Position=name,caption,size,pos
 b.Font,b.TextSize=FONT,20;b.TextColor3,b.BackgroundColor3=INK,Color3.new(1,1,1)
 b.BorderSizePixel,b.AutoButtonColor=0,false;corner(b,999);stroke(b,3);b.Parent=parent
 -- Gradients tint a TextButton's own glyphs too. Keep the caption in a child.
 b.TextTransparency=1
 local captionLabel=Instance.new("TextLabel");captionLabel.Name="Caption";captionLabel.Size=UDim2.fromScale(1,1);captionLabel.BackgroundTransparency=1;captionLabel.Active=false;captionLabel.Parent=b
 local function syncCaption()
  for _,property in {"Text","Font","TextSize","TextColor3","TextStrokeColor3","TextStrokeTransparency","TextYAlignment"}do (captionLabel::any)[property]=(b::any)[property]end
 end
 for _,property in {"Text","TextSize","TextColor3","TextStrokeColor3","TextStrokeTransparency","TextYAlignment"}do b:GetPropertyChangedSignal(property):Connect(syncCaption)end
 syncCaption()
 local scale=Instance.new("UIScale");scale.Parent=b
 b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Tween:Create(scale,Motion.press,{Scale=.96}):Play()end end)
 b.InputEnded:Connect(function()Tween:Create(scale,Motion.press,{Scale=1}):Play()end)
 return b
end

return {INK=INK,FONT=FONT,Motion=Motion,corner=corner,stroke=stroke,gradient=gradient,text=text,button=button}
