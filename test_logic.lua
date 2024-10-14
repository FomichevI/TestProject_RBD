require "logic"
require "settings"
require "cell"
require "coordinate"

settings = Settings:new()

TestLogic={}
TestLogic.__index=TestLogic
setmetatable(TestLogic,Logic)

function TestLogic:new()
	local object=Logic:new()
	setmetatable(object,self)
	return object
end

--генерирует стартовый уровень
function TestLogic:init()	
	for i=0,settings.columnCount-1 do
		self.grid[i] = {}
			for j=0,settings.rowCount-1 do
			exceptions = {} --типы-исключения, которые нельзя генерировать в текущей ячейке
			--проверяем, есть ли на уже сгенерированном уровне 2 одинаковых элемента в одну линию и добавляем такой тип элемента в исключения
			if i>=2 then
				if self.grid[i-1][j].value == self.grid[i-2][j].value then
					table.insert(exceptions, self.grid[i-1][j].value)
				end				
			end
			if j>=2 then
				if self.grid[i][j-1].value == self.grid[i][j-2].value then
					table.insert(exceptions, self.grid[i][j-1].value)
				end				
			end
			self.grid[i][j] = self:getRandomeCell(exceptions)
		end
	end
	if (self:hasAvailableMove() == false) then
		repeat
		self:mix()
		until self:hasAvailableMove()
	end	
end

--Если возможно совершить такой ход, то совершает его и возвращает true. Если нет - возвращает false
function TestLogic:move(from, to)
	local availableMove = true
	for i = 1, 1 do
		--если координаты меньше минимально возможного значения
		if (from.x < 0 or from.y < 0 or to.x < 0 or to.y < 0) then
			availableMove = false
			break
		end
		--если координаты больше максимально возможного значения
		if (from.x >= settings.columnCount or from.y >= settings.rowCount 
		or to.x >= settings.columnCount or to.y >= settings.rowCount ) then
			availableMove = false
			break
		end
		--если в следствии этого перемещения не произойдет объединения
		gridCopy = self:getGridCopy()
		self:makeTurn(gridCopy, from, to)		
		if (self:isMergeAvailable(gridCopy) == false and self:isUnicTypesMergeAvailable() == false) then
			availableMove = false
			break
		end		
	end
	if (availableMove == false) then
		print("You can't make this move!")
	else
		self:makeTurn(self.grid, from, to)
	end
	return availableMove
end

--логика одного цикла объединения фишек
function TestLogic:tick()
	local comboArray = self:getMergedComboArray()
	self:deleteCells(comboArray)
	self:fillEmptyCells()
end

--возвращает все найденный комбинации, в которых объеденены 3 и больше фишек
function TestLogic:getMergedComboArray()
	local mergeVerCombo = {}
	local mergeHorCombo = {}
	local maxX = #(self.grid)
	local maxY = #(self.grid[0])
	for x = 0, maxX do
		for y = 0, maxY do
			--проверяем, нет ли текущей клетки в уже записанных комбинациях
			local containsInVer = false
			local containsInHor = false
			for i = 1,#(mergeVerCombo) do
				for j = 1,#(mergeVerCombo[i]) do
					if (mergeVerCombo[i][j].x == x and mergeVerCombo[i][j].y ==y) then
					containsInVer = true
					break
					end
				end				
			end
			for i = 1, #(mergeHorCombo) do
				for j = 1,#(mergeHorCombo[i]) do
					if (mergeHorCombo[i][j].x == x and mergeHorCombo[i][j].y ==y) then
					containsInHor = true
					break
					end
				end				
			end		
			
			--в эти списки будем записывать элементы Coordinate клеток, которые подходят под комбо по вертикали и горизонтали
			local equalCellsVer = {}
			local equalCellsHor = {}
			table.insert(equalCellsVer, Coordinate:new(x,y))
			table.insert(equalCellsHor, Coordinate:new(x,y))
			--находим вертикальные комбинации
			local offsetY = 1
			local isSerchVerOver = false
			if (maxY - y >= 2 and containsInVer ~= true) then			
				repeat
					if (self.grid[x][y].value == self.grid[x][y + offsetY].value) then
					table.insert(equalCellsVer, Coordinate:new(x,y + offsetY))
					offsetY = offsetY + 1
					if (y + offsetY > maxY) then isSerchVerOver = true end
					else
						isSerchVerOver = true
					end
				until isSerchVerOver
			end
			
			local offsetX = 1
			isSerchVerOver = false
			if (maxX - x >= 2 and containsInHor ~= true) then
				repeat
					if (self.grid[x][y].value == self.grid[x + offsetX][y].value) then
					table.insert(equalCellsHor, Coordinate:new(x + offsetX,y))
					offsetX = offsetX + 1
					if (x + offsetX > maxX) then isSerchVerOver = true end
					else
						isSerchVerOver = true
					end
				until isSerchVerOver
			end
			--добавляем найденные комбинации, если их общее число элементов в них >= 3
			if (#(equalCellsVer) >= 3) then
				table.insert(mergeVerCombo, equalCellsVer)
			end
			if (#(equalCellsHor) >= 3) then
				table.insert(mergeHorCombo, equalCellsHor)
			end
		end
	end	
	--print("ver " ..#(mergeVerCombo))
	--print("hor " ..#(mergeHorCombo))
	--объединяем комбинации, если хотя бы один элемент встречается и в горизонтальной, и в вертикальной комбинации (угловые или крестовые комбинации из 5+ элементов)
	--пока что реализация ужасна
	local allCombo = {}	
	for iv = 1,#(mergeVerCombo) do
		local isMultiCombo = false
		for jv = 1,#(mergeVerCombo[iv]) do
			for ih = #(mergeHorCombo), 1, -1 do
				for jh = 1,#(mergeHorCombo[ih]) do
					if (mergeVerCombo[iv][jv].x == mergeHorCombo[ih][jh].x and mergeVerCombo[iv][jv].y == mergeHorCombo[ih][jh].y) then
						isMultiCombo = true
						multiCombo = {}
						for jv1 = 1,#(mergeVerCombo[iv]) do
							table.insert(multiCombo, mergeVerCombo[iv][jv1])
						end
						for jh1 = 1,#(mergeHorCombo[iv]) do
							if (jh1 ~= jh) then
								table.insert(multiCombo, mergeHorCombo[iv][jh1])
							end
						end
						table.insert(allCombo, multiCombo)
						table.remove(mergeHorCombo, ih)
						break
					end
				end	
			end
		end
		if (isMultiCombo == false) then
			table.insert(allCombo, mergeVerCombo[iv])
		end
	end
	for ih = 1, #(mergeHorCombo) do
		table.insert(allCombo, mergeHorCombo[ih])
	end
	
	--print("all " ..#(allCombo))
	return allCombo
end

--удаляет указаные комбинации с игрового поля
function TestLogic:deleteCells(comboArray)
	for i = 1, #comboArray do
		--print("Combo lenght: " ..#(comboArray[i]))
		--тут же можно прописать логику удаления комбинаций определенной длины
		for j=1, #(comboArray[i]) do
			--print ('deleted ' ..comboArray[i][j].x ..' ' ..comboArray[i][j].y)
			self.grid[comboArray[i][j].x][comboArray[i][j].y].value = settings.deletedCellColor		
		end
	end
end

--перемещает верхние ячейки на место пустых нижних ячеек и заполняет оставшееся пространсто рандомными ячейками
function TestLogic:fillEmptyCells()
	--сначала перемещаем все элементывниз на пустые ячейки
	for x=0, #(self.grid) do
		for y = #(self.grid[x]), 0, -1 do
			if(self.grid[x][y].value == settings.deletedCellColor) then
				for targetY = y-1, 0, -1 do
					--print(self.grid[x][targetY].value)
					if (self.grid[x][targetY].value ~= settings.deletedCellColor) then
						self.grid[x][y] = Cell:new(self.grid[x][targetY].type, self.grid[x][targetY].value)
						self.grid[x][targetY].value = settings.deletedCellColor
						break
					end
				end
			end			
		end
	end
	--теперь заполняем все пустые ячейки новыми случайными фишками
	for x=0, #(self.grid) do
		for y = 0, #(self.grid[x]) do
			if(self.grid[x][y].value == settings.deletedCellColor) then
				local exceptions = {}
				self.grid[x][y] = self:getRandomeCell(exceptions)
			end			
		end
	end
end

--возвращает рандомный тим, исключая типы exceptions
function TestLogic:getRandomeCell(exceptions)
	local currentValue
	repeat
		local notExeption = true
		currentValue = settings.cellColors[math.random(#(settings.cellColors))]
		for i = 0, #(exceptions) do
			if currentValue==exceptions[i] then
				notExeption = false
			end
		end
	until notExeption == true
	--продолжение логики, если нам нужны особенные типы для конкретных стартовых ячеек
	newCell = Cell:new('simple', currentValue)
	return newCell
end

--проверка на уникальные типы (не реализована)
function TestLogic:isUnicTypesMergeAvailable()
	return false
end

function TestLogic:isMergeAvailable(grid)
	local mergeAvailable = false
	local x = #(grid)
	local y = #(grid[0])
	--проверку по соответствию типов проводить не будем, так как некоторые типы могут в дальнейшем взаимодействовать друг с другом, а другие - нет
	repeat
		y = #(grid[0])
		repeat
			--проверка по вертикали (вверх)
			if (y-2 >= 0) then
				if(grid[x][y].value == grid[x][y-1].value and grid[x][y].value == grid[x][y-2].value) then
					mergeAvailable = true
					break
				end
			end
			--проверка по горизонтали (влево)
			if (x-2 >= 0) then
				if(grid[x][y].value == grid[x-1][y].value and grid[x][y].value == grid[x-2][y].value) then
					mergeAvailable = true
					break
				end		
			end	
			y = y-1
		until y <= -1
		if (mergeAvailable == true) then break end
		x = x-1
	until x <= -1
	return mergeAvailable
end

function TestLogic:getGridCopy()
	local gridCopy = {}
	for i = 0, #(self.grid) do
		gridCopy[i] = {}
		for j = 0, #(self.grid[i]) do
			gridCopy[i][j] = Cell:new(self.grid[i][j].type, self.grid[i][j].value)
		end
	end	
	return gridCopy
end

function TestLogic:makeTurn(grid, from, to)
	if (grid[from.x][from.y].type == 'simple' and grid[to.x][to.y].type == 'simple') then
		local fromType = grid[from.x][from.y].type
		local fromValue = grid[from.x][from.y].value
		grid[from.x][from.y] = grid[to.x][to.y]
		grid[to.x][to.y] = Cell:new(fromType, fromValue)	
	end
	--дальше логика с особыми типами
end

function TestLogic:hasAvailableMove()
	local hasMove = false
	--логика поиска возможной комбинации заключается в поиске вокруг одной ячейки ячеек с тем же значением и сравнивания их положения
	--для полного понимания лучше визуализировать все возможные комбинации (всего останется 3 шаблона удачного расположения ячеек)
	local maxX = #(self.grid)
	local maxY = #(self.grid[0])
	for x = 0, maxX do
		for y = 0, maxY do
			if ((x == 0 and y == 0) or (x == maxX and y == 0) or (x == 0 and y == maxY) or 
			(x == maxX and y == maxY)) then
				--граничные значения пропускаем
				goto continue 
			end
			--находим все элементы с тем же значением вокруг интересующей нас клетки
			targetOffsets = {}
			for offsetX = -1, 1 do
				for offsetY = -1, 1 do
					if ((x + offsetX >= 0) and (x + offsetX <= maxX) and (y + offsetY >= 0) and (y + offsetY <= maxY) and 
					(offsetX ~= 0 or offsetY ~= 0)) then
						if (self.grid[x][y].value == self.grid[x+offsetX][y+offsetY].value) then
							offsetPos = Coordinate:new(offsetX, offsetY)
							table.insert(targetOffsets, offsetPos)
						end
					end
				end
			end
			--если элементов 2 или больше, то делаем проверку по шаблону
			--print(x ..' ' ..y ..' ' ..self.grid[x][y].value ..' ' ..#targetOffsets)
			if (#targetOffsets >= 2) then
				for i = 1, #targetOffsets do
					for j = 1, #targetOffsets do
						if (i ~= j) then						
							if (targetOffsets[i].x == 0) then
								if (targetOffsets[j].y ~= targetOffsets[i].y and targetOffsets[j].y ~= 0) then
									hasMove = true
									break
								end
							elseif (targetOffsets[i].y == 0) then
								if (targetOffsets[j].x ~= targetOffsets[i].x and targetOffsets[j].x ~= 0) then
									hasMove = true
									break
								end
							else
								if ((targetOffsets[j].x == targetOffsets[i].x and targetOffsets[j].y ~= 0) and 
								(targetOffsets[j].y == targetOffsets[i].y and targetOffsets[j].x ~= 0) and 
								(targetOffsets[j].x ~= -targetOffsets[i].x and targetOffsets[j].y ~= -targetOffsets[i].y)) then
									hasMove = true
									break
								end
							end
						end
					end
					if (hasMove) then break end
				end
			end			
			::continue::
			if (hasMove)then 				
				--print("Has move " ..self.grid[x][y].value)
				break 
			end
		end
		if (hasMove) then break end
	end
	return hasMove
end

function TestLogic:mix()
	repeat
	--собираем все имеющиеся клетки в один массив
	local allCells = {}
	for x=0, #(self.grid) do
		for y=0, #(self.grid[x]) do
			local cell = Cell:new(self.grid[x][y].type, self.grid[x][y].value)
			table.insert(allCells, cell)
		end
	end
	--перемешиваем массив
	for i = #allCells, 2, -1 do
		local j = math.random(i)
		allCells[i], allCells[j] = allCells[j], allCells[i]
	end
	--перезаполняем нашу сетку
	for x=0, #(self.grid) do
		for y=0, #(self.grid[x]) do
			self.grid[x][y] = allCells[#allCells]
			table.remove(allCells, #allCells)
		end
	end
	until self:isMergeAvailable(self.grid) == false
end