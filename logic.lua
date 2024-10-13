Logic={}
Logic.__index=Logic

function Logic:new()
	local object={}
	object.grid={}
	setmetatable(object,self)
	return object
end

function Logic:init()
	print('Run function init')
end

function Logic:tick()
	print('Run function tick')
end

function Logic:move(from, to)
	availableMove = true
	print('Run function move')
	return availableMove
end

function Logic:mix()
	print('Run function mix')
end