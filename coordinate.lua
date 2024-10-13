Coordinate={}
Coordinate.__index=Coordinate

function Coordinate:new(xPos, yPos)
	local object={}
	object.x = xPos
	object.y = yPos
	setmetatable(object,self)
	return object
end