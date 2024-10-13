Visualizer={}
Visualizer.__index=Visualizer

function Visualizer:new()
	local object={}
	setmetatable(object,self)
	return object
end

function Visualizer:dump(grid)	
	local firstLine = "   "
	local secondLine = "---"
	for x=0, #(grid) do
		firstLine = firstLine ..x .." "
		secondLine = secondLine .."--"
	end
	print('')
	print (firstLine)
	print (secondLine)
		
	for y=0, #(grid[0]) do
		local line = y .."| "
		for x=0,#(grid) do
			line = line ..grid[x][y].value .." "
		end
		print (line)
	end
end