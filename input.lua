require "coordinate"

Input={}
Input.__index=Input

function Input:new()
local object={}
object.moveCommand = 'm'
object.quitCommand = 'q'
object.currectDirections = {'r', 'l', 'u', 'd'}
setmetatable(object,self)
return object
end

function Input:getMoveValue()
	print('')
	print("Make your turn!")
	repeat
		io.flush()
		value ={}
		local massage = io.read()
		for str in string.gmatch(massage, "[^%s]+") do
			table.insert(value, str)
		end
	until self:checkMoveInput(value)
	fromPos, toPos = self:convertToCoordinates(value)
	return fromPos, toPos
end

function Input:checkMoveInput(value)	
	local isCorrectValue = true
	--закрываем приложение при вводе команды выхода
	if (#value == 1 and value[1] == self.quitCommand) then
		print('Exit')
		os.exit()
	end
	
	for k=1,1 do
		--проверка на количество введенных данных
		if (#(value) ~= 4) then
			isCorrectValue = false
			break
		end
		--проверка на правильность ввода команды
		if (value[1] ~= self.moveCommand) then 
			isCorrectValue = false
			break
		end
		--проверка на правильность ввода направления
		local hasCorrectDirection = false
		for i=1, #(self.currectDirections) do
			if (self.currectDirections[i] == value[4]) then
				hasCorrectDirection = true 
				break
			end
		end
		if (hasCorrectDirection == false) then
			isCorrectValue = false
			break
		end
		--проверка на то, являются ли координаты числами
		if (value[2]:find("%D") or value[3]:find("%D")) then
			isCorrectValue = false
		end
	end	
	
	if(isCorrectValue == false) then
		print("Incorrect value! Example correct value: m 3 0 r")
		print("Or 'q' for exit")
	end	
	return isCorrectValue
end

function Input:convertToCoordinates(value)
	fromX = tonumber(value[2])
	fromY = tonumber(value[3])
	
	fromCoordinate = Coordinate:new(fromX, fromY)
	if(value[4] == 'r') then
		toCoordinate = Coordinate:new(fromX + 1, fromY)
	elseif (value[4] == 'l') then
		toCoordinate = Coordinate:new(fromX - 1, fromY)	
	elseif (value[4] == 'u') then
		toCoordinate = Coordinate:new(fromX, fromY - 1)
	else
		toCoordinate = Coordinate:new(fromX, fromY + 1)
	end
	return fromCoordinate, toCoordinate
end