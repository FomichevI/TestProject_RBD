require "test_logic"
require "visualizer"
require "input"
require "coordinate"

logic = TestLogic:new()
visualizer = Visualizer:new()
input = Input:new()

local isPlaying = true

os.execute("cls")
logic:init()
visualizer:dump(logic.grid)
repeat
	--запрашиваем ввод пользовател€, пока не будет введен допустимых ход
	repeat
		fromPos, toPos = input:getMoveValue()
	until logic:move(fromPos, toPos)
	--проводим объединение сложившихс€ комбинаций и заполнение пустых €чеек, пока комбинации не закончатс€
	repeat
		print('')
		print("Merge!")
		logic:tick()
		visualizer:dump(logic.grid)
	until logic:isMergeAvailable(logic.grid) == false
	--если нет доступных ходов, то перемешиваем поле, пока не по€в€тс€ возможные ходы
	if (logic:hasAvailableMove() == false) then
		repeat
			logic:mix()
		until logic:hasAvailableMove()
		print("No available turns! Shuffle!")
		visualizer:dump(logic.grid)		
	end	
until isPlaying == false