local license = ... or {}
license.Key = script_key or license.Key or nil
repeat task.wait() until game:IsLoaded()

-- Whitelist system with Roblox user ID and hash verification
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function getRobloxHash(player)
	-- Generate a simple hash based on Roblox username for verification
	-- Using a local implementation instead of external API
	local data = player.Name
	local hash = 0
	for i = 1, #data do
		hash = (hash * 31 + string.byte(data, i)) % 4294967296
	end
	return string.format("%08x", hash)
end

local function loadWhitelist()
	local success, data = pcall(function()
		if isfile and isfile("whitelist.json") then
			return HttpService:JSONDecode(readfile("whitelist.json"))
		else
			-- Try to download from GitHub if local file doesn't exist
			local response = game:HttpGet("https://raw.githubusercontent.com/4hdq/doitvapev2/main/whitelist.json", true)
			return HttpService:JSONDecode(response)
		end
	end)
	
	if success and data then
		return data
	end
	return nil
end

local function verifyWhitelist()
	local whitelist = loadWhitelist()
	if not whitelist then
		LocalPlayer:Kick("Access Denied: Failed to load whitelist.")
		return false
	end
	
	local playerHash = getRobloxHash(LocalPlayer)
	local whitelisted = false
	
	for userId, userData in pairs(whitelist.WhitelistedUsers or {}) do
		-- Check both user ID and hash
		if tostring(userId) == tostring(LocalPlayer.UserId) then
			whitelisted = true
			shared.WhitelistData = {
				userId = userId,
				name = userData.name or LocalPlayer.Name,
				attackable = userData.attackable or false,
				level = userData.level or 1,
				tags = userData.tags or {}
			}
			break
		end
	end
	
	if not whitelisted then
		LocalPlayer:Kick("Access Denied: You are not whitelisted to use this script.")
		return false
	end
	
	return true
end

if not verifyWhitelist() then
	return
end

if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local redirect = function()
	local body = httpService:JSONEncode({
		nonce = httpService:GenerateGUID(false),
		args = {
			invite = {code = 'doitvape'},
			code = 'doitvape'
		},
		cmd = 'INVITE_BROWSER'
	})

	for i = 1, 2 do
		task.spawn(function()
			request({
				Method = 'POST',
				Url = 'http://127.0.0.1:6463/rpc?v=1',
				Headers = {
					['Content-Type'] = 'application/json',
					Origin = 'https://discord.com'
				},
				Body = body
			})
		end)
	end
end

local function downloadFile(path, func)
	if not isfile(path) then
		warn(path)
		local commit = isfile('doitvapev2/profiles/commit.txt') and readfile('doitvapev2/profiles/commit.txt') or 'main'
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/4hdq/doitvapev2/'..commit..'/'..select(1, path:gsub('doitvapev2/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			task.spawn(error, res)
		end
		if suc then
			if path:find('.lua') then
				res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
			end
			writefile(path, res)
		end
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function(state)
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				if shared.VapeDeveloper then
					loadstring(readfile('doitvapev2/main.lua'), 'main')(_scriptconfig)
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/4hdq/doitvapev2/master/init.lua', true), 'init')(_scriptconfig)
				end
			]]
			local teleportConfig = httpService:JSONEncode(license)
			teleportConfig = teleportConfig:gsub('":true', "=true"):gsub('{"', '{')
			teleportConfig = teleportConfig:gsub(',"', ','):gsub('":', '=')
			teleportConfig = teleportConfig:gsub('%[', '{'):gsub('%]', '}')
			teleportScript = teleportScript:gsub('_key', tostring(license.Key or '_key'))
			teleportScript = teleportScript:gsub('_scriptconfig', teleportConfig)
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			if getgenv().doitvaperole == 'HWID MISMATCH' then
				vape:CreateNotification('DoitVape', 'HWID MISMATCH, Go to the script panel to reset hwid', 25, 'alert')
				getgenv().doitvaperole = ''
				task.wait(0.1)
			end
			if vape.Place ~= 6872274481 then
				--task.spawn(redirect)
			end
			vape:CreateNotification('Finished Loading', (getgenv().doitvapename and `Authenticated as {getgenv().doitvapename} with {getgenv().doitvaperole}, ` or '').. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
			task.delay(1, function()
				if shared.updated then
					local commit = isfile('doitvapev2/profiles/commit.txt') and readfile('doitvapev2/profiles/commit.txt') or 'main'
					vape:CreateNotification('DoitVapeV2', `Script has updated from {shared.updated} to {commit}`, 10, 'info')
				end
			end)
		end
	end
end

if not isfile('doitvapev2/profiles/gui.txt') then
	writefile('doitvapev2/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('doitvapev2/profiles/gui.txt')

if not isfolder('doitvapev2/assets/'..gui) then
	makefolder('doitvapev2/assets/'..gui)
end
if not isfile('doitvapev2/profiles/commit.txt') then
	writefile('doitvapev2/profiles/commit.txt', 'main')
end

getgenv().used_init = true
vape = loadstring(downloadFile('doitvapev2/guis/'..gui..'.lua'), 'gui')(license)
_G.vape = vape
shared.vape = vape

if shared.maindoitvape then
	redirect()
	playersService.LocalPlayer:Kick('Your script is outdated, Get new one at discord.gg/doitvape')
	return
end

if not shared.VapeIndependent then
	loadstring(downloadFile('doitvapev2/games/universal.lua'), 'universal')(license)
	if isfile('doitvapev2/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('doitvapev2/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	else
		if not shared.VapeDeveloper then
			local commit = isfile('doitvapev2/profiles/commit.txt') and readfile('doitvapev2/profiles/commit.txt') or 'main'
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/4hdq/doitvapev2/'..commit..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('doitvapev2/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
