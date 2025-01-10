Clever = {}
Squares = {}

local Reanimate = function(corpse)
	local reanimate_time = getGameTime():getWorldAgeHours() + 12.0

	if 2 > ZombRand(100) then
		Clever[#Clever + 1] = { corpse, reanimate_time - 0.5 }
	else
		corpse:setReanimateTime(reanimate_time)
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

Events.LoadGridsquare.Add(LoadGridsquare)

local function OnZombieDead(zombie)
	Squares[#Squares + 1] = zombie:getCurrentSquare()
end

Events.OnZombieDead.Add(OnZombieDead)

local function EveryTenMinutes()
	for i=1, #Squares do
		ReanimateSquare(table.remove(Squares))
	end

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

-- local function ReanimateNearPlayer(player, args)
-- 	player:getCell():getGridSquare(args[1], args[2], args[3])
-- end

-- local function OnClientCommand(module, command, player, args)
-- 	if (module == "ASD" and command == "ReanimateNearPlayer") then
-- 		ReanimateAtSquare(ReanimateNearPlayer(player, args))
-- 	end
-- end

-- Events.OnClientCommand.Add(OnClientCommand)
