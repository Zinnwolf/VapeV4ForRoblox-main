local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, funclist)
	local oldidentity = getidentity()
	pcall(function() setidentity(8) end)

	local coreGui = game:GetService("CoreGui")
	local playerGui = playersService and playersService.LocalPlayer and playersService.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "VapeErrorPrompt"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	pcall(function() gui.Parent = coreGui end)
	if not gui.Parent and playerGui then gui.Parent = playerGui end
	if not gui.Parent then warn("Vape: "..tostring(text)); pcall(function() setidentity(oldidentity) end); return end

	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 1)
	holder.BackgroundTransparency = 0.35
	holder.BackgroundColor3 = Color3.new(0, 0, 0)
	holder.Parent = gui

	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Size = UDim2.fromOffset(430, 170)
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	box.BorderSizePixel = 0
	box.Parent = holder
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(14, 10)
	title.Size = UDim2.new(1, -28, 0, 26)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = "Vape"
	title.Parent = box

	local msg = Instance.new("TextLabel")
	msg.BackgroundTransparency = 1
	msg.Position = UDim2.fromOffset(14, 42)
	msg.Size = UDim2.new(1, -28, 1, -92)
	msg.Font = Enum.Font.SourceSans
	msg.TextSize = 18
	msg.TextWrapped = true
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextYAlignment = Enum.TextYAlignment.Top
	msg.TextColor3 = Color3.fromRGB(230, 230, 230)
	msg.Text = tostring(text)
	msg.Parent = box

	local buttons = {}
	if type(funclist) == "table" then
		for name, callback in pairs(funclist) do table.insert(buttons, {Text = tostring(name), Callback = callback}) end
	else
		table.insert(buttons, {Text = "OK", Callback = type(funclist) == "function" and funclist or nil})
	end

	for i, buttonData in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(88, 30)
		button.Position = UDim2.new(1, -(14 + ((#buttons - i) * 96) + 88), 1, -42)
		button.BackgroundColor3 = Color3.fromRGB(5, 134, 105)
		button.BorderSizePixel = 0
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 16
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Text = buttonData.Text
		button.Parent = box
		Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
		button.MouseButton1Click:Connect(function()
			gui:Destroy()
			if buttonData.Callback then task.spawn(buttonData.Callback) end
		end)
	end

	pcall(function() setidentity(oldidentity) end)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox-main/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

if not shared.VapeDeveloper then 
	local commit = "main"
	for i,v in pairs(game:HttpGet("https://github.com/Zinnwolf/VapeV4ForRoblox-main"):split("\n")) do 
		if v:find("commit") and v:find("fragment") then 
			local str = v:split("/")[5]
			commit = str:sub(0, str:find('"') - 1)
			break
		end
	end
	if commit then
		if isfolder("vape") then 
			if ((not isfile("vape/commithash.txt")) or (readfile("vape/commithash.txt") ~= commit or commit == "main")) then
				for i,v in pairs({"vape/Universal.lua", "vape/MainScript.lua", "vape/GuiLibrary.lua"}) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						delfile(v)
					end 
				end
				if isfolder("vape/CustomModules") then 
					for i,v in pairs(listfiles("vape/CustomModules")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
							delfile(v)
						end 
					end
				end
				if isfolder("vape/Libraries") then 
					for i,v in pairs(listfiles("vape/Libraries")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
							delfile(v)
						end 
					end
				end
				writefile("vape/commithash.txt", commit)
			end
		else
			makefolder("vape")
			writefile("vape/commithash.txt", commit)
		end
	else
		displayErrorPopup("Failed to connect to github, please try using a VPN.")
		error("Failed to connect to github, please try using a VPN.")
	end
end

return loadstring(vapeGithubRequest("MainScript.lua"))()
