Settings={}
Settings.__index=Settings

function Settings:new()
	local object={}
	object.rowCount = 10
	object.columnCount = 10
	object.cellColors = {'A', 'B', 'C', 'D', 'E', 'F'}
	--����, ������� ���������� ��������� �������. ����� ������ ������ ���������, ������ ��� ������ �� �����
	object.deletedCellColor = 'X'
	setmetatable(object,self)
	return object
end