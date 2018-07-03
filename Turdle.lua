-- DELETE ALL THIS WHEN DONE
TurtleSim = {}

function TurtleSim.turnRight()
	print("I'm turning right!")
	return true
end

function TurtleSim.turnLeft()
	print("I'm turning left!")
	return true
end

function TurtleSim.up()
	print("I'm going up!")
	return true
end

function TurtleSim.down()
	print("I'm going down!")
	return true
end

function TurtleSim.forward()
	print("I'm going forward!")
	return true
end

function TurtleSim.back()
	print("I'm going back!")
	return true
end

function TurtleSim.refuel(times)
	print("Refueling", times, "times")
	return true
end

function TurtleSim.detect()
	return false
end

function TurtleSim.detectUp()
	return false
end

function TurtleSim.detectDown()
	return false
end

function TurtleSim.dig()
	print("I am a dwarf and I'm digging a hole")
end

function TurtleSim.digUp()
	print("I am a dwarf and I'm digging a hole")
end

function TurtleSim.digDown()
	print("I am a dwarf and I'm digging a hole")
end

function TurtleSim.select()
	return false
end

function TurtleSim.place()
	return false
end

function TurtleSim.drop()
	return false
end

function TurtleSim.suck()
	return false
end

function TurtleSim.getFuelLevel()
	return 0
end

function TurtleSim.refuel()
	return true
end

function TurtleSim.getItemCount()
	return 0
end

function sleep()
end

local turtle = TurtleSim
-- DELETE EVERYTHING ABOVE WHEN DONE








local Direction = 0
local XCoord = 0
local YCoord = 0
local ZCoord = 0
local Fuel = 0
local Coke = 0
local NFuel = 0
local NCoke = 0
local blockMap = {}

function Turn(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		for i = 1, (times * -1) do
			turtle.turnLeft()
			Direction = (Direction - 1) % 4
		end
	else
		for i = 1, times do
			turtle.turnRight()
			Direction = (Direction + 1) % 4
		end
	end
end

function MoveVert(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		for i = 1, (times * -1) do
			if turtle.detectDown() then
				turtle.digDown()
			end
			if turtle.down() then
				YCoord = YCoord - 1
			end
		end
	else
		for i = 1, times do
			if turtle.detectUp() then
				turtle.digUp()
			end
			if turtle.up() then
				YCoord = YCoord + 1
			end
		end
	end
end

function fastAxisMove(orientation, times)
	if times == nil then times = 1 end
	local dirToTravel
	local stepsLeft
	if orientation == 'x' then if times > 0 then dirToTravel = 1 else dirToTravel = 3 end
	else if times > 0 then dirToTravel = 0 else dirToTravel = 2 end end
	if times > 0 then stepsLeft = times else stepsLeft = -1 * times end
	
--	Try doing it backwards
	if (Direction-dirToTravel) == 2 or (Direction-dirToTravel) == -2 then
		local remainingSteps = 0
		while stepsLeft > 0 do
			if turtle.back() then
				if Direction == 1 then XCoord = XCoord - 1 else XCoord = XCoord + 1 end
				stepsLeft = stepsLeft - 1
			else
				remainingSteps = stepsLeft
				stepsLeft = 0
			end
		end
		if remainingSteps > 0 then
			turnRight(2)
			MoveForward(remainingSteps)
		end
	else
		TurnTo(dirToTravel)
		MoveForward(stepsLeft)
	end
end
	

function MoveForward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		times = times * -1
		Turn(2)
	end
	for i = 1, times do
		while turtle.detect() do
			turtle.dig()
			sleep(0.5)
		end
		if turtle.forward() then
			if Direction == 0 then
				ZCoord = ZCoord + 1
			elseif Direction == 1 then
				XCoord = XCoord + 1
			elseif Direction == 2 then
				ZCoord = ZCoord - 1
			elseif Direction == 3 then
				XCoord = XCoord - 1
			end
		end
	end
end


function TurnTo(dir)
	local spin = dir-Direction
	if spin == 3 then spin = -1
	elseif spin == -3 then spin = 1 end
	Turn(spin)
end

function goTo(x, y, z)
	local goX = x - XCoord
	local goY = y - YCoord
	local goZ = z - ZCoord	
	fastAxisMove('x', goX)
	MoveVert(goY)
	fastAxisMove('z', goZ)
end
	
function Refuel()
	Fuel = turtle.getFuelLevel()
	print(Fuel)
	while Fuel < 1000 do
		NFuel = 1000 - Fuel
		NCoke = NFuel / 160
		NCoke = math.ceil(NCoke)
		TurnTo(1)
		turtle.select(3)
		turtle.place()
		turtle.select(1)
		turtle.suck(NCoke)
		Coke = turtle.getItemCount()
		turtle.refuel(Coke - 1)
		Fuel = turtle.getFuelLevel()
	end
	turtle.dig()
	TurnTo(0)
end

function getBlockmapCoord(dir)
	if dir == "north" or dir == 0 or (dir == "forward" and Direction == 0) then
		return XCoord..':'..YCoord..':'..(ZCoord+1)
	elseif dir == "east" or dir == 1 or (dir == "forward" and Direction == 1) then
		return (XCoord+1)..':'..YCoord..':'..ZCoord
	elseif dir == "south" or dir == 2 or (dir == "forward" and Direction == 2) then
		return XCoord..':'..YCoord..':'..(ZCoord-1)
	elseif dir == "west" or dir == 3 or (dir == "forward" and Direction == 3) then
		return (XCoord-1)..':'..YCoord..':'..ZCoord
	elseif dir == "up" then return XCoord..':'..(YCoord+1)..':'..ZCoord
	elseif dir == "down" then return XCoord..':'..(YCoord-1)..':'..ZCoord
	end
end

function checkIfOre(dir)
	local oreTrue = false
	local success, data
	
	if dir == nil then dir = "forward" end
	if blockMap[getBlockmapCoord(dir)] ~= nil then return false end
	
	if dir == "forward" then success, data = turtle.inspect()
	elseif dir == "up" then success, data = turtle.inspectUp()
	elseif dir == "down" then success, data = turtle.inspectDown()
	elseif dir == "north" or dir == 0 then
		TurnTo(0)
		success, data = turtle.inspect()
	elseif dir == "east" or dir == 1 then
		TurnTo(1)
		success, data = turtle.inspect()
	elseif dir == "south" or dir == 2 then
		TurnTo(2)
		success, data = turtle.inspect()
	elseif dir == "west" or dir == 3 then
		TurnTo(3)
		success, data = turtle.inspect()
	end
		
	if success then
		if 	data.name ~= "minecraft:stone" and
			data.name ~= "minecraft:grass" and
			data.name ~= "chisel:limestone" and
			data.name ~= "chisel:diorite" and
			data.name ~= "railcraft:quarried_stone" and
			data.name ~= "chisel:andesite" and
			data.name ~= "chisel:granite" and
			data.name ~= "chisel:marble" and
			data.name ~= "minecraft:gravel" and
			data.name ~= "minecraft:dirt" and
			data.name ~= "minecraft:lava" and
			data.name ~= "minecraft:water" then
			oreTrue = true
		else
			oreTrue = false
		end
	else
		oreTrue = false
	end
	
	blockMap[getBlockmapCoord("forward")] = oreTrue
	return oreTrue
end

local dfsCount = 0

function dfs(returnX, returnY, returnZ)
	local currDFS = dfsCount
	dfsCount = dfsCount + 1
	for i = 0, 3 do 
		if checkIfOre(i) then
			MoveForward()
			dfs(XCoord, YCoord, ZCoord)
		end
	end
	if checkIfOre("up") then
		MoveVert(1)
		dfs(XCoord, YCoord, ZCoord)
	end
	if checkIfOre("down") then
		MoveVert(-1)
		dfs(XCoord, YCoord, ZCoord)
	end
	goTo(returnX, returnY, returnZ)
end

	
	
			
		


function printStats()
	print("Direction:", Direction, "Coordinates:", XCoord, YCoord, ZCoord)
end
print("Need 1000 Fuel in Slot 1!")

function initialFuel()
	Fuel = turtle.getFuelLevel()
	while Fuel < 1000 do
		sleep(1)
		Coke = turtle.getItemCount()
		if Coke >= 2 then
			turtle.refuel(Coke - 1)
			sleep(1)
			Fuel = turtle.getFuelLevel()
			print("Fuel is now ", Fuel)
		end
	end
end

function placeTorch()
	turtle.select(16)
	turtle.place()
end

function dumpItems()
	turtle.select(2)
	turtle.place()
	for i = 4, 15 do
		turtle.select(i)
		turtle.drop()
	end
	turtle.select(2)
	turtle.dig()
end

function tunnel2x3()
	while 1 == 1 do
		Refuel()
		for i = 1, 10 do
			for i = 1, 10 do
				MoveForward()
				TurnTo(3)
				searchForOres("down")
				searchForOres("forward")
				searchForOres("up")
				MoveVert(1)
				searchForOres("forward")
				searchForOres("up")
				MoveVert(1)
				searchForOres("forward")
				searchForOres("up")
				TurnTo(1)
				MoveForward()
				searchForOres("down")
				searchForOres("forward")
				searchForOres("up")
				MoveVert(-1)
				searchForOres("down")
				searchForOres("forward")
				MoveVert(-1)
				searchForOres("down")
				searchForOres("forward")
				TurnTo(3)
				MoveForward()
				TurnTo(0)
			end
			MoveVert()
			TurnTo(1)
			placeTorch()
			MoveVert(-1)
			dumpItems()
			TurnTo(0)
		end
	end
end

function searchForOres(dir)
	if checkIfOre(dir) then
		startDirection = Direction
		dfs(XCoord, YCoord, ZCoord)
		TurnTo(startDirection)
		blockMap = {}
	end
end


initialFuel()
searchForOres()
tunnel2x3()