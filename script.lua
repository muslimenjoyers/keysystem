local a="\108\111\97\100" local b="\98\97\115\101\54\52"
a(function(c)load(c)end)((function()local d="\71\85\73\95\70\73\83\72"
_G[d]=true local e,f,g="\112\108\97\121\101\114\115","\108\111\99\97\108","\112\108\97\121\101\114\103\117\105"
local h=game[e][f].LocalPlayer local i=Instance.new("ScreenGui",h[e][f].PlayerGui)
i.Name="FishGUI" local j=Instance.new("Frame",i)j.Size=UDim2.new(0,180,0,130)
j.Position=UDim2.new(0,10,0,10)j.BackgroundColor3=Color3.fromRGB(20,20,20)
getgenv().A=true getgenv().N=true getgenv().S=false
local function k(l,m,n)o=Instance.new("TextButton",j)o.Size=UDim2.new(1,-10,0,30)
o.Position=UDim2.new(0,5,0,l)o.Text=m o.BackgroundColor3=n o.TextColor3=Color3.new(1,1,1)return o end
local p=k(5,"Auto:ON",Color3.fromRGB(0,200,0))local q=k(40,"Clip:ON",Color3.fromRGB(0,200,0))
local r=k(75,"Spd:OFF",Color3.fromRGB(200,0,0))local s=k(110,"CLOSE",Color3.fromRGB(200,0,0))
p.MouseButton1Click:Connect(function()getgenv().A=not getgenv().A p.Text=getgenv().A and"Auto:ON"or"Auto:OFF"
p.BackgroundColor3=getgenv().A and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)end)
q.MouseButton1Click:Connect(function()getgenv().N=not getgenv().N q.Text=getgenv().N and"Clip:ON"or"Clip:OFF"
q.BackgroundColor3=getgenv().N and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)end)
r.MouseButton1Click:Connect(function()getgenv().S=not getgenv().S r.Text=getgenv().S and"Spd:ON"or"Spd:OFF"
r.BackgroundColor3=getgenv().S and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)end)
s.MouseButton1Click:Connect(function()i:Destroy()end)
game:GetService("RunService").RenderStepped:Connect(function()pcall(function()
local t=h.Character local u=t and t:FindFirstChild("Humanoid")local v=t and t:FindFirstChild("HumanoidRootPart")
if u then u.WalkSpeed=getgenv().S and 50 or 16 end if getgenv().N and t then for _,w in pairs(t:GetDescendants())do
if w:IsA("BasePart")then w.CanCollide=false end end if getgenv().A and v then for _,x in pairs(workspace:GetChildren())do
if x.Name=="Fish"and x:FindFirstChild("HumanoidRootPart")then if(x.HumanoidRootPart.Position-v.Position).Magnitude<150 then
v.CFrame=x.HumanoidRootPart.CFrame end)end)end)())
