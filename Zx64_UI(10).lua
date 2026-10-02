-- [[ // Error Handling // ]]
local Passed, Statement = pcall(function()
	-- [[ // Libraries // ]]
	local library = {
		Renders = {},
		Connections = {},
		Folder = "Zx64", -- Change if wanted
		Assets = "Assets", -- Change if wanted
		Configs = "Configs" -- Change if wanted
	}
	local utility = {}
	
	-- [[ // Global Config Registries // ]]
	local genv = (getgenv and getgenv()) or _G
	if genv.Zx64_Unload then pcall(genv.Zx64_Unload) end
	local Options = {}
	local Toggles = {}
	genv.Options = Options
	genv.Toggles = Toggles
	
	-- Helper to ensure unique IDs for configs
	local function getUniqueId(name, table)
		local id = name
		local i = 1
		while table[id] do
			i = i + 1
			id = name .. "_" .. i
		end
		return id
	end

	-- [[ // Tables // ]]
	local pages = {}
	local sections = {}
	-- [[ // Indexes // ]]
	do
		library.__index = library
		pages.__index = pages
		sections.__index = sections
	end
	-- [[ // Variables // ]] 
	local tws = game:GetService("TweenService")
	local uis = game:GetService("UserInputService")
	local players = game:GetService("Players")
	local lp = players.LocalPlayer
	local cre = nil
	-- try gethui
	pcall(function()
		if gethui then cre = gethui() end
	end)
	-- try CoreGui
	if not cre then
		pcall(function()
			cre = game:GetService("CoreGui")
		end)
	end
	-- fallback PlayerGui (no infinite wait)
	if not cre then
		if lp then
			cre = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
		end
	end
	if not cre then
		error("No UI parent found (CoreGui/PlayerGui)")
	end

	-- [[ // Background Options // ]]
	local Backgrounds = {
		{ Name = "Anime Waifu",       Id = "13002178909" },
		{ Name = "Aesthetic Anime",   Id = "5252447904" },
		{ Name = "Sad Anime Girl",    Id = "6239938337" },
		{ Name = "Kawaii Anime Girl", Id = "11425468695" },
		{ Name = "Aesthetic Anime Girl", Id = "6368110022" },
		{ Name = "Cute Aesthetic Anime Girl", Id = "6029337509" },
		{ Name = "Dark Aesthetic Girl", Id = "10341849885" },
		{ Name = "Anime Face",        Id = "3241672660" },
		{ Name = "Aesthetic Anime 2", Id = "5191098772" },
		{ Name = "None" },
	}
	local BackgroundNames = {}
	for _, bg in ipairs(Backgrounds) do
		table.insert(BackgroundNames, bg.Name)
	end

	-- [[ // Functions // ]]
	function utility:RenderObject(RenderType, RenderProperties, RenderHidden)
		local Render = Instance.new(RenderType)
		--
		if RenderProperties and typeof(RenderProperties) == "table" then
			for Property, Value in pairs(RenderProperties) do
				if Property ~= "RenderTime" then
					Render[Property] = Value
				end
			end
		end
		--
		
		--
		return Render
	end
	--
	function utility:CreateConnection(ConnectionType, ConnectionCallback)
		local Connection = ConnectionType:Connect(ConnectionCallback)
		--
		library.Connections[#library.Connections + 1] = Connection
		--
		return Connection
	end
	--
	function utility:MouseLocation()
		return uis:GetMouseLocation()
	end
	--
	function utility:InputPosition(Input)
		if Input and Input.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(Input.Position.X, Input.Position.Y)
		end
		return uis:GetMouseLocation()
	end
	--
	function utility:Inside(Object, Position)
		local P, S = Object.AbsolutePosition, Object.AbsoluteSize
		return Position.X >= P.X and Position.X <= P.X + S.X and Position.Y >= P.Y and Position.Y <= P.Y + S.Y
	end
	--
	function utility:Serialise(Table)
		local Serialised = ""
		--
		for Index, Value in pairs(Table) do
			Serialised = Serialised .. Value .. ", "
		end
		--
		return Serialised:sub(0, #Serialised - 2)
	end
	--
	function utility:Sort(Table1, Table2)
		local Table3 = {}
		--
		for Index, Value in pairs(Table2) do
			if table.find(Table1, Index) then
				Table3[#Table3 + 1] = Value
			end
		end
		--
		return Table3
	end
	-- [[ // UI Functions // ]]
	function library:CreateWindow(Properties)
		Properties = Properties or {}
		--
		local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
		local isMobile = uis.TouchEnabled and (not uis.KeyboardEnabled or vp.X < 900 or vp.Y < 700)
		-- Desktop: 600x650 | Mobile: shorter so it fits the phone screen
		local baseW, baseH = 600, 650
		local winW, winH = baseW, baseH
		local uiScale = 1
		if isMobile then
			winW = math.clamp(math.floor(vp.X * 0.92), 300, 400)
			winH = math.clamp(math.floor(vp.Y * 0.68), 380, 520) -- shorter for mobile
			uiScale = math.clamp(math.min(winW / baseW, winH / baseH), 0.55, 0.85)
		end
		--
		local Window = {
			Pages = {},
			Accent = Color3.fromRGB(255, 255, 255), -- White
			Enabled = true,
			Locked = false,
			Dragging = false,
			DragStart = nil,
			StartPos = nil,
			Key = Enum.KeyCode.RightShift, -- Toggle menu
			UITransparency = 0,
			IsMobile = isMobile,
			Scale = uiScale,
			Width = winW,
			Height = winH,
			BackgroundImage = nil,
			Outline = Color3.fromRGB(255, 255, 255),
			OutlineTargets = {},
			AccentCallbacks = {},
			OpenContent = nil,
			Binding = false,
			Layers = {},
		}
		--
		do
			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "Zx64UI"
			ScreenGui.DisplayOrder = 9999
			ScreenGui.Enabled = true
			ScreenGui.IgnoreGuiInset = true
			ScreenGui.ResetOnSpawn = false
			ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			local parentOk, parentErr = pcall(function()
				ScreenGui.Parent = cre
			end)
			if not parentOk then
				-- last resort PlayerGui
				local pg = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
				if pg then
					ScreenGui.Parent = pg
				else
					error("Could not parent ScreenGui: " .. tostring(parentErr))
				end
			end

			-- // Backdrop dim (darkens game behind menu)
			local Backdrop = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = ScreenGui,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 0,
				Visible = false
			})
			Window.Backdrop = Backdrop

			-- // Lighting blur for menu open
			local MenuBlur = nil
			pcall(function()
				MenuBlur = Instance.new("BlurEffect")
				MenuBlur.Name = "Zx64_MenuBlur"
				MenuBlur.Size = 0
				MenuBlur.Enabled = false
				MenuBlur.Parent = game:GetService("Lighting")
			end)
			Window.MenuBlur = MenuBlur

			-- // Custom cursor — Creep.cc style (asset 4292970642) + glow outline
			local CustomCursor = utility:RenderObject("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = ScreenGui,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.fromOffset(28, 28),
				ZIndex = 100000,
				Visible = false
			})
			-- soft glow outline (larger, accent, semi-transparent)
			local CursorGlow = Instance.new("ImageLabel")
			CursorGlow.Name = "CursorGlow"
			CursorGlow.BackgroundTransparency = 1
			CursorGlow.BorderSizePixel = 0
			CursorGlow.Position = UDim2.fromOffset(-4, -4)
			CursorGlow.Size = UDim2.fromOffset(25, 25)
			CursorGlow.ZIndex = 100000
			CursorGlow.Image = "rbxassetid://4292970642"
			CursorGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
			CursorGlow.ImageTransparency = 0.5
			CursorGlow.Rotation = -45
			CursorGlow.Parent = CustomCursor
			-- dark outline (Creep.cc)
			local CursorOutline = Instance.new("ImageLabel")
			CursorOutline.Name = "CursorOutline"
			CursorOutline.BackgroundTransparency = 1
			CursorOutline.BorderSizePixel = 0
			CursorOutline.Position = UDim2.fromOffset(-1, -1)
			CursorOutline.Size = UDim2.fromOffset(19, 19)
			CursorOutline.ZIndex = 100001
			CursorOutline.Image = "rbxassetid://4292970642"
			CursorOutline.ImageColor3 = Color3.new(0, 0, 0)
			CursorOutline.ImageTransparency = 0
			CursorOutline.Rotation = -45
			CursorOutline.Parent = CustomCursor
			-- main cursor (accent)
			local CursorImg = Instance.new("ImageLabel")
			CursorImg.Name = "CursorImg"
			CursorImg.BackgroundTransparency = 1
			CursorImg.BorderSizePixel = 0
			CursorImg.Position = UDim2.fromOffset(0, 0)
			CursorImg.Size = UDim2.fromOffset(17, 17)
			CursorImg.ZIndex = 100002
			CursorImg.Image = "rbxassetid://4292970642"
			CursorImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
			CursorImg.ImageTransparency = 0
			CursorImg.Rotation = -45
			CursorImg.Parent = CustomCursor

			Window.CustomCursor = CustomCursor
			Window.CursorParts = { CursorImg, CursorGlow }
			Window.CursorSpin = nil
			Window.CursorBlade = nil
			Window.CursorGlow = CursorGlow
			Window.CursorImg = CursorImg
			Window.CursorOutline = CursorOutline
			Window.LiquidGlass = false
			Window._baseStrokeTransparency = 0.35
			Window._glassStrokeTransparency = 0.55

			-- //
			-- Outer glow halo
			local GlowFrame = utility:RenderObject("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.85,
				BorderSizePixel = 0,
				Parent = ScreenGui,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, winW + 16, 0, winH + 16),
				ZIndex = 0
			})
			utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 18),
				Parent = GlowFrame
			})
			--
			local ScreenGui_MainFrame = utility:RenderObject("CanvasGroup", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(12, 12, 16),
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Parent = ScreenGui,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, winW, 0, winH),
				ClipsDescendants = true,
				ZIndex = 1,
				Visible = true
			})
			-- UIScale for overall mobile shrink (keeps layout proportional)
			local MainUIScale = Instance.new("UIScale")
			MainUIScale.Name = "MainUIScale"
			MainUIScale.Scale = isMobile and 1 or 1 -- size already fitted; scale reserved for settings
			MainUIScale.Parent = ScreenGui_MainFrame
			Window.UIScale = MainUIScale
			--
			function Window:SetScale(scale)
				scale = math.clamp(tonumber(scale) or 1, 0.5, 1.25)
				Window.Scale = scale
				if isMobile then
					-- on mobile, scale from the fitted base size
					ScreenGui_MainFrame.Size = UDim2.new(0, math.floor(winW * scale), 0, math.floor(winH * scale))
					GlowFrame.Size = UDim2.new(0, math.floor(winW * scale) + 16, 0, math.floor(winH * scale) + 16)
				else
					ScreenGui_MainFrame.Size = UDim2.new(0, math.floor(baseW * scale), 0, math.floor(baseH * scale))
					GlowFrame.Size = UDim2.new(0, math.floor(baseW * scale) + 16, 0, math.floor(baseH * scale) + 16)
				end
				if Window.ScaleLabel then
					Window.ScaleLabel.Text = string.format("%d%%", math.floor(scale * 100 + 0.5))
				end
			end
			-- // Bottom-left scale drag handle
			-- Circular resize handle (half the previous body size)
			local ScaleHandle = utility:RenderObject("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				Parent = ScreenGui_MainFrame,
				Position = UDim2.new(0, 10, 1, -10),
				Size = UDim2.new(0, 11, 0, 11), -- half of previous 22px body
				ZIndex = 100,
				Text = "",
				AutoButtonColor = false
			})
			utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(1, 0), -- full circle
				Parent = ScaleHandle
			})
			local ScaleHandleStroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1,
				Transparency = 0.25,
				Parent = ScaleHandle
			})
			Window._ScaleHandleStroke = ScaleHandleStroke
			local ScaleLabel = utility:RenderObject("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = ScaleHandle,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(1, 6, 0.5, 0),
				Size = UDim2.new(0, 40, 0, 14),
				ZIndex = 101,
				Font = Enum.Font.GothamBold,
				Text = "100%",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = false
			})
			Window.ScaleLabel = ScaleLabel
			Window.ScaleHandle = ScaleHandle
			-- // Rounded sexy corners
			local MainCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ScreenGui_MainFrame
			})
			-- // Soft stroke / glow border
			local MainStroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1.5,
				Transparency = 0.35,
				Parent = ScreenGui_MainFrame
			})
			-- //
			local ScreenGui_MainFrame_InnerBorder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(16, 16, 20),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = ScreenGui_MainFrame,
				Position = UDim2.new(0, 2, 0, 2),
				Size = UDim2.new(1, -4, 1, -4)
			})
			local InnerCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 10),
				Parent = ScreenGui_MainFrame_InnerBorder
			})
			-- //
			local MainFrame_InnerBorder_InnerFrame = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(12, 12, 16),
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Parent = ScreenGui_MainFrame,
				Position = UDim2.new(0, 4, 0, 4),
				Size = UDim2.new(1, -8, 1, -8)
			})
			local DeepCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 9),
				Parent = MainFrame_InnerBorder_InnerFrame
			})
			-- // Title / Drag bar (sexy header)
			local TitleBar = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(8, 8, 12),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 32),
				ZIndex = 10
			})
			local TitleCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 9),
				Parent = TitleBar
			})
			-- Fix bottom corners of title bar so only top is rounded
			local TitleFix = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(8, 8, 12),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = TitleBar,
				Position = UDim2.new(0, 0, 1, -10),
				Size = UDim2.new(1, 0, 0, 10),
				ZIndex = 10
			})
			local TitleLabel = utility:RenderObject("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = TitleBar,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 11,
				Font = Enum.Font.GothamBold,
				Text = "Zx64",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Center
			})
			-- Rainbow wave gradient (color sweeps forward across title)
			local TitleGradient = utility:RenderObject("UIGradient", {
				Parent = TitleLabel,
				Rotation = 0,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.9, 1)),
					ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.15, 0.9, 1)),
					ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.35, 0.9, 1)),
					ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.55, 0.9, 1)),
					ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.75, 0.9, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(0.95, 0.9, 1)),
				})
			})
			Window.TitleGradient = TitleGradient
			Window._titleWave = {
				offset = 0,
				speed = 0.12 + math.random() * 0.06, -- natural slow drift
				nextRandom = tick() + (2.5 + math.random() * 3),
				phase = math.random() * math.pi * 2,
				hueShift = math.random(),
			}
			-- Game name label (right side of title) e.g. [rivals]
			local GameLabel = utility:RenderObject("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = TitleBar,
				Position = UDim2.new(1, -12, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.new(0.28, 0, 1, 0),
				ZIndex = 11,
				Font = Enum.Font.Gotham,
				Text = "[unknown]",
				TextColor3 = Color3.fromRGB(160, 160, 165),
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			task.spawn(function()
				local name = "unknown"
				pcall(function()
					name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
				end)
				if not name or name == "" then
					pcall(function() name = game.Name end)
				end
				name = tostring(name or "unknown"):lower()
				-- short clean name
				name = name:gsub("%s+", " "):sub(1, 24)
				GameLabel.Text = "[" .. name .. "]"
			end)
			local TitleAccent = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				Parent = TitleBar,
				Position = UDim2.new(0, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 11
			})
			-- //
			-- Top tab bar (Elysium style)
			local InnerBorder_InnerFrame_Tabs = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(8, 8, 12),
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 32),
				Size = UDim2.new(1, 0, 0, 26)
			})
			--
			local InnerBorder_InnerFrame_Pages = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 58),
				Size = UDim2.new(1, 0, 1, -58)
			})
			--
			local InnerBorder_InnerFrame_TopGradient = utility:RenderObject("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 58),
				Size = UDim2.new(1, 0, 0, 2)
			})
			-- //
			local InnerFrame_Tabs_List = utility:RenderObject("UIListLayout", {
				Padding = UDim.new(0, 2),
				Parent = InnerBorder_InnerFrame_Tabs,
				FillDirection = "Horizontal",
				HorizontalAlignment = "Left",
				VerticalAlignment = "Center"
			})
			--
			local InnerFrame_Tabs_Padding = utility:RenderObject("UIPadding", {
				Parent = InnerBorder_InnerFrame_Tabs,
				PaddingLeft = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 0)
			})
			--
			local InnerFrame_Pages_InnerBorder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(20, 20, 26),
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Parent = InnerBorder_InnerFrame_Pages,
				Position = UDim2.new(0, 1, 0, 0),
				Size = UDim2.new(1, -1, 1, 0)
			})
			local PagesCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = InnerFrame_Pages_InnerBorder
			})
			--
			local InnerFrame_TopGradient_Gradient = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = InnerBorder_InnerFrame_TopGradient,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				Image = "rbxassetid://8508019876",
				ImageColor3 = Color3.fromRGB(240, 240, 245),
				ImageTransparency = 0.55
			})
			-- //
			local Pages_InnerBorder_InnerFrame = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(10, 10, 14),
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				Parent = InnerFrame_Pages_InnerBorder,
				Position = UDim2.new(0, 1, 0, 0),
				Size = UDim2.new(1, -1, 1, 0)
			})
			local PagesInnerCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 5),
				Parent = Pages_InnerBorder_InnerFrame
			})
			-- //
			local InnerBorder_InnerFrame_Folder = utility:RenderObject("Folder", {
				Parent = Pages_InnerBorder_InnerFrame
			})
			--
			local InnerBorder_InnerFrame_Pattern = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Pages_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Image = "rbxassetid://8547666218",
				ImageColor3 = Color3.fromRGB(14, 14, 18),
				ImageTransparency = 0.72,
				ScaleType = "Tile",
				TileSize = UDim2.new(0, 8, 0, 8)
			})
			-- // Background (Dynamic)
			local TungTungBG = utility:RenderObject("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Pages_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 1,
				Image = "rbxthumb://type=Asset&id=13002178909&w=420&h=420",
				ImageTransparency = 0.28,
				ScaleType = Enum.ScaleType.Crop,
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			})
			Window.BackgroundImage = TungTungBG -- store reference
			--
			-- ========== MOBILE / FLOATING CONTROLS ==========
			local MobilePanel = utility:RenderObject("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(18, 18, 22),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Parent = ScreenGui,
				Position = UDim2.new(1, -16, 0, 16),
				Size = UDim2.new(0, 140, 0, 110),
				ZIndex = 50,
				Visible = Window.IsMobile
			}, true) -- hidden from fade, phone only
			local MobileCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 10),
				Parent = MobilePanel
			}, true)
			local MobileStroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(240, 240, 245),
				Thickness = 1.5,
				Transparency = 0.3,
				Parent = MobilePanel
			}, true)
			local MobileTitle = utility:RenderObject("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = MobilePanel,
				Position = UDim2.new(0, 0, 0, 6),
				Size = UDim2.new(1, 0, 0, 20),
				ZIndex = 51,
				Font = Enum.Font.GothamBold,
				Text = "Toggle UI",
				TextColor3 = Color3.fromRGB(240, 240, 245),
				TextSize = 13
			}, true)
			-- Toggle UI Button
			local ToggleBtn = utility:RenderObject("TextButton", {
				BackgroundColor3 = Color3.fromRGB(240, 240, 245),
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Parent = MobilePanel,
				Position = UDim2.new(0.5, -55, 0, 30),
				Size = UDim2.new(0, 110, 0, 28),
				ZIndex = 51,
				Font = Enum.Font.GothamBold,
				Text = "Show / Hide",
				TextColor3 = Color3.fromRGB(20, 20, 24),
				TextSize = 12,
				AutoButtonColor = false
			}, true)
			local ToggleBtnCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ToggleBtn
			}, true)
			-- Lock UI Button
			local LockBtn = utility:RenderObject("TextButton", {
				BackgroundColor3 = Color3.fromRGB(40, 40, 48),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Parent = MobilePanel,
				Position = UDim2.new(0.5, -55, 0, 66),
				Size = UDim2.new(0, 110, 0, 28),
				ZIndex = 51,
				Font = Enum.Font.GothamBold,
				Text = "Lock UI",
				TextColor3 = Color3.fromRGB(220, 220, 230),
				TextSize = 12,
				AutoButtonColor = false
			}, true)
			local LockBtnCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = LockBtn
			}, true)
			local LockBtnStroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(80, 80, 90),
				Thickness = 1,
				Parent = LockBtn
			}, true)
			--
			do -- // Functions
				function Window:RegisterOutline(Object, Property)
					table.insert(Window.OutlineTargets, {Object, Property})
					Object[Property] = Window.Outline
				end
				--
				function Window:SetOutlineColor(Color)
					if typeof(Color) ~= "Color3" then return end
					Window.Outline = Color
					for Index = #Window.OutlineTargets, 1, -1 do
						local Target = Window.OutlineTargets[Index]
						if Target[1] and Target[1].Parent then
							Target[1][Target[2]] = Color
						else
							table.remove(Window.OutlineTargets, Index)
						end
					end
				end
				--
				function Window:RegisterAccent(Callback)
					table.insert(Window.AccentCallbacks, Callback)
				end
				--
				function Window:SetAccent(Color)
					if typeof(Color) ~= "Color3" then return end
					Window.Accent = Color
					for _, Callback in ipairs(Window.AccentCallbacks) do
						pcall(Callback, Color)
					end
				end
				--
				function Window:ClosePopups()
					local Open = Window.OpenContent
					Window.OpenContent = nil
					if Open and Open.Open and Open.Close then
						Open:Close()
					end
				end
				--
				function Window:SetPage(Page)
					Window:ClosePopups()
					for index, page in pairs(Window.Pages) do
						if page.Open and page ~= Page then
							page:Set(false)
						end
					end
				end
				--
				function Window:Fade(state)
					Window:ClosePopups()
					Window.FadeToken = (Window.FadeToken or 0) + 1
					local Token = Window.FadeToken
					local Info = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					if state then
						ScreenGui_MainFrame.Visible = true
						GlowFrame.Visible = true
						if Backdrop then
							Backdrop.Visible = true
							tws:Create(Backdrop, Info, { BackgroundTransparency = 0.45 }):Play()
						end
						if MenuBlur then
							MenuBlur.Enabled = true
							tws:Create(MenuBlur, Info, { Size = 12 }):Play()
						end
						if CustomCursor then
							CustomCursor.Visible = true
							pcall(function() uis.MouseIconEnabled = false end)
						end
					else
						if Backdrop then
							tws:Create(Backdrop, Info, { BackgroundTransparency = 1 }):Play()
						end
						if MenuBlur then
							tws:Create(MenuBlur, Info, { Size = 0 }):Play()
						end
						if CustomCursor then
							CustomCursor.Visible = false
							pcall(function() uis.MouseIconEnabled = true end)
						end
					end
					ScreenGui_MainFrame.Active = state
					tws:Create(ScreenGui_MainFrame, Info, {GroupTransparency = state and 0 or 1}):Play()
					tws:Create(GlowFrame, Info, {BackgroundTransparency = state and 0.85 or 1}):Play()
					tws:Create(MainStroke, Info, {Transparency = state and 0.2 or 1}):Play()
					if not state then
						task.delay(0.24, function()
							if Window.FadeToken == Token and not Window.Enabled then
								ScreenGui_MainFrame.Visible = false
								GlowFrame.Visible = false
								if Backdrop then Backdrop.Visible = false end
								if MenuBlur then MenuBlur.Enabled = false end
							end
						end)
					end
				end
				--
				function Window:SetLiquidGlass(enabled)
					Window.LiquidGlass = enabled and true or false
					-- Liquid glass = only darken UI panels (no blur/shape changes)
					if not Window._layerBaseColors then
						Window._layerBaseColors = {}
						for _, Layer in ipairs(Window.Layers) do
							if Layer and Layer:IsA("GuiObject") then
								Window._layerBaseColors[Layer] = Layer.BackgroundColor3
							end
						end
					end
					if Window.LiquidGlass then
						for _, Layer in ipairs(Window.Layers) do
							if Layer and Layer.Parent and Layer:IsA("GuiObject") then
								local base = Window._layerBaseColors[Layer] or Layer.BackgroundColor3
								-- pull toward near-black
								Layer.BackgroundColor3 = Color3.new(
									base.R * 0.35,
									base.G * 0.35,
									base.B * 0.38
								)
							end
						end
						if Window.BackgroundImage then
							Window.BackgroundImage.ImageColor3 = Color3.fromRGB(120, 120, 130)
						end
					else
						for _, Layer in ipairs(Window.Layers) do
							if Layer and Layer.Parent and Layer:IsA("GuiObject") then
								local base = Window._layerBaseColors[Layer]
								if base then
									Layer.BackgroundColor3 = base
								end
							end
						end
						if Window.BackgroundImage then
							Window.BackgroundImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
						end
						Window:SetTransparency(Window.UITransparency or 0.4)
					end
				end
				--
				function Window:SetLocked(state)
					Window.Locked = state
					if state then
						LockBtn.Text = "Unlock UI"
						LockBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
						LockBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
						LockBtnStroke.Color = Color3.fromRGB(255, 255, 255)
					else
						LockBtn.Text = "Lock UI"
						LockBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
						LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
						LockBtnStroke.Color = Color3.fromRGB(80, 80, 85)
					end
				end
				--
				function Window:SetTransparency(amount)
					amount = math.clamp(tonumber(amount) or 0, 0, 0.85)
					Window.UITransparency = amount
					local Each = amount == 0 and 0 or amount ^ (1 / 5)
					for _, Layer in ipairs(Window.Layers) do
						Layer.BackgroundTransparency = Each
					end
				end
				--
				function Window:SetBackground(optionName)
					for _, bg in ipairs(Backgrounds) do
						if bg.Name == optionName then
							if bg.Id then
								Window.BackgroundImage.Image = "rbxthumb://type=Asset&id=" .. bg.Id .. "&w=420&h=420"
								Window.BackgroundImage.Visible = true
							else
								Window.BackgroundImage.Visible = false
							end
							return
						end
					end
				end
				--
				function Window:Unload()
					if Window.Unloaded then return end
					Window.Unloaded = true
					pcall(function() Window:ClosePopups() end)
					pcall(function() uis.MouseIconEnabled = true end)
					if MenuBlur then
						pcall(function() MenuBlur:Destroy() end)
						MenuBlur = nil
						Window.MenuBlur = nil
					end
					for _, connection in pairs(library.Connections) do
						pcall(function() connection:Disconnect() end)
					end
					table.clear(library.Connections)
					pcall(function() ScreenGui:Destroy() end)
					if genv.Zx64_Unload == Window.UnloadHook then
						genv.Zx64_Unload = nil
					end
				end
			end
			--
			do -- // Index Setting
				Window["TabsHolder"] = InnerBorder_InnerFrame_Tabs
				Window["PagesHolder"] = InnerBorder_InnerFrame_Folder
				Window["MainFrame"] = ScreenGui_MainFrame
				Window["ScreenGui"] = ScreenGui
				Window.Layers = {
					ScreenGui_MainFrame, ScreenGui_MainFrame_InnerBorder, MainFrame_InnerBorder_InnerFrame,
					InnerFrame_Pages_InnerBorder, Pages_InnerBorder_InnerFrame, TitleBar, TitleFix, InnerBorder_InnerFrame_Tabs
				}
				Window:RegisterOutline(MainStroke, "Color")
				Window:RegisterOutline(GlowFrame, "BackgroundColor3")
				Window:RegisterOutline(TitleAccent, "BackgroundColor3")
				Window:RegisterOutline(MobileStroke, "Color")
				if Window._ScaleHandleStroke then
					Window:RegisterOutline(Window._ScaleHandleStroke, "Color")
				end
				Window.TitleLabel = TitleLabel
			end
			--
			do -- // Connections + Drag + Mobile
				-- Rainbow wave: color sweeps forward across title, speed/phase randomize
				utility:CreateConnection(game:GetService("RunService").RenderStepped, function(dt)
					local grad = Window.TitleGradient
					local wave = Window._titleWave
					if not grad or not grad.Parent or not wave then return end
					local now = tick()
					-- occasionally nudge speed / phase (slow, natural)
					if now >= wave.nextRandom then
						wave.speed = 0.08 + math.random() * 0.1
						wave.phase = wave.phase + (math.random() * 0.4 - 0.1)
						wave.hueShift = (wave.hueShift + 0.03 + math.random() * 0.06) % 1
						wave.nextRandom = now + (2.5 + math.random() * 4)
					end
					-- move wave forward slowly
					wave.offset = (wave.offset + (dt or 0.016) * wave.speed) % 1
					local wobble = math.sin(now * 0.55 + wave.phase) * 0.04
					local o = (wave.offset + wobble) % 1
					-- rebuild keypoints shifted by hue so the rainbow travels
					local keys = {}
					for i = 0, 5 do
						local t = i / 5
						local hue = (t * 0.55 + o + wave.hueShift) % 1
						keys[#keys + 1] = ColorSequenceKeypoint.new(t, Color3.fromHSV(hue, 0.85, 1))
					end
					grad.Color = ColorSequence.new(keys)
					-- soft horizontal drift
					grad.Offset = Vector2.new((o * 2 - 1) * 0.2, 0)
				end)
				-- Custom cursor follows mouse + spinning nose crosshair
				local function paintCursor(col)
					if not col then return end
					for _, part in ipairs(Window.CursorParts or {}) do
						if part and part.Parent then
							if part:IsA("UIStroke") then
								part.Color = col
							elseif part:IsA("ImageLabel") or part:IsA("ImageButton") then
								part.ImageColor3 = col
							else
								part.BackgroundColor3 = col
							end
						end
					end
				end
				utility:CreateConnection(game:GetService("RunService").RenderStepped, function()
					if not Window.Enabled or not CustomCursor or not CustomCursor.Visible then return end
					-- Creep.cc positioning (account for GuiInset when IgnoreGuiInset is true on ScreenGui)
					local mPos = uis:GetMouseLocation()
					local inset = Vector2.zero
					pcall(function()
						inset = game:GetService("GuiService"):GetGuiInset()
					end)
					-- ScreenGui has IgnoreGuiInset = true, so use raw mouse location
					CustomCursor.Position = UDim2.fromOffset(mPos.X, mPos.Y)
					local col = Window.Accent or Window.Outline or Color3.fromRGB(255, 255, 255)
					if Window.CursorImg then
						Window.CursorImg.ImageColor3 = col
					end
					if Window.CursorGlow then
						Window.CursorGlow.ImageColor3 = col
					end
					-- black outline stays black
					if Window.CursorOutline then
						Window.CursorOutline.ImageColor3 = Color3.new(0, 0, 0)
					end
					pcall(function() uis.MouseIconEnabled = false end)
				end)
				-- Menu toggle key (changeable via Settings → Menu Key)
				utility:CreateConnection(uis.InputBegan, function(Input)
					if Window.Binding or uis:GetFocusedTextBox() then return end
					local key = Window.Key
					if not key then return end
					local matched = false
					if typeof(key) == "EnumItem" then
						if key.EnumType == Enum.KeyCode and Input.KeyCode == key then
							matched = true
						elseif key.EnumType == Enum.UserInputType and Input.UserInputType == key then
							matched = true
						end
					end
					if matched then
						Window.Enabled = not Window.Enabled
						Window:Fade(Window.Enabled)
					end
				end)
				-- Toggle button
				utility:CreateConnection(ToggleBtn.MouseButton1Click, function()
					Window.Enabled = not Window.Enabled
					Window:Fade(Window.Enabled)
				end)
				-- Lock button
				utility:CreateConnection(LockBtn.MouseButton1Click, function()
					Window:SetLocked(not Window.Locked)
				end)
				-- Hover effects for mobile buttons
				utility:CreateConnection(ToggleBtn.MouseEnter, function()
					tws:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
				end)
				utility:CreateConnection(ToggleBtn.MouseLeave, function()
					tws:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
				end)
				-- ===== DRAGGING (Mouse + Touch) =====
				local function beginDrag(input)
					if Window.Locked then return end
					Window:ClosePopups()
					Window.Dragging = true
					Window.DragStart = input.Position
					Window.StartPos = ScreenGui_MainFrame.Position
				end
				local function updateDrag(input)
					if not Window.Dragging or Window.Locked then return end
					local delta = input.Position - Window.DragStart
					local newPos = UDim2.new(
						Window.StartPos.X.Scale,
						Window.StartPos.X.Offset + delta.X,
						Window.StartPos.Y.Scale,
						Window.StartPos.Y.Offset + delta.Y
					)
					ScreenGui_MainFrame.Position = newPos
					if GlowFrame then GlowFrame.Position = newPos end
				end
				local function endDrag()
					Window.Dragging = false
				end
				-- ===== SCALE HANDLE DRAG (bottom-left) =====
				local Scaling = false
				local ScaleStartY = 0
				local ScaleStartVal = 1
				utility:CreateConnection(ScaleHandle.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if Window.Locked then return end
						Scaling = true
						ScaleStartY = input.Position.Y
						ScaleStartVal = Window.Scale or 1
						ScaleLabel.Visible = true
						ScaleHandle.BackgroundTransparency = 0.25
					end
				end)
				utility:CreateConnection(uis.InputChanged, function(input)
					if not Scaling then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						-- drag up = bigger, drag down = smaller
						local dy = ScaleStartY - input.Position.Y
						local nextScale = ScaleStartVal + (dy / 250)
						Window:SetScale(nextScale)
					end
				end)
				utility:CreateConnection(uis.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if Scaling then
							Scaling = false
							ScaleLabel.Visible = false
							ScaleHandle.BackgroundTransparency = 0.55
						end
					end
				end)
				-- Title bar drag (mouse)
				utility:CreateConnection(TitleBar.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						beginDrag(input)
					end
				end)
				utility:CreateConnection(TitleBar.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						endDrag()
					end
				end)
				-- Also allow dragging from the main frame top area
				utility:CreateConnection(uis.InputChanged, function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						updateDrag(input)
					end
				end)
				utility:CreateConnection(uis.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						endDrag()
					end
				end)
			end
		end
		--
		-- Apply open-state effects if menu starts enabled
		if Window.Enabled then
			task.defer(function()
				pcall(function()
					Window:Fade(true)
					if Window.CustomCursor then
						Window.CustomCursor.Visible = true
						pcall(function() game:GetService("UserInputService").MouseIconEnabled = false end)
					end
				end)
			end)
		end
		Window.UnloadHook = function() Window:Unload() end
		genv.Zx64_Unload = Window.UnloadHook
		return setmetatable(Window, library)
	end
	--
	function library:CreatePage(Properties)
		Properties = Properties or {}
		--
		local Page = {
			Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "page"),
			Image = (Properties.image or Properties.Image or Properties.icon or Properties.Icon),
			Open = false,
			Window = self
		}
		--
		do
			-- Horizontal text tab (Elysium style)
			local tabText = "  " .. tostring(Page.Name):lower() .. "  "
			local tabWidth = math.max(50, #tabText * 7)
			local Page_Tab = utility:RenderObject("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Page.Window["TabsHolder"],
				Size = UDim2.new(0, tabWidth, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = tabText,
				TextColor3 = Color3.fromRGB(210, 210, 215), -- Brighter inactive text
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 5
			})
			utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Page_Tab
			})
			-- Linoria-style small rectangle indicator for active tab
			local Page_Tab_Underline = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Parent = Page_Tab,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -2),
				Size = UDim2.new(0, math.clamp(tabWidth - 18, 14, 36), 0, 3),
				Visible = false,
				ZIndex = 6
			})
			utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 1),
				Parent = Page_Tab_Underline
			})
			--
			local Page_Page = utility:RenderObject("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Page.Window["PagesHolder"],
				Position = UDim2.new(0, 12, 0, 12),
				Size = UDim2.new(1, -24, 1, -24),
				ZIndex = 3,
				Visible = false
			})
			--
			-- Left column (scrollable)
			local Page_Page_Left = utility:RenderObject("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Page_Page,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0.5, -8, 1, 0),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = Color3.fromRGB(90, 90, 100),
				ScrollBarImageTransparency = 0.3,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				ZIndex = 2
			})
			--
			-- Right column (scrollable)
			local Page_Page_Right = utility:RenderObject("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Page_Page,
				Position = UDim2.new(0.5, 8, 0, 0),
				Size = UDim2.new(0.5, -8, 1, 0),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = Color3.fromRGB(90, 90, 100),
				ScrollBarImageTransparency = 0.3,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				ZIndex = 2
			})
			--
			local Page_Left_List = utility:RenderObject("UIListLayout", {
				Padding = UDim.new(0, 10),
				Parent = Page_Page_Left,
				FillDirection = "Vertical",
				HorizontalAlignment = "Left",
				VerticalAlignment = "Top"
			})
			utility:RenderObject("UIPadding", {
				Parent = Page_Page_Left,
				PaddingRight = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 12)
			})
			--
			local Page_Right_List = utility:RenderObject("UIListLayout", {
				Padding = UDim.new(0, 10),
				Parent = Page_Page_Right,
				FillDirection = "Vertical",
				HorizontalAlignment = "Left",
				VerticalAlignment = "Top"
			})
			utility:RenderObject("UIPadding", {
				Parent = Page_Page_Right,
				PaddingRight = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 12)
			})
			--
			do -- // Index Setting
				Page["Page"] = Page_Page
				Page["Left"] = Page_Page_Left
				Page["Right"] = Page_Page_Right
				Page["Tab"] = Page_Tab
				Page["Underline"] = Page_Tab_Underline
				Page.Window:RegisterOutline(Page_Tab_Underline, "BackgroundColor3")
			end
			--
			do -- // Functions
				function Page:Set(state)
					Page.Open = state
					Page_Page.Visible = Page.Open
					Page_Tab_Underline.Visible = Page.Open
					Page_Tab.TextColor3 = Page.Open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
					Page_Tab.BackgroundTransparency = Page.Open and 0.88 or 1
					if Page.Open then
						Page.Window:SetPage(Page)
					end
				end
			end
			--
			do -- // Connections
				utility:CreateConnection(Page_Page_Left:GetPropertyChangedSignal("CanvasPosition"), function()
					Page.Window:ClosePopups()
				end)
				utility:CreateConnection(Page_Page_Right:GetPropertyChangedSignal("CanvasPosition"), function()
					Page.Window:ClosePopups()
				end)
				utility:CreateConnection(Page_Tab.MouseButton1Click, function()
					if not Page.Open then
						Page:Set(true)
					end
				end)
				utility:CreateConnection(Page_Tab.MouseEnter, function()
					if not Page.Open then
						Page_Tab.TextColor3 = Color3.fromRGB(220, 220, 225)
					end
				end)
				utility:CreateConnection(Page_Tab.MouseLeave, function()
					if not Page.Open then
						Page_Tab.TextColor3 = Color3.fromRGB(210, 210, 215)
					end
				end)
			end
		end
		--
		if #Page.Window.Pages == 0 then Page:Set(true) end
		Page.Window.Pages[#Page.Window.Pages + 1] = Page
		return setmetatable(Page, pages)
	end
	--
	function pages:CreateSection(Properties)
		Properties = Properties or {}
		--
		local Section = {
			Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Section"),
			Size = (Properties.size or Properties.Size or 150),
			Side = (Properties.side or Properties.Side or "Left"),
			Content = {},
			Window = self.Window,
			Page = self
		}
		--
		do
			local Section_Holder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(8, 8, 12),
				BackgroundTransparency = 0.42,
				BorderSizePixel = 0,
				Parent = Section.Page[Section.Side],
				Size = UDim2.new(1, 0, 0, Section.Size),
				ZIndex = 2
			})
			local SectionCorner = utility:RenderObject("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = Section_Holder
			})
			local SectionStroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1.2,
				Transparency = 0.55,
				Parent = Section_Holder
			})
			Section.Window:RegisterOutline(SectionStroke, "Color")
			table.insert(Section.Window.Layers, Section_Holder)
			-- //
			local Section_Holder_Extra = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				ZIndex = 2
			})
			--
			local Section_Holder_Frame = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(6, 6, 10),
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Parent = Section_Holder,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				ZIndex = 2
			})
			--
			local Section_Holder_TitleInline = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(23, 23, 23),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder,
				Position = UDim2.new(0, 9, 0, -1),
				Size = UDim2.new(0, 0, 0, 2),
				ZIndex = 5
			})
			--
			local Section_Holder_Title = utility:RenderObject("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -26, 0, 15),
				ZIndex = 5,
				Font = Enum.Font.GothamBold,
				RichText = true,
				Text = Section.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0.25,
				TextXAlignment = "Left"
			})
			-- //
			local Holder_Extra_Gradient1 = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(0, 1, 0, 1),
				Rotation = 180,
				Size = UDim2.new(1, -2, 0, 20),
				Visible = false,
				ZIndex = 4,
				Image = "rbxassetid://7783533907",
				ImageColor3 = Color3.fromRGB(23, 23, 23)
			})
			--
			local Holder_Extra_Gradient2 = utility:RenderObject("ImageLabel", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, -2, 0, 20),
				Visible = false,
				ZIndex = 4,
				Image = "rbxassetid://7783533907",
				ImageColor3 = Color3.fromRGB(23, 23, 23)
			})
			--
			local Holder_Extra_ArrowUp = utility:RenderObject("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(1, -21, 0, 0),
				Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
				Text = "",
                Visible = false,
				ZIndex = 4
			})
			--
			local Holder_Extra_ArrowDown = utility:RenderObject("TextButton", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(1, -21, 1, -(6 + 8)),
				Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
				Text = "",
                Visible = false,
				ZIndex = 4
			})
			-- //
			local Extra_ArrowUp_Image = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Holder_Extra_ArrowUp,
				Position = UDim2.new(0, 4, 0, 4),
				Size = UDim2.new(0, 7, 0, 6),
				Visible = true,
				ZIndex = 4,
				Image = "rbxassetid://8548757311",
				ImageColor3 = Color3.fromRGB(205, 205, 205)
			})
			--
			local Extra_ArrowDown_Image = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Holder_Extra_ArrowDown,
				Position = UDim2.new(0, 4, 0, 4),
				Size = UDim2.new(0, 7, 0, 6),
				Visible = true,
				ZIndex = 4,
				Image = "rbxassetid://8548723563",
				ImageColor3 = Color3.fromRGB(205, 205, 205)
			})
			--
			local Holder_Extra_Bar = utility:RenderObject("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 6, 1, 0),
				Visible = false,
				ZIndex = 4
			})
			--
			local Holder_Extra_Line = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Extra,
				Position = UDim2.new(0, 0, 0, -1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 4
			})
			--
			local Holder_Frame_ContentHolder = utility:RenderObject("ScrollingFrame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Section_Holder_Frame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 4,
				AutomaticCanvasSize = "Y",
				BottomImage = "rbxassetid://7783554086",
				CanvasSize = UDim2.new(0, 0, 0, 0),
				MidImage = "rbxassetid://7783554086",
				ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
				ScrollBarImageTransparency = 0,
				ScrollBarThickness = 5,
				TopImage = "rbxassetid://7783554086",
				VerticalScrollBarInset = "None"
			})
			-- //
			local Frame_ContentHolder_List = utility:RenderObject("UIListLayout", {
				Padding = UDim.new(0, 0),
				Parent = Holder_Frame_ContentHolder,
				FillDirection = "Vertical",
				HorizontalAlignment = "Center",
				VerticalAlignment = "Top"
			})
			--
			local Frame_ContentHolder_Padding = utility:RenderObject("UIPadding", {
				Parent = Holder_Frame_ContentHolder,
				PaddingTop = UDim.new(0, 15),
				PaddingBottom = UDim.new(0, 15)
			})
			--
			do -- // Section Init
				Section_Holder_TitleInline.Size = UDim2.new(0, Section_Holder_Title.TextBounds.X + 6, 0, 2)
				Holder_Extra_Line.Visible = false
				Section.Window:RegisterOutline(SectionStroke, "Color")
			end
			--
			do -- // Index Setting
				Section["Holder"] = Holder_Frame_ContentHolder
				Section["Extra"] = Section_Holder_Extra
			end
			--
			do -- // Functions
				function Section:CloseContent()
					Section.Window:ClosePopups()
				end
			end
			--
			do -- // Connections
				utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
					Holder_Frame_ContentHolder.ScrollingEnabled = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
					Holder_Extra_Gradient1.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
					Holder_Extra_Gradient2.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
					Holder_Extra_Bar.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
                    --
                    if (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y) then
                        Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 5)
                        Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 5 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
                    end
				end)
				--
				utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("CanvasPosition"), function()
					Section.Window:ClosePopups()
                    --
                    Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 1)
                    Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 1 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
				end)
                --
                utility:CreateConnection(Holder_Extra_ArrowUp.MouseButton1Click, function()
					Holder_Frame_ContentHolder.CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y - 10, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
				end)
                --
                utility:CreateConnection(Holder_Extra_ArrowDown.MouseButton1Click, function()
					Holder_Frame_ContentHolder.CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y + 10, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
				end)
			end
		end
		--
		return setmetatable(Section, sections)
	end
	--
	do -- // Content
		local function openListPopup(Content, Anchor, Header, IsPicked, OnPick)
			local Window = Content.Window
			Window:ClosePopups()
			--
			local Gui = Window.ScreenGui
			local RowHeight = 18
			local Count = #Content.Options
			local Height = math.min(Count, 8) * RowHeight + 2
			local Pos, Size = Anchor.AbsolutePosition, Anchor.AbsoluteSize
			local Y = Pos.Y + Size.Y + 2
			if Y + Height > Gui.AbsoluteSize.Y - 4 then
				Y = math.max(4, Pos.Y - Height - 2)
			end
			local Connections = {}
			local Rows = {}
			--
			local Holder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(12, 12, 12),
				BorderSizePixel = 0,
				Parent = Gui,
				Position = UDim2.fromOffset(Pos.X, Y),
				Size = UDim2.fromOffset(Size.X, Height),
				ZIndex = 1000
			})
			utility:RenderObject("UIStroke", {Color = Window.Outline, Thickness = 1, Transparency = 0.4, Parent = Holder})
			local Scroll = utility:RenderObject("ScrollingFrame", {
				Active = true,
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = Holder,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				CanvasSize = UDim2.new(0, 0, 0, Count * RowHeight),
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130),
				ScrollingEnabled = Count > 8,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				VerticalScrollBarInset = Enum.ScrollBarInset.None,
				ElasticBehavior = Enum.ElasticBehavior.Never,
				ZIndex = 1001
			})
			--
			for Index, Option in ipairs(Content.Options) do
				local Row = utility:RenderObject("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					BorderSizePixel = 0,
					Parent = Scroll,
					Position = UDim2.new(0, 0, 0, RowHeight * (Index - 1)),
					Size = UDim2.new(1, 0, 0, RowHeight),
					ZIndex = 1002,
					Font = Enum.Font.Gotham,
					Text = tostring(Option),
					TextColor3 = Color3.fromRGB(220, 220, 225),
					TextSize = 10,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				utility:RenderObject("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = Row})
				Rows[Index] = Row
				table.insert(Connections, Row.MouseButton1Click:Connect(function()
					OnPick(Index)
				end))
				table.insert(Connections, Row.MouseEnter:Connect(function()
					Row.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
				end))
				table.insert(Connections, Row.MouseLeave:Connect(function()
					Row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				end))
			end
			--
			table.insert(Connections, uis.InputBegan:Connect(function(Input)
				if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
				local Position = utility:InputPosition(Input)
				if utility:Inside(Holder, Position) or utility:Inside(Anchor, Position) then return end
				Window:ClosePopups()
			end))
			--
			function Content.Content:Refresh()
				for Index, Row in ipairs(Rows) do
					local Picked = IsPicked(Index)
					Row.TextColor3 = Picked and Window.Accent or Color3.fromRGB(220, 220, 225)
					Row.Font = Picked and Enum.Font.GothamBold or Enum.Font.Gotham
				end
			end
			--
			function Content.Content:Close()
				Content.Content.Open = false
				if Window.OpenContent == Content.Content then
					Window.OpenContent = nil
				end
				Header.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
				for _, Connection in ipairs(Connections) do
					Connection:Disconnect()
				end
				Holder:Destroy()
				function Content.Content:Refresh() end
			end
			--
			Content.Content.Open = true
			Window.OpenContent = Content.Content
			Header.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
			Content.Content:Refresh()
			--
			for Index = 1, Count do
				if IsPicked(Index) then
					Scroll.CanvasPosition = Vector2.new(0, math.clamp((Index - 1) * RowHeight - RowHeight * 2, 0, math.max(0, Count * RowHeight - (Height - 2))))
					break
				end
			end
		end
		--
		function sections:CreateToggle(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 8 + 10),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(40, 40, 48), -- Visible box background
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 16, 0, 4),
					Size = UDim2.new(0, 12, 0, 12),
					ZIndex = 3
				})
				utility:RenderObject("UICorner", {
					CornerRadius = UDim.new(0, 2),
					Parent = Content_Holder_Outline
				})
				utility:RenderObject("UIStroke", {
					Color = Color3.fromRGB(100, 100, 110),
					Thickness = 1,
					Parent = Content_Holder_Outline
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 36, 0, 0),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold, -- Bold font
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235), -- Brighter text
					TextSize = 11, -- Slightly larger
					TextXAlignment = Enum.TextXAlignment.Left
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(120, 120, 130), -- Visible toggle fill
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200)),
					Enabled = true,
					Rotation = 90,
					Parent = Holder_Outline_Frame
				})
				--
				do -- // Functions
					function Content:UpdateColor()
						Holder_Outline_Frame.BackgroundColor3 = Content.State and Content.Window.Accent or Color3.fromRGB(80, 80, 90)
					end
					--
					function Content:Set(state)
						Content.State = state and true or false
						Content:UpdateColor()
						Content.Callback(Content:Get())
					end
					--
					function Content:Get()
						return Content.State
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						Content:Set(not Content:Get())
					end)
					
					--
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(230, 230, 230))
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
					end)
				end
				--
				Content:Set(Content.State)
				Content.Window:RegisterAccent(function() Content:UpdateColor() end)

				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Element")))
				local uniqueId = getUniqueId(baseId, Toggles)
				Toggles[uniqueId] = Content
			end
			--
			return Content
		end
		--
		function sections:CreateSlider(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or nil),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
				Min = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
				Max = (Properties.max or Properties.Max or Properties.maxmimum or Properties.Maximum or 100),
				Ending = (Properties.ending or Properties.Ending or Properties.suffix or Properties.Suffix or ""),
				Decimals = (1 / (Properties.decimals or Properties.Decimals or Properties.tick or Properties.Tick or 1)),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Holding = false,
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, (Content.Name and 24 or 13) + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, Content.Name and 18 or 5),
					Size = UDim2.new(1, -99, 0, 7),
					ZIndex = 3
				})
				--
				if Content.Name then
					local Content_Holder_Title = utility:RenderObject("TextLabel", {
						AnchorPoint = Vector2.new(0, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Parent = Content_Holder,
						Position = UDim2.new(0, 41, 0, 4),
						Size = UDim2.new(1, -41, 0, 10),
						ZIndex = 3,
						Font = Enum.Font.GothamBold,
						RichText = true,
						Text = Content.Name,
						TextColor3 = Color3.fromRGB(230, 230, 235),
						TextSize = 10,
						TextStrokeTransparency = 1,
						TextXAlignment = "Left"
					})
				end
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(71, 71, 71),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Slider = utility:RenderObject("Frame", {
					BackgroundColor3 = Content.Window.Accent,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(0, 0, 1, 0),
					ZIndex = 3
				})
				--
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
                -- //
                local Frame_Slider_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175)),
					Enabled = true,
					Rotation = 90,
					Parent = Outline_Frame_Slider
				})
				-- //
				local Frame_Slider_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Outline_Frame_Slider,
					Position = UDim2.new(1, 0, 0.5, 1),
					Size = UDim2.new(0, 2, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 11,
					TextStrokeTransparency = 0.5,
					TextXAlignment = "Center",
					RenderTime = 0.15
				})
				--
				do -- // Functions
					function Content:Set(state)
						state = tonumber(state) or Content.Min
						Content.State = math.clamp(math.round(state * Content.Decimals) / Content.Decimals, Content.Min, Content.Max)
						--
						Frame_Slider_Title.Text = "<b>" .. Content.State .. Content.Ending .. "</b>"
						Outline_Frame_Slider.Size = UDim2.new(math.clamp((Content.State - Content.Min) / math.max(Content.Max - Content.Min, 1e-9), 0, 1), 0, 1, 0)
						--
						Content.Callback(Content:Get())
					end
					--
					function Content:Refresh(Position)
						local X = (Position or utility:MouseLocation()).X
						local Width = math.max(Holder_Outline_Frame.AbsoluteSize.X, 1)
						local Alpha = math.clamp((X - Holder_Outline_Frame.AbsolutePosition.X) / Width, 0, 1)
						Content:Set(Content.Min + (Content.Max - Content.Min) * Alpha)
					end
					--
					function Content:Get()
						return Content.State
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function(Input)
						Content:Refresh()
						--
						Content.Holding = true
                        --
                        Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Content.Holding and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(175, 175, 175))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Content.Holding and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(175, 175, 175))
					end)
					--
					utility:CreateConnection(uis.InputChanged, function(Input)
						if Content.Holding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
							Content:Refresh(utility:InputPosition(Input))
						end
					end)
					--
					utility:CreateConnection(uis.InputEnded, function(Input)
						if Content.Holding and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
							Content.Holding = false
                            --
                            Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175))
                        	Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175))
						end
					end)
				end
				--
				Content:Set(Content.State)
				Content.Window:RegisterAccent(function(Color) Outline_Frame_Slider.BackgroundColor3 = Color end)

				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Slider")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			--
			return Content
		end
		--
		function sections:CreateDropdown(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or 1),
				Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = {
					Open = false
				},
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			-- Ensure there is at least one option to prevent invisible dropdowns
			if #Content.Options == 0 then
				Content.Options = {"--"}
			end
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 34 + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, 15),
					Size = UDim2.new(1, -98, 0, 20),
					ZIndex = 3
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235),
					TextSize = 10,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(36, 36, 36),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
				--
				local Outline_Frame_Title = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, -24, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					RichText = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Text = "",
					TextColor3 = Color3.fromRGB(220, 220, 225), -- Brighter dropdown text
					TextSize = 10,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(1, -11, 0.5, -4),
					Size = UDim2.new(0, 7, 0, 6),
					Image = "rbxassetid://8532000591",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 3
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = state
						--
						Outline_Frame_Title.Text = tostring(Content.Options[Content:Get()] or "--")
						--
						Content.Callback(Content:Get())
						--
						if Content.Content.Open then
							Content.Content:Refresh(Content:Get())
						end
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					-- swap the option list at runtime (used by the config list); does not fire the callback
					function Content:SetOptions(list, selectName)
						Content.Section:CloseContent()
						Content.Options = list or {}
						if #Content.Options == 0 then
							Content.Options = {"--"}
						end
						local idx = 1
						if selectName ~= nil then
							for i, v in ipairs(Content.Options) do
								if tostring(v) == tostring(selectName) then
									idx = i
									break
								end
							end
						end
						Content.State = idx
						Outline_Frame_Title.Text = tostring(Content.Options[idx] or "--")
					end
					--
					function Content:Open()
						openListPopup(Content, Content_Holder_Outline, Holder_Outline_Frame, function(Index)
							return Index == Content.State
						end, function(Index)
							Content:Set(Index)
							Content.Window:ClosePopups()
						end)
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						if Content.Content.Open then
							Content.Window:ClosePopups()
						else
							Content:Open()
						end
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Content.Content.Open and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(36, 36, 36)
					end)
				end
				--
				Content:Set(Content.State)
				
				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Dropdown")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			--
			return Content
		end
		--
		function sections:CreateMultibox(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or {1}),
				Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
				Minimum = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
				Maximum = (Properties.max or Properties.Max or Properties.maximum or Properties.Maximum or 1000),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = {
					Open = false
				},
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 34 + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, 15),
					Size = UDim2.new(1, -98, 0, 20),
					ZIndex = 3
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235),
					TextSize = 10,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(36, 36, 36),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
				--
				local Outline_Frame_Title = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, -24, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					RichText = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Text = "",
					TextColor3 = Color3.fromRGB(220, 220, 225),
					TextSize = 10,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(1, -11, 0.5, -4),
					Size = UDim2.new(0, 7, 0, 6),
					Image = "rbxassetid://8532000591",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 3
				})
				--
				do -- // Functions
					function Content:Set(state)
						table.sort(state)
						Content.State = state
						--
						local Serialised = utility:Serialise(utility:Sort(Content:Get(), Content.Options))
						--
						Serialised = Serialised == "" and "-" or Serialised
						--
						Outline_Frame_Title.Text = Serialised
						--
						Content.Callback(Content:Get())
						--
						if Content.Content.Open then
							Content.Content:Refresh(Content:Get())
						end
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					function Content:Open()
						openListPopup(Content, Content_Holder_Outline, Holder_Outline_Frame, function(Index)
							return table.find(Content.State, Index) ~= nil
						end, function(Index)
							local NewTable = Content:Get()
							local Found = table.find(NewTable, Index)
							if Found then
								if (#NewTable - 1) >= Content.Minimum then
									table.remove(NewTable, Found)
								end
							else
								if (#NewTable + 1) <= Content.Maximum then
									table.insert(NewTable, Index)
								end
							end
							Content:Set(NewTable)
						end)
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						if Content.Content.Open then
							Content.Window:ClosePopups()
						else
							Content:Open()
						end
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Content.Content.Open and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(36, 36, 36)
					end)
				end
				--
				Content:Set(Content.State)
				
				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Multibox")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			--
			return Content
		end
		--
		function sections:CreateKeybind(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil),
                Mode = (Properties.mode or Properties.Mode or "Hold"),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
                Active = false,
                Holding = false,
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
            --
            local Keys = {
                KeyCodes = {
					"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M",
					"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero",
					"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
					"Insert", "Delete", "Tab", "Home", "End", "PageUp", "PageDown",
					"LeftAlt", "LeftControl", "LeftShift", "RightAlt", "RightControl", "RightShift", "CapsLock",
					"Space", "Backquote", "Minus", "Equals", "LeftBracket", "RightBracket", "BackSlash", "Semicolon", "Quote", "Comma", "Period", "Slash"
				},
                Inputs = {"MouseButton1", "MouseButton2", "MouseButton3"},
                Shortened = {
					["MouseButton1"] = "M1", ["MouseButton2"] = "M2", ["MouseButton3"] = "M3",
					["Insert"] = "INS", ["Delete"] = "DEL", ["PageUp"] = "PGUP", ["PageDown"] = "PGDN",
					["LeftAlt"] = "LALT", ["LeftControl"] = "LCTRL", ["LeftShift"] = "LSHIFT",
					["RightAlt"] = "RALT", ["RightControl"] = "RCTRL", ["RightShift"] = "RSHIFT",
					["CapsLock"] = "CAPS", ["Backquote"] = "`", ["Minus"] = "-", ["Equals"] = "=",
					["LeftBracket"] = "[", ["RightBracket"] = "]", ["BackSlash"] = "\\",
					["Semicolon"] = ";", ["Quote"] = "'", ["Comma"] = ",", ["Period"] = ".", ["Slash"] = "/",
					["Space"] = "SPACE"
				}
            }
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 8 + 10),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -41, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235),
					TextSize = 10,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
                -- //
                local Content_Holder_Value = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -61, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					RichText = true,
					Text =  "",
					TextColor3 = Color3.fromRGB(255, 255, 255), -- Brighter keybind value
                    TextStrokeColor3 = Color3.fromRGB(15, 15, 15),
					TextSize = 10,
					TextStrokeTransparency = 0,
					TextXAlignment = "Right"
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = state or {}
                        Content.Active = false
                        --
                        Content_Holder_Value.Text = "[" .. (#Content:Get() > 0 and Content:Shorten(Content:Get()[2]) or "-") .. "]"
						--
						Content.Callback(Content:Get())
					end
					--
					function Content:Get()
						return Content.State
					end
                    --
                    function Content:Shorten(Str)
                        for Index, Value in pairs(Keys.Shortened) do
                            Str = string.gsub(Str, Index, Value)
                        end
                        --
                        return Str
                    end
                    --
                    function Content:Change(Key)
                        if Key.EnumType then
                            if Key.EnumType == Enum.KeyCode or Key.EnumType == Enum.UserInputType then
                                if table.find(Keys.KeyCodes, Key.Name) or table.find(Keys.Inputs, Key.Name) then
                                    Content:Set({Key.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType", Key.Name})
                                    return true
                                end
                            end
                        end
                    end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						Content.Holding = true
						Content.Window.Binding = true
						Content_Holder_Value.TextColor3 = Color3.fromRGB(255, 0, 0)
					end)
                    --
                    utility:CreateConnection(Content_Holder_Button.MouseButton2Click, function(Input)
						Content:Set()
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Content_Holder_Value.TextColor3 = Color3.fromRGB(230, 230, 235)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Content_Holder_Value.TextColor3 = Content.Holding and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 205)
					end)
                    --
                    utility:CreateConnection(uis.InputBegan, function(Input)
                        if Content.Holding then
							if Input.KeyCode == Enum.KeyCode.Escape then
								Content.Holding = false
								Content.Window.Binding = false
								Content_Holder_Value.TextColor3 = Color3.fromRGB(255, 255, 255)
								return
							end
							local Success = Content:Change(Input.KeyCode.Name ~= "Unknown" and Input.KeyCode or Input.UserInputType)
							if Success then
								Content.Holding = false
								Content.Window.Binding = false
								Content_Holder_Value.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						end
                        --
                        if Content:Get()[1] and Content:Get()[2] then
                            if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                                if Content.Mode == "Hold" then
                                    Content.Active = true
                                elseif Content.Mode == "Toggle" then
                                    Content.Active = not Content.Active
                                end
                            end
                        end
                    end)
                    --
                    utility:CreateConnection(uis.InputEnded, function(Input)
                        if Content:Get()[1] and Content:Get()[2] then
                            if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                                if Content.Mode == "Hold" then
                                    Content.Active = false
                                end
                            end
                        end
                    end)
				end
				--
				Content:Set(Content.State)
				
				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Keybind")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			--
			return Content
		end
		--
		function sections:CreateColorpicker(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Color"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 255, 255)),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = { Open = false },
				Window = self.Window,
				Page = self.Page,
				Section = self,
				Hue = 0,
				Sat = 1,
				Val = 1
			}
			-- init HSV from state
			do
				local h, s, v = Color3.toHSV(Content.State)
				Content.Hue, Content.Sat, Content.Val = h, s, v
			end
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 8 + 10),
					ZIndex = 3
				})
				--
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(22, 22, 26),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(1, -40, 0, 3),
					Size = UDim2.new(0, 22, 0, 12),
					ZIndex = 3
				})
				local CPCorner = utility:RenderObject("UICorner", {
					CornerRadius = UDim.new(0, 3),
					Parent = Content_Holder_Outline
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -70, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235),
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					ZIndex = 4
				})
				--
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Content.State,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				local CPInnerCorner = utility:RenderObject("UICorner", {
					CornerRadius = UDim.new(0, 2),
					Parent = Holder_Outline_Frame
				})
				--
				do -- // Functions
					function Content:Set(state)
						if typeof(state) == "Color3" then
							Content.State = state
							local h, s, v = Color3.toHSV(state)
							Content.Hue, Content.Sat, Content.Val = h, s, v
						end
						Holder_Outline_Frame.BackgroundColor3 = Content.State
						Content.Callback(Content:Get())
						if Content.Content.Open and Content.Content.Refresh then
							Content.Content:Refresh()
						end
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					function Content:Open()
						local Window = Content.Window
						Window:ClosePopups()
						--
						local Gui = Window.ScreenGui
						local Connections = {}
						local DraggingSV, DraggingHue = false, false
						local Pos, Size = Content_Holder_Outline.AbsolutePosition, Content_Holder_Outline.AbsoluteSize
						local W, H = 176, 196
						local X = math.clamp(Pos.X + Size.X - W, 4, math.max(4, Gui.AbsoluteSize.X - W - 4))
						local Y = Pos.Y + Size.Y + 4
						if Y + H > Gui.AbsoluteSize.Y - 4 then
							Y = math.max(4, Pos.Y - H - 4)
						end
						--
						local Holder = utility:RenderObject("Frame", {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Parent = Gui,
							Position = UDim2.fromOffset(X, Y),
							Size = UDim2.fromOffset(W, H),
							ZIndex = 1000
						})
						local Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(30, 30, 36),
							BorderSizePixel = 0,
							Parent = Holder,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 1001
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Outline})
						utility:RenderObject("UIStroke", {Color = Window.Outline, Thickness = 1, Parent = Outline})
						local Inner = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(8, 8, 10),
							BorderSizePixel = 0,
							Parent = Outline,
							Position = UDim2.new(0, 4, 0, 4),
							Size = UDim2.new(1, -8, 1, -8),
							ZIndex = 1002
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Inner})
						--
						local SV = utility:RenderObject("Frame", {
							Active = true,
							BackgroundColor3 = Color3.fromHSV(Content.Hue, 1, 1),
							BorderSizePixel = 0,
							Parent = Inner,
							Position = UDim2.new(0, 6, 0, 6),
							Size = UDim2.new(0, 130, 0, 130),
							ZIndex = 1003
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = SV})
						local WhiteLayer = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Parent = SV,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 1004
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = WhiteLayer})
						utility:RenderObject("UIGradient", {
							Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
							Parent = WhiteLayer
						})
						local BlackLayer = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = SV,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 1005
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = BlackLayer})
						utility:RenderObject("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
							Parent = BlackLayer
						})
						local SVCursor = utility:RenderObject("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Parent = SV,
							Position = UDim2.new(Content.Sat, 0, 1 - Content.Val, 0),
							Size = UDim2.new(0, 8, 0, 8),
							ZIndex = 1006
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SVCursor})
						utility:RenderObject("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5, Parent = SVCursor})
						--
						local HueBar = utility:RenderObject("Frame", {
							Active = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Parent = Inner,
							Position = UDim2.new(0, 142, 0, 6),
							Size = UDim2.new(0, 16, 0, 130),
							ZIndex = 1003
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = HueBar})
						utility:RenderObject("UIGradient", {
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
							}),
							Parent = HueBar
						})
						local HueCursor = utility:RenderObject("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Parent = HueBar,
							Position = UDim2.new(0.5, 0, Content.Hue, 0),
							Size = UDim2.new(1, 4, 0, 6),
							ZIndex = 1006
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 2), Parent = HueCursor})
						utility:RenderObject("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = HueCursor})
						--
						local Preview = utility:RenderObject("Frame", {
							BackgroundColor3 = Content.State,
							BorderSizePixel = 0,
							Parent = Inner,
							Position = UDim2.new(0, 6, 0, 142),
							Size = UDim2.new(1, -12, 0, 10),
							ZIndex = 1003
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Preview})
						local Hex = utility:RenderObject("TextBox", {
							BackgroundColor3 = Color3.fromRGB(22, 22, 26),
							BorderSizePixel = 0,
							ClearTextOnFocus = false,
							Font = Enum.Font.Code,
							Parent = Inner,
							Position = UDim2.new(0, 6, 0, 158),
							Size = UDim2.new(1, -12, 0, 20),
							Text = "#" .. Content.State:ToHex():upper(),
							TextColor3 = Color3.fromRGB(230, 230, 235),
							TextSize = 11,
							ZIndex = 1003
						})
						utility:RenderObject("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Hex})
						--
						local function applyColor()
							Content.State = Color3.fromHSV(Content.Hue, Content.Sat, Content.Val)
							Holder_Outline_Frame.BackgroundColor3 = Content.State
							Preview.BackgroundColor3 = Content.State
							SV.BackgroundColor3 = Color3.fromHSV(Content.Hue, 1, 1)
							Hex.Text = "#" .. Content.State:ToHex():upper()
							Content.Callback(Content.State)
						end
						--
						local function updateSV(Position)
							local P, S = SV.AbsolutePosition, SV.AbsoluteSize
							local x = math.clamp((Position.X - P.X) / S.X, 0, 1)
							local y = math.clamp((Position.Y - P.Y) / S.Y, 0, 1)
							Content.Sat = x
							Content.Val = 1 - y
							SVCursor.Position = UDim2.new(x, 0, y, 0)
							applyColor()
						end
						--
						local function updateHue(Position)
							local P, S = HueBar.AbsolutePosition, HueBar.AbsoluteSize
							local y = math.clamp((Position.Y - P.Y) / S.Y, 0, 1)
							Content.Hue = y
							HueCursor.Position = UDim2.new(0.5, 0, y, 0)
							applyColor()
						end
						--
						local function isPress(Input)
							return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch
						end
						--
						table.insert(Connections, SV.InputBegan:Connect(function(Input)
							if isPress(Input) then
								DraggingSV = true
								updateSV(utility:InputPosition(Input))
							end
						end))
						table.insert(Connections, HueBar.InputBegan:Connect(function(Input)
							if isPress(Input) then
								DraggingHue = true
								updateHue(utility:InputPosition(Input))
							end
						end))
						table.insert(Connections, uis.InputChanged:Connect(function(Input)
							if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
								if DraggingSV then updateSV(utility:InputPosition(Input)) end
								if DraggingHue then updateHue(utility:InputPosition(Input)) end
							end
						end))
						table.insert(Connections, uis.InputEnded:Connect(function(Input)
							if isPress(Input) then
								DraggingSV = false
								DraggingHue = false
							end
						end))
						table.insert(Connections, Hex.FocusLost:Connect(function()
							local Ok, Color = pcall(Color3.fromHex, Hex.Text)
							if Ok and typeof(Color) == "Color3" then
								Content:Set(Color)
							else
								Hex.Text = "#" .. Content.State:ToHex():upper()
							end
						end))
						table.insert(Connections, uis.InputBegan:Connect(function(Input)
							if not isPress(Input) then return end
							local Position = utility:InputPosition(Input)
							if utility:Inside(Holder, Position) or utility:Inside(Content_Holder, Position) then return end
							Window:ClosePopups()
						end))
						--
						function Content.Content:Close()
							Content.Content.Open = false
							if Window.OpenContent == Content.Content then
								Window.OpenContent = nil
							end
							for _, Connection in ipairs(Connections) do
								Connection:Disconnect()
							end
							Holder:Destroy()
							function Content.Content:Refresh() end
						end
						--
						function Content.Content:Refresh()
							SVCursor.Position = UDim2.new(Content.Sat, 0, 1 - Content.Val, 0)
							HueCursor.Position = UDim2.new(0.5, 0, Content.Hue, 0)
							SV.BackgroundColor3 = Color3.fromHSV(Content.Hue, 1, 1)
							Preview.BackgroundColor3 = Content.State
							Hex.Text = "#" .. Content.State:ToHex():upper()
						end
						--
						Content.Content.Open = true
						Window.OpenContent = Content.Content
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function()
						if Content.Content.Open then
							Content.Window:ClosePopups()
						else
							Content:Open()
						end
					end)
				end
				--
				Content:Set(Content.State)
				
				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Colorpicker")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			--
			return Content
		end
		--


		function sections:CreateSeparator(Properties)
			Properties = Properties or {}
			local Content = {
				Name = (Properties.name or Properties.Name or ""),
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 10),
					ZIndex = 3
				})
				local Line = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(80, 80, 90),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 16, 0.5, 0),
					Size = UDim2.new(1, -32, 0, 1),
					ZIndex = 3
				})
			end
			return Content
		end
		--
		function sections:CreateLabel(Properties)
			Properties = Properties or {}
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Label"),
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 18),
					ZIndex = 3
				})
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 20, 0, 0),
					Size = UDim2.new(1, -40, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(240, 240, 245),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				-- update the label text at runtime (used by the autoload line)
				function Content:SetText(t)
					Content_Holder_Title.Text = tostring(t)
				end
			end
			return Content
		end
		--

		function sections:CreateTextbox(Properties)
			Properties = Properties or {}
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Textbox"),
				State = tostring(Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or ""),
				Placeholder = (Properties.placeholder or Properties.Placeholder or "Enter text..."),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 36),
					ZIndex = 3
				})
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 20, 0, 2),
					Size = UDim2.new(1, -40, 0, 12),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(230, 230, 235),
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local BoxOutline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(22, 22, 26),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 20, 0, 16),
					Size = UDim2.new(1, -40, 0, 18),
					ZIndex = 3
				})
				utility:RenderObject("UICorner", { CornerRadius = UDim.new(0, 3), Parent = BoxOutline })
				utility:RenderObject("UIStroke", { Color = Color3.fromRGB(80, 80, 90), Thickness = 1, Parent = BoxOutline })
				local Box = utility:RenderObject("TextBox", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = BoxOutline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 4,
					Font = Enum.Font.Gotham,
					Text = Content.State,
					PlaceholderText = Content.Placeholder,
					PlaceholderColor3 = Color3.fromRGB(140, 140, 150),
					TextColor3 = Color3.fromRGB(240, 240, 245),
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false
				})
				utility:RenderObject("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Box })
				utility:RenderObject("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = Box })
				--
				function Content:Set(text)
					Content.State = tostring(text or "")
					Box.Text = Content.State
					Content.Callback(Content.State)
				end
				function Content:Get()
					return Content.State
				end
				--
				utility:CreateConnection(Box.FocusLost, function(enter)
					Content.State = Box.Text
					Content.Callback(Content.State)
				end)
				utility:CreateConnection(Box:GetPropertyChangedSignal("Text"), function()
					Content.State = Box.Text
				end)
				
				-- Register for config
				local baseId = (Properties.Id or ((self.Page.Name or "Page") .. "." .. (self.Name or "Section") .. "." .. (Content.Name or "Textbox")))
				local uniqueId = getUniqueId(baseId, Options)
				Options[uniqueId] = Content
			end
			return Content
		end
		--
		function sections:CreateButton(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Button"),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = Content.Section.Holder,
					Size = UDim2.new(1, 0, 0, 28),
					ZIndex = 3
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.88,
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 20, 0, 2),
					Size = UDim2.new(1, -40, 0, 24),
					ZIndex = 3,
					Font = Enum.Font.GothamBold,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					AutoButtonColor = false
				})
				local BtnCorner = utility:RenderObject("UICorner", {
					CornerRadius = UDim.new(0, 5),
					Parent = Content_Holder_Button
				})
				local BtnStroke = utility:RenderObject("UIStroke", {
					Color = Color3.fromRGB(255, 255, 255),
					Thickness = 1,
					Transparency = 0.45,
					Parent = Content_Holder_Button
				})
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function()
						Content.Callback()
					end)
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
						Content_Holder_Button.BackgroundTransparency = 0.75
						Content_Holder_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
						BtnStroke.Transparency = 0.15
						BtnStroke.Color = Content.Window.Outline
					end)
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
						Content_Holder_Button.BackgroundTransparency = 0.88
						Content_Holder_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
						BtnStroke.Transparency = 0.45
						BtnStroke.Color = Color3.fromRGB(255, 255, 255)
					end)
				end
			end
			--
			return Content
		end
	end


	-- [[ ============================================================ ]]
	-- [[  SAVE MANAGER (creep.cc / Linoria config manager)           ]]
	-- [[ ============================================================ ]]
	local SaveManager = {
		Folder = (library and library.Folder) or "Zx64",
		Ignore = {},
		Window = nil,
		NameBox = nil,
		List = nil,
		AutoloadLabel = nil,
		NotifyArea = nil,
		NotifyCounter = 0,
	}

	-- Linoria style button row (1 or 2 buttons side by side)
	function sections:CreateButtonRow(list)
		local N = #list
		local Holder = utility:RenderObject("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = self.Holder,
			Size = UDim2.new(1, 0, 0, 28),
			ZIndex = 3
		})
		local gap = 4
		local shrink = (40 + (N - 1) * gap) / N
		for i, info in ipairs(list) do
			local Body = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderSizePixel = 0,
				Parent = Holder,
				Position = UDim2.new((i - 1) / N, 20 + (i - 1) * (gap - shrink), 0, 2),
				Size = UDim2.new(1 / N, -shrink, 0, 24),
				ZIndex = 3
			})
			utility:RenderObject("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(212, 212, 212)),
				Rotation = 90,
				Parent = Body
			})
			local Stroke = utility:RenderObject("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = Body
			})
			local Btn = utility:RenderObject("TextButton", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Body,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 4,
				Font = Enum.Font.Code,
				Text = info.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13,
				TextStrokeTransparency = 0,
				AutoButtonColor = false
			})
			utility:CreateConnection(Btn.MouseButton1Click, function()
				info.Callback()
			end)
			utility:CreateConnection(Btn.MouseEnter, function()
				Stroke.Color = self.Window.Accent
			end)
			utility:CreateConnection(Btn.MouseLeave, function()
				Stroke.Color = Color3.fromRGB(0, 0, 0)
			end)
		end
	end

	do
		local httpService = game:GetService("HttpService")
		local textService = game:GetService("TextService")

		local function hasFS()
			return writefile and readfile and isfile and isfolder and makefolder and listfiles and true or false
		end

		local function sanitize(name)
			name = tostring(name or "")
			name = name:gsub("[^%w%-_ ]", "")
			name = name:gsub("^%s+", ""):gsub("%s+$", "")
			return name
		end

		local function typeOf(obj)
			if obj.Type then return obj.Type end
			if obj.Hue ~= nil and obj.Sat ~= nil then return "ColorPicker" end
			if obj.Mode ~= nil and obj.Active ~= nil then return "Keybind" end
			if obj.Minimum ~= nil then return "Multibox" end
			if obj.Min ~= nil and obj.Max ~= nil then return "Slider" end
			if obj.Options ~= nil then return "Dropdown" end
			if obj.Placeholder ~= nil then return "Input" end
			return nil
		end

		-- [[ parsers ]]
		SaveManager.Parser = {
			Toggle = {
				Save = function(idx, obj)
					return { type = "Toggle", idx = idx, value = obj:Get() and true or false }
				end,
				Load = function(idx, d)
					local o = Toggles[idx]
					if o then o:Set(d.value and true or false) end
				end,
			},
			Slider = {
				Save = function(idx, obj)
					return { type = "Slider", idx = idx, value = tostring(obj:Get()) }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					local n = tonumber(d.value)
					if o and n then o:Set(n) end
				end,
			},
			Dropdown = {
				Save = function(idx, obj)
					local i = obj:Get()
					return { type = "Dropdown", idx = idx, value = i, text = tostring(obj.Options[i] or "") }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					if not o then return end
					local found
					if d.text and d.text ~= "" then
						for k, v in ipairs(o.Options) do
							if tostring(v) == d.text then found = k break end
						end
					end
					found = found or (o.Options[d.value] ~= nil and d.value or nil)
					if found then o:Set(found) end
				end,
			},
			Multibox = {
				Save = function(idx, obj)
					local texts = {}
					for _, i in ipairs(obj:Get()) do
						table.insert(texts, tostring(obj.Options[i]))
					end
					return { type = "Multibox", idx = idx, values = texts }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					if not o then return end
					local picked = {}
					for _, text in ipairs(d.values or {}) do
						for k, v in ipairs(o.Options) do
							if tostring(v) == text then table.insert(picked, k) break end
						end
					end
					o:Set(picked)
				end,
			},
			ColorPicker = {
				Save = function(idx, obj)
					return { type = "ColorPicker", idx = idx, value = obj:Get():ToHex() }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					if not o then return end
					local ok, c = pcall(Color3.fromHex, d.value)
					if ok and typeof(c) == "Color3" then o:Set(c) end
				end,
			},
			Keybind = {
				Save = function(idx, obj)
					local st = obj:Get() or {}
					return { type = "Keybind", idx = idx, key = { st[1], st[2] }, mode = obj.Mode }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					if not o then return end
					o.Mode = d.mode or o.Mode
					if d.key and d.key[1] and d.key[2] then
						o:Set({ d.key[1], d.key[2] })
					else
						o:Set(nil)
					end
				end,
			},
			Input = {
				Save = function(idx, obj)
					return { type = "Input", idx = idx, value = obj:Get() }
				end,
				Load = function(idx, d)
					local o = Options[idx]
					if o and type(d.value) == "string" then o:Set(d.value) end
				end,
			},
		}

		-- [[ setup ]]
		function SaveManager:SetIgnoreIndexes(list)
			for _, key in next, list do
				self.Ignore[key] = true
			end
		end

		function SaveManager:IgnoreThemeSettings()
			self:SetIgnoreIndexes({
				"settings.UI Colors.Accent Color",
				"settings.UI Misc.See Through",
			})
		end

		function SaveManager:SetFolder(folder)
			self.Folder = folder
			self:BuildFolderTree()
		end

		function SaveManager:BuildFolderTree()
			if not hasFS() then return end
			for _, path in ipairs({ self.Folder, self.Folder .. "/settings" }) do
				if not isfolder(path) then makefolder(path) end
			end
		end

		function SaveManager:PathFor(name)
			return self.Folder .. "/settings/" .. sanitize(name) .. ".json"
		end

		-- [[ creep.cc style notification: bottom accent bar, slides open, stacks center ]]
		function SaveManager:Notify(text, dur)
			text = tostring(text or "")
			if text == "" then return end
			local gui = self.Window and self.Window.MainFrame and self.Window.MainFrame.Parent
			if not gui then return end
			local accent = self.Window.Accent

			if not self.NotifyArea or not self.NotifyArea.Parent then
				local area = Instance.new("Frame")
				area.Name = "Zx64_NotifyArea"
				area.BackgroundTransparency = 1
				area.AnchorPoint = Vector2.new(0.5, 1)
				area.Position = UDim2.new(0.5, 0, 1, -56) -- center bottom, a bit higher
				area.Size = UDim2.new(0, 0, 0, 0)
				area.AutomaticSize = Enum.AutomaticSize.XY
				area.ZIndex = 2000
				area.Parent = gui
				local layout = Instance.new("UIListLayout")
				layout.Padding = UDim.new(0, 6)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
				layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				layout.Parent = area
				self.NotifyArea = area
			end

			self.NotifyCounter = self.NotifyCounter + 1
			local H = 22
			local w = textService:GetTextSize(text, 13, Enum.Font.Code, Vector2.new(1920, 1080)).X

			local Outer = Instance.new("Frame")
			Outer.BackgroundTransparency = 1
			Outer.BorderSizePixel = 0
			Outer.ClipsDescendants = true
			Outer.Size = UDim2.fromOffset(0, H)
			Outer.LayoutOrder = self.NotifyCounter
			Outer.ZIndex = 2001
			Outer.Parent = self.NotifyArea

			local Inner = Instance.new("Frame")
			Inner.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			Inner.BackgroundTransparency = 0.6
			Inner.BorderSizePixel = 0
			Inner.Size = UDim2.new(1, 0, 1, 0)
			Inner.ZIndex = 2002
			Inner.Parent = Outer
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(31, 31, 31)
			stroke.Transparency = 0.6
			stroke.Thickness = 1
			stroke.Parent = Inner

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0, 8, 0, 0)
			Label.Size = UDim2.new(1, -8, 1, 0)
			Label.Font = Enum.Font.Code
			Label.Text = text
			Label.TextSize = 13
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.ZIndex = 2003
			Label.Parent = Inner
			local ls = Instance.new("UIStroke")
			ls.Color = Color3.new(0, 0, 0)
			ls.Thickness = 1
			ls.LineJoinMode = Enum.LineJoinMode.Miter
			ls.Parent = Label

			local Bar = Instance.new("Frame")
			Bar.BackgroundColor3 = accent
			Bar.BorderSizePixel = 0
			Bar.Position = UDim2.new(0, -1, 1, -2)
			Bar.Size = UDim2.new(1, 2, 0, 3)
			Bar.ZIndex = 2004
			Bar.Parent = Outer

			local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			tws:Create(Outer, info, { Size = UDim2.fromOffset(w + 16, H) }):Play()

			task.delay(dur or 5, function()
				if not Outer.Parent then return end
				tws:Create(Outer, info, { Size = UDim2.fromOffset(0, H) }):Play()
				task.wait(0.4)
				Outer:Destroy()
			end)
		end

		-- [[ save / load ]]
		function SaveManager:Save(name)
			name = sanitize(name)
			if name == "" or name == "None" then return false, "invalid file name for config (empty)" end
			if not hasFS() then return false, "executor has no filesystem" end
			self:BuildFolderTree()

			local data = { objects = {} }

			for idx, obj in next, Toggles do
				if not self.Ignore[idx] then
					table.insert(data.objects, self.Parser.Toggle.Save(idx, obj))
				end
			end

			for idx, obj in next, Options do
				if not self.Ignore[idx] then
					local t = typeOf(obj)
					local parser = t and self.Parser[t]
					if parser then
						local ok, entry = pcall(parser.Save, idx, obj)
						if ok and entry then table.insert(data.objects, entry) end
					end
				end
			end

			local ok, encoded = pcall(httpService.JSONEncode, httpService, data)
			if not ok then return false, "failed to encode data" end

			local wrote, err = pcall(writefile, self:PathFor(name), encoded)
			if not wrote then return false, tostring(err) end
			return true
		end

		function SaveManager:Load(name)
			name = sanitize(name)
			if name == "" or name == "None" then return false, "invalid file name for config (empty)" end
			if not hasFS() then return false, "executor has no filesystem" end

			local path = self:PathFor(name)
			if not isfile(path) then return false, "invalid file" end

			local ok, decoded = pcall(function()
				return httpService:JSONDecode(readfile(path))
			end)
			if not ok or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
				return false, "decode error"
			end

			for _, entry in next, decoded.objects do
				local parser = self.Parser[entry.type]
				if parser and not self.Ignore[entry.idx] then
					task.spawn(function()
						pcall(parser.Load, entry.idx, entry)
					end)
				end
			end
			return true
		end

		function SaveManager:RefreshConfigList()
			local out = {}
			if not hasFS() then return {"None"} end
			self:BuildFolderTree()
			local ok, files = pcall(listfiles, self.Folder .. "/settings")
			if not ok or type(files) ~= "table" then return {"None"} end
			for _, file in ipairs(files) do
				local name = file:match("([^/\\]+)%.json$")
				if name then table.insert(out, name) end
			end
			table.sort(out)
			if #out == 0 then
				table.insert(out, "None")
			end
			return out
		end

		-- [[ autoload ]]
		function SaveManager:GetAutoload()
			local path = self.Folder .. "/settings/autoload.txt"
			if hasFS() and isfile(path) then
				local n = sanitize(readfile(path))
				if n ~= "" then return n end
			end
			return nil
		end

		function SaveManager:SetAutoload(name)
			name = sanitize(name)
			if name == "" or name == "None" then return false, "no config selected" end
			if not hasFS() then return false, "executor has no filesystem" end
			self:BuildFolderTree()
			local ok, err = pcall(writefile, self.Folder .. "/settings/autoload.txt", name)
			if not ok then return false, tostring(err) end
			return true
		end

		function SaveManager:ResetAutoload()
			local path = self.Folder .. "/settings/autoload.txt"
			if hasFS() and isfile(path) and delfile then
				pcall(delfile, path)
			end
			return true
		end

		function SaveManager:LoadAutoloadConfig()
			local name = self:GetAutoload()
			if not name then return end
			local ok, err = self:Load(name)
			if not ok then
				return self:Notify("Failed to load autoload config: " .. tostring(err))
			end
			self:Notify(string.format("Auto loaded config %q", name))
		end

		-- [[ ui helpers ]]
		function SaveManager:GetSelected()
			local dd = self.List
			if not dd then return nil end
			local name = dd.Options[dd:Get()]
			if name == "None" then return nil end
			return name
		end

		function SaveManager:UpdateAutoloadLabel()
			if self.AutoloadLabel then
				self.AutoloadLabel:SetText("Current autoload config: " .. (self:GetAutoload() or "none"))
			end
		end

		function SaveManager:RefreshList(selectName)
			if not self.List then return end
			self.List:SetOptions(self:RefreshConfigList(), selectName or self:GetSelected())
		end

		-- [[ the actual config section (single "Configuration" box, same layout as creep.cc) ]]
		function SaveManager:BuildConfigSection(page)
			assert(self.Window, "SaveManager.Window must be set before BuildConfigSection")
			self:BuildFolderTree()
			self:SetIgnoreIndexes({ "SM_ConfigName", "SM_ConfigList" })

			-- change Side to "Left" if you want it on the left instead
			local box = page:CreateSection({ Name = "Configuration", Size = 265, Side = "Right" })

			self.NameBox = box:CreateTextbox({
				Name = "Config name",
				Id = "SM_ConfigName",
				Placeholder = "",
			})
			self.List = box:CreateDropdown({
				Name = "Config list",
				Id = "SM_ConfigList",
				State = 1,
				Options = self:RefreshConfigList(),
			})
			box:CreateSeparator({})

			box:CreateButtonRow({
				{ Name = "Create config", Callback = function()
					local name = sanitize(self.NameBox:Get())
					if name == "" then
						return self:Notify("Invalid file name for config (empty)")
					end
					local ok, err = self:Save(name)
					if not ok then
						return self:Notify("Failed to create config: " .. tostring(err))
					end
					self:Notify(string.format("Created config %q", name))
					self:RefreshList(name)
				end },
			})

			box:CreateButtonRow({
				{ Name = "Load config", Callback = function()
					local name = self:GetSelected()
					if not name then return self:Notify("Invalid file name for config (empty)") end
					local ok, err = self:Load(name)
					if not ok then
						return self:Notify("Failed to load config: " .. tostring(err))
					end
					self:Notify(string.format("Loaded config %q", name))
				end },
				{ Name = "Overwrite config", Callback = function()
					local name = self:GetSelected()
					if not name then return self:Notify("Invalid file name for config (empty)") end
					local ok, err = self:Save(name)
					if not ok then
						return self:Notify("Failed to overwrite config: " .. tostring(err))
					end
					self:Notify(string.format("Overwrote config %q", name))
				end },
			})

			box:CreateButtonRow({
				{ Name = "Refresh list", Callback = function()
					self:RefreshList()
				end },
			})

			box:CreateButtonRow({
				{ Name = "Set as autoload", Callback = function()
					local name = self:GetSelected()
					if not name then return self:Notify("Invalid file name for config (empty)") end
					local ok, err = self:SetAutoload(name)
					if not ok then
						return self:Notify("Failed to set autoload: " .. tostring(err))
					end
					self:UpdateAutoloadLabel()
					self:Notify(string.format("Set %q to auto load", name))
				end },
				{ Name = "Reset autoload", Callback = function()
					self:ResetAutoload()
					self:UpdateAutoloadLabel()
					self:Notify("Set autoload to none")
				end },
			})

			self.AutoloadLabel = box:CreateLabel({ Name = "Current autoload config: none" })
			self:UpdateAutoloadLabel()
		end
	end

	-- [[ // Main // ]]

	local window = library:CreateWindow({})
	--
	-- Hook the SaveManager up to the window
	SaveManager.Window = window
	--
	local page1 = window:CreatePage({Name = "combat"})
	local page2 = window:CreatePage({Name = "rage"})
	local page3 = window:CreatePage({Name = "visuals"})
	local page4 = window:CreatePage({Name = "settings"})
	local page5 = window:CreatePage({Name = "config"})
	--
	-- ========== PAGE 1 ==========
	local page1sec1 = page1:CreateSection({Name = "Section 1", Size = 300, Side = "Left"})
	local page1sec2 = page1:CreateSection({Name = "Section 2", Size = 220, Side = "Left"})
	local page1sec3 = page1:CreateSection({Name = "Section 3", Size = 300, Side = "Right"})
	local page1sec4 = page1:CreateSection({Name = "Section 4", Size = 220, Side = "Right"})
	--
	page1sec1:CreateLabel({Name = "Main"})
	page1sec1:CreateToggle({Name = "Toggle 1", State = false, Callback = function(v) end})
	page1sec1:CreateToggle({Name = "Toggle 2", State = false})
	page1sec1:CreateToggle({Name = "Toggle 3", State = false})
	page1sec1:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 0, Decimals = 1})
	page1sec1:CreateSlider({Name = "Slider 2", State = 50, Max = 100, Min = 0, Decimals = 1})
	page1sec1:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page1sec1:CreateDropdown({Name = "Dropdown 2", State = 1, Options = {"Option 1", "Option 2", "Option 3", "Option 4"}})
	page1sec1:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(230, 230, 235)})
	page1sec1:CreateKeybind({Name = "Keybind 1"})
	page1sec1:CreateSeparator({})
	page1sec1:CreateToggle({Name = "Toggle 4", State = false})
	page1sec1:CreateToggle({Name = "Toggle 5", State = false})
	--
	page1sec2:CreateLabel({Name = "Main"})
	page1sec2:CreateToggle({Name = "Toggle 1", State = false})
	page1sec2:CreateToggle({Name = "Toggle 2", State = false})
	page1sec2:CreateSlider({Name = "Slider 1", State = 25, Max = 100, Min = 0, Decimals = 1})
	page1sec2:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page1sec2:CreateKeybind({Name = "Keybind 1"})
	page1sec2:CreateToggle({Name = "Toggle 3", State = false})
	--
	page1sec3:CreateLabel({Name = "Main"})
	page1sec3:CreateToggle({Name = "Toggle 1", State = false})
	page1sec3:CreateToggle({Name = "Toggle 2", State = false})
	page1sec3:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 0, Decimals = 1})
	page1sec3:CreateSlider({Name = "Slider 2", State = 100, Max = 100, Min = 0, Decimals = 1})
	page1sec3:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page1sec3:CreateDropdown({Name = "Dropdown 2", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page1sec3:CreateMultibox({Name = "Multibox 1", State = {1}, Options = {"Option 1", "Option 2", "Option 3", "Option 4"}})
	page1sec3:CreateToggle({Name = "Toggle 3", State = false})
	page1sec3:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(230, 230, 235)})
	--
	page1sec4:CreateLabel({Name = "Main"})
	page1sec4:CreateToggle({Name = "Toggle 1", State = false})
	page1sec4:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 0, Decimals = 1})
	page1sec4:CreateSlider({Name = "Slider 2", State = 50, Max = 100, Min = 0, Decimals = 1})
	page1sec4:CreateToggle({Name = "Toggle 2", State = false})
	page1sec4:CreateToggle({Name = "Toggle 3", State = false})
	--
	-- ========== PAGE 2 ==========
	local page2sec1 = page2:CreateSection({Name = "Section 1", Size = 300, Side = "Left"})
	local page2sec2 = page2:CreateSection({Name = "Section 2", Size = 240, Side = "Left"})
	local page2sec3 = page2:CreateSection({Name = "Section 3", Size = 280, Side = "Right"})
	local page2sec4 = page2:CreateSection({Name = "Section 4", Size = 200, Side = "Right"})
	--
	page2sec1:CreateLabel({Name = "Main"})
	page2sec1:CreateToggle({Name = "Toggle 1", State = false})
	page2sec1:CreateToggle({Name = "Toggle 2", State = false})
	page2sec1:CreateToggle({Name = "Toggle 3", State = false})
	page2sec1:CreateToggle({Name = "Toggle 4", State = false})
	page2sec1:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 0, Decimals = 1})
	page2sec1:CreateSlider({Name = "Slider 2", State = 50, Max = 100, Min = 0, Decimals = 1})
	page2sec1:CreateSlider({Name = "Slider 3", State = 1, Max = 100, Min = 1, Decimals = 1})
	page2sec1:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page2sec1:CreateMultibox({Name = "Multibox 1", State = {1, 2}, Options = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}})
	page2sec1:CreateToggle({Name = "Toggle 5", State = false})
	page2sec1:CreateToggle({Name = "Toggle 6", State = false})
	--
	page2sec2:CreateLabel({Name = "Main"})
	page2sec2:CreateToggle({Name = "Toggle 1", State = false})
	page2sec2:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}})
	page2sec2:CreateDropdown({Name = "Dropdown 2", State = 1, Options = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}})
	page2sec2:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 1, Decimals = 1})
	page2sec2:CreateSlider({Name = "Slider 2", State = 30, Max = 90, Min = 1, Decimals = 1})
	page2sec2:CreateToggle({Name = "Toggle 2", State = false})
	page2sec2:CreateToggle({Name = "Toggle 3", State = false})
	page2sec2:CreateSlider({Name = "Slider 3", State = 14, Max = 22, Min = 1, Decimals = 1})
	--
	page2sec3:CreateLabel({Name = "Main"})
	page2sec3:CreateToggle({Name = "Toggle 1", State = false})
	page2sec3:CreateToggle({Name = "Toggle 2", State = false})
	page2sec3:CreateToggle({Name = "Toggle 3", State = false})
	page2sec3:CreateToggle({Name = "Toggle 4", State = false})
	page2sec3:CreateKeybind({Name = "Keybind 1"})
	page2sec3:CreateToggle({Name = "Toggle 5", State = false})
	page2sec3:CreateToggle({Name = "Toggle 6", State = false})
	page2sec3:CreateToggle({Name = "Toggle 7", State = false})
	page2sec3:CreateSlider({Name = "Slider 1", State = 200, Max = 400, Min = 0, Decimals = 1})
	--
	page2sec4:CreateLabel({Name = "Main"})
	page2sec4:CreateToggle({Name = "Toggle 1", State = false})
	page2sec4:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page2sec4:CreateToggle({Name = "Toggle 2", State = false})
	page2sec4:CreateToggle({Name = "Toggle 3", State = false})
	--
	-- ========== PAGE 3 ==========
	local page3sec1 = page3:CreateSection({Name = "Section 1", Size = 330, Side = "Left"})
	local page3sec2 = page3:CreateSection({Name = "Section 2", Size = 180, Side = "Left"})
	local page3sec3 = page3:CreateSection({Name = "Section 3", Size = 240, Side = "Right"})
	local page3sec4 = page3:CreateSection({Name = "Section 4", Size = 270, Side = "Right"})
	--
	page3sec1:CreateLabel({Name = "Main"})
	page3sec1:CreateKeybind({Name = "Keybind 1"})
	page3sec1:CreateToggle({Name = "Toggle 1", State = true})
	page3sec1:CreateToggle({Name = "Toggle 2", State = false})
	page3sec1:CreateToggle({Name = "Toggle 3", State = true})
	page3sec1:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(230, 230, 235)})
	page3sec1:CreateToggle({Name = "Toggle 4", State = true})
	page3sec1:CreateToggle({Name = "Toggle 5", State = true})
	page3sec1:CreateToggle({Name = "Toggle 6", State = true})
	page3sec1:CreateToggle({Name = "Toggle 7", State = false})
	page3sec1:CreateToggle({Name = "Toggle 8", State = false})
	page3sec1:CreateToggle({Name = "Toggle 9", State = false})
	page3sec1:CreateToggle({Name = "Toggle 10", State = false})
	page3sec1:CreateToggle({Name = "Toggle 11", State = true})
	page3sec1:CreateColorpicker({Name = "Color 2", State = Color3.fromRGB(230, 230, 235)})
	page3sec1:CreateToggle({Name = "Toggle 12", State = false})
	page3sec1:CreateToggle({Name = "Toggle 13", State = false})
	page3sec1:CreateToggle({Name = "Toggle 14", State = true})
	page3sec1:CreateSlider({Name = "Slider 1", State = 12, Max = 30, Min = 1, Decimals = 1})
	page3sec1:CreateSlider({Name = "Slider 2", State = 100, Max = 500, Min = 1, Decimals = 1})
	page3sec1:CreateToggle({Name = "Toggle 15", State = false})
	page3sec1:CreateToggle({Name = "Toggle 16", State = true})
	page3sec1:CreateToggle({Name = "Toggle 17", State = true})
	page3sec1:CreateColorpicker({Name = "Color 3", State = Color3.fromRGB(255, 50, 50)})
	--
	page3sec2:CreateLabel({Name = "Main"})
	page3sec2:CreateToggle({Name = "Toggle 1", State = false})
	page3sec2:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(230, 230, 235)})
	page3sec2:CreateToggle({Name = "Toggle 2", State = false})
	page3sec2:CreateToggle({Name = "Toggle 3", State = false})
	page3sec2:CreateToggle({Name = "Toggle 4", State = false})
	page3sec2:CreateToggle({Name = "Toggle 5", State = false})
	page3sec2:CreateToggle({Name = "Toggle 6", State = false})
	page3sec2:CreateToggle({Name = "Toggle 7", State = false})
	page3sec2:CreateToggle({Name = "Toggle 8", State = false})
	--
	page3sec3:CreateLabel({Name = "Main"})
	page3sec3:CreateToggle({Name = "Toggle 1", State = false})
	page3sec3:CreateMultibox({Name = "Multibox 1", State = {1, 3}, Options = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"}})
	page3sec3:CreateToggle({Name = "Toggle 2", State = false})
	page3sec3:CreateToggle({Name = "Toggle 3", State = false})
	page3sec3:CreateToggle({Name = "Toggle 4", State = false})
	page3sec3:CreateToggle({Name = "Toggle 5", State = false})
	page3sec3:CreateToggle({Name = "Toggle 6", State = false})
	page3sec3:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(230, 230, 235)})
	page3sec3:CreateToggle({Name = "Toggle 7", State = false})
	page3sec3:CreateToggle({Name = "Toggle 8", State = false})
	page3sec3:CreateColorpicker({Name = "Color 2", State = Color3.fromRGB(230, 230, 235)})
	page3sec3:CreateToggle({Name = "Toggle 9", State = false})
	--
	page3sec4:CreateLabel({Name = "Main"})
	page3sec4:CreateToggle({Name = "Toggle 1", State = false})
	page3sec4:CreateToggle({Name = "Toggle 2", State = false})
	page3sec4:CreateToggle({Name = "Toggle 3", State = false})
	page3sec4:CreateToggle({Name = "Toggle 4", State = false})
	page3sec4:CreateToggle({Name = "Toggle 5", State = false})
	page3sec4:CreateToggle({Name = "Toggle 6", State = false})
	page3sec4:CreateDropdown({Name = "Dropdown 1", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page3sec4:CreateSlider({Name = "Slider 1", State = 50, Max = 100, Min = 0, Decimals = 1})
	page3sec4:CreateSlider({Name = "Slider 2", State = 50, Max = 100, Min = 0, Decimals = 1})
	page3sec4:CreateDropdown({Name = "Dropdown 2", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page3sec4:CreateToggle({Name = "Toggle 7", State = false})
	page3sec4:CreateToggle({Name = "Toggle 8", State = false})
	--
	-- ========== PAGE 4 (SETTINGS) ==========
	local page4sec1 = page4:CreateSection({Name = "UI Colors", Size = 220, Side = "Left"})
	local page4sec2 = page4:CreateSection({Name = "UI Misc", Size = 240, Side = "Left"})
	local page4sec5 = page4:CreateSection({Name = "Background", Size = 120, Side = "Left"})
	local page4sec3 = page4:CreateSection({Name = "Menu Keys", Size = 180, Side = "Right"})
	local page4sec4 = page4:CreateSection({Name = "Other", Size = 200, Side = "Right"})

	--
	page4sec1:CreateLabel({Name = "Main"})
	page4sec1:CreateColorpicker({Name = "Accent Color", State = window.Accent, Callback = function(col)
		window:SetAccent(col)
	end})
	page4sec1:CreateColorpicker({Name = "Outline Color", State = window.Outline, Callback = function(col)
		window:SetOutlineColor(col)
	end})
	page4sec1:CreateColorpicker({Name = "Color 1", State = Color3.fromRGB(16, 16, 20)})
	page4sec1:CreateColorpicker({Name = "Color 2", State = Color3.fromRGB(28, 28, 34)})
	page4sec1:CreateColorpicker({Name = "Color 3", State = Color3.fromRGB(215, 215, 225)})
	page4sec1:CreateToggle({Name = "Toggle 1", State = false})
	--
	page4sec2:CreateLabel({Name = "Main"})
	page4sec2:CreateSlider({
		Name = "See Through",
		State = 40,
		Min = 0,
		Max = 85,
		Decimals = 1,
		Suffix = "%",
		Callback = function(v)
			window:SetTransparency(v / 100)
			if window.LiquidGlass then
				window:SetLiquidGlass(true)
			end
		end
	})
	page4sec2:CreateSlider({
		Name = "UI Scale",
		State = 100,
		Min = 55,
		Max = 120,
		Decimals = 1,
		Suffix = "%",
		Callback = function(v)
			window:SetScale(v / 100)
		end
	})
	-- apply default glass so background is visible on inject
	window:SetTransparency(0.40)
	-- mobile starts a bit smaller
	if window.IsMobile then
		window:SetScale(1)
	end
	page4sec2:CreateToggle({
		Name = "Liquid Glass",
		State = false,
		Callback = function(v)
			window:SetLiquidGlass(v)
		end
	})
	page4sec2:CreateToggle({Name = "Toggle 1", State = true})
	page4sec2:CreateToggle({Name = "Toggle 2", State = true})
	page4sec2:CreateToggle({Name = "Toggle 3", State = false})
	page4sec2:CreateToggle({Name = "Toggle 4", State = false})
	page4sec2:CreateDropdown({Name = "Dropdown 1", State = 2, Options = {"Option 1", "Option 2", "Option 3", "Option 4"}})
	page4sec2:CreateDropdown({Name = "Dropdown 2", State = 1, Options = {"Option 1", "Option 2", "Option 3"}})
	page4sec2:CreateButton({Name = "Unload Menu", Callback = function()
		window:Unload()
	end})
	--
	page4sec5:CreateLabel({Name = "Main"})
	page4sec5:CreateDropdown({
		Name = "Background Image",
		State = 1,
		Options = BackgroundNames,
		Callback = function(v)
			if type(v) == "number" and BackgroundNames[v] then
				window:SetBackground(BackgroundNames[v])
			end
		end
	})
	--
	page4sec3:CreateLabel({Name = "Main"})
	page4sec3:CreateKeybind({
		Name = "Menu Key",
		Id = "settings.MenuKeys.MenuKey",
		State = {"KeyCode", "RightShift"},
		Mode = "Toggle",
		Callback = function(state)
			-- Click bind value, then press a key/mouse button to change menu toggle
			if type(state) == "table" and state[1] and state[2] then
				local ok, key = pcall(function()
					return Enum[state[1]][state[2]]
				end)
				if ok and key then
					window.Key = key
					return
				end
			end
			window.Key = Enum.KeyCode.RightShift
		end
	})
	page4sec3:CreateKeybind({Name = "Keybind 2"})
	page4sec3:CreateKeybind({Name = "Keybind 3"})
	--
	page4sec4:CreateLabel({Name = "Main"})
	page4sec4:CreateToggle({Name = "Toggle 1", State = false})
	page4sec4:CreateToggle({Name = "Toggle 2", State = false})
	page4sec4:CreateToggle({Name = "Toggle 3", State = false})
	page4sec4:CreateToggle({Name = "Toggle 4", State = false})
	page4sec4:CreateButton({Name = "Button 1", Callback = function() end})
	--
	-- ========== PAGE 5 (CONFIG) ==========
	SaveManager:BuildConfigSection(page5)
	--
	-- Autoload: keep this BELOW every control on every page so everything exists before it loads
	SaveManager:LoadAutoloadConfig()
	--
	-- Watermark (improved glass style + live stats)
	do
		local frame = Instance.new("Frame")
		frame.Name = "Zx64_Watermark"
		frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
		frame.BackgroundTransparency = 0.28
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0, 14, 0, 14)
		frame.Size = UDim2.new(0, 0, 0, 28)
		frame.AutomaticSize = Enum.AutomaticSize.X
		frame.ZIndex = 40
		frame.Parent = window.ScreenGui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 7)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.2
		stroke.Transparency = 0.35
		stroke.Parent = frame
		window:RegisterOutline(stroke, "Color")
		-- left accent bar
		local accentBar = Instance.new("Frame")
		accentBar.Name = "Accent"
		accentBar.BackgroundColor3 = window.Outline or Color3.fromRGB(255, 255, 255)
		accentBar.BorderSizePixel = 0
		accentBar.Position = UDim2.new(0, 0, 0, 4)
		accentBar.Size = UDim2.new(0, 3, 1, -8)
		accentBar.ZIndex = 41
		accentBar.Parent = frame
		local accentCorner = Instance.new("UICorner")
		accentCorner.CornerRadius = UDim.new(1, 0)
		accentCorner.Parent = accentBar
		window:RegisterOutline(accentBar, "BackgroundColor3")
		-- soft inner fill
		local inner = Instance.new("Frame")
		inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		inner.BackgroundTransparency = 0.94
		inner.BorderSizePixel = 0
		inner.Size = UDim2.new(1, 0, 1, 0)
		inner.ZIndex = 40
		inner.Parent = frame
		local innerCorner = Instance.new("UICorner")
		innerCorner.CornerRadius = UDim.new(0, 7)
		innerCorner.Parent = inner
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Font = Enum.Font.GothamBold
		label.Text = "Zx64  |  0 fps  |  00:00"
		label.TextColor3 = Color3.fromRGB(245, 245, 250)
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 42
		label.Parent = frame
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 0)
		pad.PaddingRight = UDim.new(0, 14)
		pad.Parent = frame
		-- live FPS + clock
		local frames, last = 0, tick()
		local fps = 0
		utility:CreateConnection(game:GetService("RunService").RenderStepped, function()
			frames = frames + 1
			local now = tick()
			if now - last >= 1 then
				fps = frames
				frames = 0
				last = now
			end
			local t = os.date("%H:%M")
			local user = (lp and lp.Name) or "player"
			label.Text = string.format("Zx64  ·  %s  ·  %d fps  ·  %s", user, fps, t)
		end)
		window:RegisterAccent(function(col)
			accentBar.BackgroundColor3 = col
		end)
	end
end)
if not Passed then
	warn("[Zx64] UI failed to load:")
	warn(tostring(Statement))
end
