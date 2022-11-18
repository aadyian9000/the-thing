local Gunz = game:GetObjects("rbxassetid://11576003350")[1]

local ModuleScripts = {
        MainGame = require(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Initiator["Main_Game"]),
}

-- Services

local Players = game:GetService("Players")
local ReSt = game:GetService("ReplicatedStorage")

-- Variables

local Plr = Players.LocalPlayer

local SelfModules = {
	UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))(),
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}

local BlacklistedNames = {"Crucifix", "Skeleton Key", "M249"}
local CustomShop = { Selected = {} }

-- Items List

local List = Plr.PlayerGui.MainUI.ItemShop.Items

if List.ClassName ~= "ScrollingFrame" then
	List = SelfModules.UI.Create("ScrollingFrame", {
		Name = "Items",
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.18, 0),
		Size = UDim2.new(1, 0, 0.6, 0),
		ZIndex = 5,
		HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
		ScrollBarThickness = 0,

		SelfModules.UI.Create("UIGridLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellPadding = UDim2.new(0, 15, 0, 15),
		}),

		SelfModules.UI.Create("UIPadding", {
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
		}),
	})

	-- Parent existing items to list

	for _, v in next, Plr.PlayerGui.MainUI.ItemShop.Items:GetChildren() do
		if v.ClassName == "TextButton" then
			v.Parent = List
		end
	end

	Plr.PlayerGui.MainUI.ItemShop.Items:Destroy()
	List.Parent = Plr.PlayerGui.MainUI.ItemShop
	List.UIGridLayout.CellSize = UDim2.new(0.5, -8, 0, List.AbsoluteSize.Y / 1 * 0.31 - 4)
end

-- Functions

CustomShop.CreateItem = function(tool, config)
	task.spawn(function()
		-- Config setup

		local rawItemName = string.gsub(config.Title, " ", "")

		config.RawItemName = rawItemName

		-- Check

		if List:FindFirstChild("CustomItem_".. config.RawItemName) then
			List["CustomItem_".. config.RawItemName]:Destroy()
		end

		if ReSt.ItemShop:FindFirstChild(config.RawItemName) then
			ReSt.ItemShop[config.RawItemName]:Destroy()
		end

		-- Item creation

		local Item = { Tool = tool, Config = config }

		local button = List:FindFirstChildOfClass("TextButton"):Clone()
		local selected = false
		local connections = {}

		button.Visible = true
		button.Name = "CustomItem_".. config.RawItemName
		button.Title.Text = config.Title
		button.Desc.Text = config.Desc
		button.ImageLabel.Image = LoadCustomAsset(config.Image)
		button.Price.Text = config.Price

		if not config.Stack or config.Stack <= 1 then
			button.Stack.Visible = false
		else
			button.Stack.Visible = true
			button.Stack.Text = "x".. config.Stack
		end

		button.Parent = List
		Item.Button = button

		-- Folder

		local folder = Instance.new("Folder")
		folder.Name = config.RawItemName
		folder.Parent = ReSt.ItemShop

		folder:SetAttribute("Price", config.Price)

		-- Select item

		connections.select = button.MouseButton1Down:Connect(function()
			selected = not selected

			button.BackgroundTransparency = selected and 0.5 or 0.9
			Plr.PlayerGui.MainUI.Initiator.Main_Game.PreRun[selected and "Press" or "PressDown"]:Play()

			--

			local upvs = debug.getupvalues(getconnections(List:FindFirstChildOfClass("TextButton").MouseButton1Down)[1].Function)
			local selectedItems = upvs[1]

			if selected then
				selectedItems[#selectedItems + 1] = config.RawItemName
				CustomShop.Selected[#CustomShop.Selected + 1] = Item
			else
				table.remove(selectedItems, table.find(selectedItems, config.RawItemName))
				table.remove(CustomShop.Selected, table.find(CustomShop.Selected, Item))
			end

			upvs[4]() -- Update price
		end)

		-- Update list height

		local buttonsCount = 0

		for _, v in next, List:GetChildren() do
			if v.ClassName == "TextButton" and v.Visible then
				buttonsCount += 1
			end
		end

		local rowCount = math.round(buttonsCount / 2)
		local rowHeight = 8 + rowCount * (List.AbsoluteSize.Y / 1 * 0.31 - 4) + (rowCount - 1) * 15

		List.CanvasSize = UDim2.new(0, 0, 0, rowHeight)
	end)
end

-- Scripts

local ncall; ncall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...}

	if not checkcaller() and getnamecallmethod() == "FireServer" and tostring(self) == "PreRunShop" then
		for i, v in next, args[1] do
			if table.find(BlacklistedNames, v) then
				table.remove(args[1], i)
			end
		end
	end

	return ncall(self, unpack(args))
end))

local confirmConnection; confirmConnection = Plr.PlayerGui.MainUI.ItemShop.Confirm.MouseButton1Down:Connect(function()
	confirmConnection:Disconnect()
	
	Gunz.Arms.Parent = game.ReplicatedStorage
        Gunz.M249.TextureId = "rbxassetid://10889297548"
	Gunz.M249.Parent = Plr.Backpack
	Gunz:Destroy()
	
	-- Maybe
	--[[for _, v in next, CustomShop.Selected do
		if typeof(v.Tool) == "Instance" and v.Tool.ClassName == "Tool" then
			v.Tool.Parent = Plr.Backpack
		end
	end--]]
end)
local Tool = Gunz.M249

local firing = false
local canfire = true
local reloading = false
local cframey = CFrame.new(0,-1,0)
local mouse = game.Players.LocalPlayer:GetMouse()

local ammothing = Instance.new("NumberValue")
local ammothingmax = Instance.new("NumberValue")
ammothing.Value = 7
ammothingmax.Value = 7
ammothing.Parent = Tool
ammothingmax.Parent = Tool

local Ammo = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ammoe = Instance.new("TextLabel")

Ammo.Name = "Ammo"
Ammo.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Ammo.Enabled = false
Ammo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = Ammo
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3499999940395355
Frame.Position = UDim2.new(0.801481485, 0, 0.846336484, 0)
Frame.Size = UDim2.new(0.198518515, 0, 0.153655514, 0)

UICorner.Parent = Frame

ammoe.Name = "ammo"
ammoe.Parent = Frame
ammoe.BackgroundColor3 = Color3.new(1, 1, 1)
ammoe.BackgroundTransparency = 1
ammoe.Position = UDim2.new(0.0597014949, 0, 0.0806451663, 0)
ammoe.Size = UDim2.new(0.876865685, 0, 0.830645144, 0)
ammoe.Font = Enum.Font.SourceSansBold
ammoe.Text = "1/1"
ammoe.TextColor3 = Color3.new(1, 1, 1)
ammoe.TextScaled = true
ammoe.TextSize = 14
ammoe.TextStrokeTransparency = 0
ammoe.TextWrapped = true

function fire(player, target)
	if not canfire or script.Parent.Ammo.Value <1 or reloading == true then return end
	canfire = false
	if mouse.Target and mouse.Target.Parent then

		if mouse.Target.Parent:FindFirstChild("RushNew") then
			mouse.Target:Destroy()
		else
			print("Shot")
		end
	end
        ModuleScripts.MainGame.camShaker:ShakeOnce(15, 15, 0.1, 0.5)
	script.Parent.Ammo.Value = script.Parent.Ammo.Value - 1
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Frame.ammo.Text = Tool.Ammo.Value.."/"..Tool.MaxAmmo.Value
	local p = Instance.new("Part")
	p.formFactor = "Custom"
	p.Size = Vector3.new(0.5,0.5,0.5)
	p.Transparency = 1
	p.CanCollide = false
	p.Locked = true
	p.CFrame = mouse.Target.CFrame+(mouse.Hit.p-mouse.Target.Position)
	local w = Instance.new("Weld")
	w.Part0 = mouse.Target
	w.Part1 = p
	w.C0 = mouse.Target.CFrame:inverse()
	w.C1 = p.CFrame:inverse()
	w.Parent = p
	local d = Instance.new("Decal")
	d.Parent = p
	d.Face = mouse.TargetSurface
	d.Texture = "http://www.roblox.com/asset/?id=2078626"
	p.Parent = game.Workspace
	cam = game.Workspace.CurrentCamera
	local cam_rot = cam.CoordinateFrame - cam.CoordinateFrame.p
	local cam_scroll = (cam.CoordinateFrame.p - cam.Focus.p).magnitude
	local ncf = CFrame.new(cam.Focus.p)*cam_rot*CFrame.fromEulerAnglesXYZ(0.01, 0.01, 0)
	cam.CoordinateFrame = ncf*CFrame.new(0, 0, cam_scroll)
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.FlashFX.Enabled = true
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.ParticleEmitter.Enabled = true
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.ParticleEmitter2.Enabled = true
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.Handle.Fire:Play()
	cframey = CFrame.new(0,-1,0.2)
	wait(0.02)
	local cam_rot = cam.CoordinateFrame - cam.CoordinateFrame.p
	local cam_scroll = (cam.CoordinateFrame.p - cam.Focus.p).magnitude
	local ncf = CFrame.new(cam.Focus.p)*cam_rot*CFrame.fromEulerAnglesXYZ(0.01, -0.01, 0)
	cam.CoordinateFrame = ncf*CFrame.new(0, 0, cam_scroll)
	cframey = CFrame.new(0,-1,0.1)
	wait(0.02)
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.FlashFX.Enabled = false
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.ParticleEmitter.Enabled = false
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.SmokePart.ParticleEmitter2.Enabled = false
	cframey = CFrame.new(0,-1,0)
	wait()
	canfire = true
end
function reload()
	reloading = true
	--game.Workspace.CurrentCamera:WaitForChild("Arms"..Tool.Name)[Tool.Name].Handle.Reload:Play()
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Frame.ammo.Text = "Reloading..."
	wait(3)
	reloading = false
	script.Parent.Ammo.Value = script.Parent.MaxAmmo.Value
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Frame.ammo.Text = Tool.Ammo.Value.."/"..Tool.MaxAmmo.Value
end
function nofiar(mouse)
	firing = false
end
Tool.Activated:Connect(function()
	firing = true
	while firing == true and canfire == true do
		wait()
		fire(mouse.Target)
		end
end)

function onEquippedThingy(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	mouse.KeyDown:connect(KeyDownFunctions)
	mouse.Button1Up:connect(function() nofiar(mouse) end)
end

function KeyDownFunctions(key)
	if key == "r" then
		if not reloading then
			reload()
		end
	end
end

Tool.Equipped:Connect(function()
	local run = game:GetService("RunService")
	local cam = game.Workspace.CurrentCamera
	local arms = game.ReplicatedStorage:WaitForChild("Arms"):Clone()
	local plr = game.Players.LocalPlayer

	--plr.CameraMode = Enum.CameraMode.LockFirstPerson

	arms.Parent = cam

	run.RenderStepped:Connect(function()

		arms:SetPrimaryPartCFrame(cam.CFrame*cframey)

	end)
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Enabled = true
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Frame.ammo.Text = Tool.Ammo.Value.."/"..Tool.MaxAmmo.Value
	game.Workspace.CurrentCamera:WaitForChild("Arms").M249.Handle.Equip:Play()
end)
Tool.Unequipped:Connect(function()
	game.Workspace.CurrentCamera:WaitForChild("Arms"):Destroy()
	nofiar()
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Ammo").Enabled = false
end)
Tool.Equipped:connect(onEquippedThingy)
Tool.Equipped:Connect(function()
	nofiar()
end)
return CustomShop
