local gameTime

local sandboxASD = SandboxVars.ASD

Events.OnGameTimeLoaded.Add(function()
    gameTime = GameTime.getInstance()
end)

local Clever = {}
-- local Squares = {}

local Reanimate = function(corpse)
	local reanimate_time = gameTime:getWorldAgeHours() + (sandboxASD.ReanimateTimeMin + ZombRand(101) * (sandboxASD.ReanimateTimeMax - sandboxASD.ReanimateTimeMin)) / 60.0

	if corpse:isSkeleton() and not sandboxASD.ReanimateSkeletons then return end
	if corpse:isPlayer() and not sandboxASD.ReanimatePlayers then return end

	local corpseModData = corpse:getModData()

	if (corpseModData.dead ~= true) then
		if sandboxASD.ReanimateChance > ZombRand(100) then
			if sandboxASD.FakeDeadChance > ZombRand(100) then
				Clever[#Clever + 1] = { corpse, reanimate_time }
			else
				corpse:setReanimateTime(reanimate_time)
			end
		else
			corpseModData.dead = true
		end
	end
end

local ReanimateSquare = function(square)
	if square then
		local corpses = square:getDeadBodys()
		for i=0, corpses:size()-1 do
			local corpse = corpses:get(i)
			Reanimate(corpse)
		end
	end
end

local function LoadGridsquare(square)
	if isServer() then
		ReanimateSquare(square)
	end
end

if sandboxASD.ReanimateNearbyCorpses then
	Events.LoadGridsquare.Add(LoadGridsquare)
end

-- local function OnCharacterDeath(character)
-- 	if isServer() then
-- 		Squares[#Squares + 1] = character:getCurrentSquare()
-- 	end
-- end

Events.OnCharacterDeath.Add(OnCharacterDeath)

local function EveryTenMinutes()
	-- for i=1, #Squares do
	-- 	ReanimateSquare(table.remove(Squares))
	-- end

	for i=1, #Clever do
		if Clever[#Clever][2] >= getGameTime():getWorldAgeHours() then -- reanimate_time >= now
			local corpse = Clever[#Clever][1]
			if corpse then
				corpse:setFakeDead(true)
			end
			table.remove(Clever)
		end
	end
end

Events.EveryTenMinutes.Add(EveryTenMinutes)

local function OnClientCommand(module, command, player, args)
	if (module == "ASD" and command == "ReanimateNearPlayer") then
		ReanimateSquare(player:getCell():getGridSquare(args[1], args[2], args[3]))
	end
end

Events.OnClientCommand.Add(OnClientCommand)
