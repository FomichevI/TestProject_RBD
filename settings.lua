Settings={}
Settings.__index=Settings

function Settings:new()
	local object={}
	object.rowCount = 10
	object.columnCount = 10
	object.cellColors = {'A', 'B', 'C', 'D', 'E', 'F'}
	--цвет, которым отмечаются удаленные объекты. Виден только внутри программы, игроку эти данные не видны
	object.deletedCellColor = 'X'
	setmetatable(object,self)
	return object
end