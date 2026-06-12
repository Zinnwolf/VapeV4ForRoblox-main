local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, func)
	warn("[Vape] "..tostring(text))

	local suc = pcall(function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "VapeErrorPrompt"
		gui.ResetOnSpawn = false
		gui.Parent = game:GetService("CoreGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(420, 120)
		frame.Position = UDim2.new(0.5, -210, 0.5, -60)
		frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		frame.BorderSizePixel = 0
		frame.Parent = gui

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 30)
		title.Position = UDim2.fromOffset(10, 8)
		title.BackgroundTransparency = 1
		title.Text = "Vape"
		title.TextColor3 = Color3.new(1, 1, 1)
		title.TextSize = 22
		title.Font = Enum.Font.SourceSansBold
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		local body = Instance.new("TextLabel")
		body.Size = UDim2.new(1, -20, 0, 58)
		body.Position = UDim2.fromOffset(10, 40)
		body.BackgroundTransparency = 1
		body.Text = tostring(text)
		body.TextWrapped = true
		body.TextColor3 = Color3.fromRGB(230, 230, 230)
		body.TextSize = 18
		body.Font = Enum.Font.SourceSans
		body.TextXAlignment = Enum.TextXAlignment.Left
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.Parent = frame

		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(90, 28)
		button.Position = UDim2.new(1, -100, 1, -38)
		button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		button.BorderSizePixel = 0
		button.Text = "OK"
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextSize = 18
		button.Font = Enum.Font.SourceSans
		button.Parent = frame
		button.MouseButton1Click:Connect(function()
			gui:Destroy()
			if func then func() end
		end)
	end)

	if not suc and func then
		func()
	end
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
		suc, res = pcall(function() local ref = isfile("vape/commithash.txt") and readfile("vape/commithash.txt") or "main"
			local url = "https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox-main/"..ref.."/"..scripturl
			local response = game:HttpGet(url, true)
			if response == "404: Not Found" and ref ~= "main" then
				response = game:HttpGet("https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox-main/main/"..scripturl, true)
			end
			return response end)
		if not suc or res == "404: Not Found" then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..tostring(res))
			error(res)
		end
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

if not shared.VapeDeveloper then 
	local commit = "main"
	if commit then
		if isfolder("vape") then 
			if ((not isfile("vape/commithash.txt")) or (readfile("vape/commithash.txt") ~= commit)) then
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
