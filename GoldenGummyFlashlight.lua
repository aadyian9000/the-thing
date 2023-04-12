local Tool = game:GetObjects("rbxassetid://13106101212")[1]
Tool.Parent = game.Players.LocalPlayer.Backpack

-- VARIABLES

local GUMMY_DECREASE_SPEED = 0.2 -- How fast it will decrease light.
local GUMMY_INCREASE_RATE = 9 -- How much it will increase on shake.
local GUMMY_SHAKE_COOLDOWN = 0.2 -- How fast you can shake your gummy flashlight

-- CODE

local u2 = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)

local Player = game.Players.LocalPlayer
local Humanoid = Player.Character:WaitForChild("Humanoid")

local Equipped = false

local AnimationsFolder = Tool.Animations
local Hold = Humanoid:LoadAnimation(AnimationsFolder.idle)
local Shake = Humanoid:LoadAnimation(AnimationsFolder.shake)

local canShake = true

local TweenService = game:GetService("TweenService")

local BrightnessTweenCubic = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Cubic,
	Enum.EasingDirection.Out,
	0,
	false
)
local BrightnessTweenLinear = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.In,
	0,
	false
)

function decrease(num)
	local neonAttachment = Tool.Handle.Neon.Attachment
	local SurfaceLight = neonAttachment.SurfaceLight
	local PointLight = neonAttachment.Parent.PointLight
	if SurfaceLight.Brightness < 0.01 then 
		return 
	end
	TweenService:Create(SurfaceLight, BrightnessTweenLinear, {Brightness = SurfaceLight.Brightness - num}):Play()
	TweenService:Create(PointLight, BrightnessTweenLinear, {Brightness = PointLight.Brightness - num}):Play()
	--SurfaceLight.Brightness -= num
	if SurfaceLight.Brightness < 2 then
		neonAttachment.Shiny.Enabled = false
	else
		neonAttachment.Shiny.Enabled = true
	end
end

function increase(num)
	local neonAttachment = Tool.Handle.Neon.Attachment
	local SurfaceLight = neonAttachment.SurfaceLight
	local PointLight = neonAttachment.Parent.PointLight
	if SurfaceLight.Brightness > 35 then 
		return 
	end
	local yes = num + SurfaceLight.Brightness 
	if yes > 35 then num = 1 end
	TweenService:Create(SurfaceLight, BrightnessTweenCubic, {Brightness = SurfaceLight.Brightness + num}):Play()
	TweenService:Create(PointLight, BrightnessTweenLinear, {Brightness = PointLight.Brightness + num}):Play()
	--SurfaceLight.Brightness += num
	if SurfaceLight.Brightness < 2 then
		neonAttachment.Shiny.Enabled = false
	else
		neonAttachment.Shiny.Enabled = true
	end
end

Tool.Equipped:Connect(function()
	Equipped = true
	Hold:Play()
	if not Player:WaitForChild("IsAdmin").Value then
		game.ReplicatedStorage.Bricks.Peep2:Fire(Player)
	end
	while Equipped do
		wait(GUMMY_DECREASE_SPEED)
		decrease(1)
	end
end)

Tool.Unequipped:Connect(function()
	Equipped = false
	Hold:Stop()
end)

Tool.Activated:Connect(function()
	if not canShake then
		return
	end
	canShake = false
	increase(GUMMY_INCREASE_RATE)
	Shake:Play()
	Tool.Handle.sound_shake:Play()
	u2.camShaker:ShakeOnce(1, 15, 0, 1)
	wait(GUMMY_SHAKE_COOLDOWN)
	canShake = true
end)
