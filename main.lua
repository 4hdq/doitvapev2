repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local license = ... or shared.catdata or {}
license.Key = license.Key or script_key

local vape
local oldload = loadstring
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
local inputService = cloneref(game:GetService('UserInputService'))
local httpService = cloneref(game:GetService('HttpService'))
local runService = cloneref(game:GetService('RunService'))
local playersService = cloneref(game:GetService('Players'))

if shared.maincat then
	shared.maincat = nil
	task.spawn(function()
		local body = httpService:JSONEncode({
			nonce = httpService:GenerateGUID(false),
			args = {
				invite = {code = 'catvape'},
				code = 'catvape'
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
	end)
	playersService:Kick('Your script is outdated, Get new one at discord.gg/catvape')
	return
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/MaxlaserTech/CatV6/'..readfile('catrewrite/profiles/commit.txt')..'/'..select(1, path:gsub('catrewrite/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) and vape.AutoTeleport.Enabled then
			teleportedServers = true
			local teleportScript = [[
				if shared.VapeDeveloper then
					loadstring(readfile('catrewrite/init.lua'), 'init')(_scriptconfig)
				else
					loadstring(game:HttpGet('https://api.catvape.dev/script?key=_key'), 'init')(_scriptconfig)
				end
			]]
			local teleportConfig = httpService:JSONEncode(license)
			teleportConfig = teleportConfig:gsub('":true', "=true"):gsub('{"', '{')
			teleportConfig = teleportConfig:gsub(',"', ','):gsub('":', '=')
			
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

	if not vape.Categories then return end
	if vape.Place ~= 6872274481 and not license.Closet and not getgenv().catname then
		task.spawn(function()
			local body = httpService:JSONEncode({
				nonce = httpService:GenerateGUID(false),
				args = {
					invite = {code = 'catvape'},
					code = 'catvape'
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
		end)
	end
	if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
		if getgenv().catrole == 'HWID MISMATCH' then
			vape:CreateNotification('Cat', 'HWID mismatch, Please go to our server And press reset hwid on script panel', 60, 'alert')
		else
			vape:CreateNotification('Cat', 'Authenticated as '.. (getgenv().catname or 'Guest').. ' with ('.. (getgenv().catrole or 'Free').. ')', 4, 'info')
		end
		runService.PostSimulation:Wait()
		vape:CreateNotification('Finished Loading', not inputService.KeyboardEnabled and vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
	end
end

if not isfile('catrewrite/profiles/gui.txt') then
	writefile('catrewrite/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('catrewrite/profiles/gui.txt')

if not isfolder('catrewrite/assets/'..gui) then
	makefolder('catrewrite/assets/'..gui)
end
vape = loadstring(downloadFile('catrewrite/guis/'..gui..'.lua'), 'gui')(license)
shared.vape = vape
_G.vape = vape

getgenv().canDebug = not table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) and debug.getconstant and debug.getproto and true or false
if not shared.VapeIndependent then
	loadstring(downloadFile('catrewrite/games/universal.lua'), 'universal')()

	local found = false
	local callback = shared.VapeDeveloper and readfile or downloadFile
	local function loadPlaceGame(placeId)
		local path = 'catrewrite/games/'..placeId..'.lua'
		if isfile(path) then
			loadstring(readfile(path), tostring(game.PlaceId))(license)
			return true
		end
		if shared.VapeDeveloper then
			return false
		end

		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/MaxlaserTech/CatV6/'..readfile('catrewrite/profiles/commit.txt')..'/games/'..placeId..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile(path), tostring(game.PlaceId))(license)
			return true
		end
		return false
	end
	local supported = httpService:JSONDecode(callback('catrewrite/profiles/supported.json'))
	
	for i, v in supported do
		if found then break; end
		if typeof(v) == 'table' and (v.gameid == nil or game.GameId == v.gameid) then
			for i2, v2 in v do
				if typeof(v2) == 'table' and (v2.Place == game.PlaceId or (typeof(v2.Ids) == 'table' and table.find(v2.Ids, game.PlaceId))) then
					vape.Place = v2.Place
					if v.gameid == nil then
						found = loadPlaceGame(vape.Place)
					else
						found = true
						if not isfolder('catrewrite/games/'.. i) then
							makefolder('catrewrite/games/'.. i)
						end
						
						loadstring(callback('catrewrite/games/'.. i.. '/'.. i2.. '.luau'), tostring(game.PlaceId))(license)
						loadstring(callback('catrewrite/games/'.. i.. '/'.. 'premium'.. '.luau'), 'paid '.. tostring(game.PlaceId))(license)
					end
					break
				end
			end
		end
	end

	if not found then
		loadPlaceGame(game.PlaceId)
	end
	
	if isfile('catrewrite/custom_modules.luau') then
		local func, err = oldload(readfile('catrewrite/custom_modules.luau'))
		print(readfile('catrewrite/custom_modules.luau'))
		if not func then
			vape:CreateNotification('Vape', 'Syntax error: "'.. ({err:gsub('\n', '	')})[1].. '"', 60, 'alert')
			task.spawn(function()
				error(err, 8)
			end)
		end

		if func then
			local clone = table.clone(license)
			clone.Key = '_key'
			xpcall(function()
				func(clone)
			end, function(newerr)
				vape:CreateNotification('Vape', 'Script error: "'.. ({newerr:gsub('\n', '	')})[1].. '"', 60, 'alert')
				task.spawn(function()
					error(newerr, 8)
				end)
			end)
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
