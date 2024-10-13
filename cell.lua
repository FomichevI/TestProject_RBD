Cell={}
Cell.__index=Cell

function Cell:new(_type, _value)
	local object={}
	object.type = _type
	object.value = _value
	setmetatable(object,self)
	return object
end