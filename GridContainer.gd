extends GridContainer

# Объект контейнер для расстановки по сетке с указанным количеством столбцов.
# Создаёт объекты "клекта" в указанном из модуля "game_logic" количестве (квадратная матрица).
# Является медиатором для модуля логики и объектов типа "клетка".
# Выполняет управляющие функции для событий игрового поля (общие анимации и еффекты)

# Подключаем модуль с моделью игры и поведением (логика и механика)
const c_gameLogic = preload("res://game_logic.gd") 
var game_logic = null
const c_CommandProtocolVersion = 1
var StartButton = null
var FinalLabel = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var control = preload("res://Control.tscn")
	game_logic = c_gameLogic.new()
	columns = game_logic.c_nColumns
	# Подключим калбек от модуля логики для обработки изменения состояния модели.
	game_logic.connect("changState", self, "on_changeState")
	StartButton = get_parent().get_node("Button")
	FinalLabel = get_parent().get_node("Label")
	
	for i in columns * columns:
		var new_control = control.instance()
		# Установим идентификатор создаваемого объекта
		new_control.id = i
		# Подключим сигнал от созданного объекта к медиатору (текущему объекту).
		new_control.connect("clicked", self, "on_controlClicked")
		add_child(new_control)
		
# Калбек для модуля логики, будет вызываться при изменении состояния объектов сцены.
# Здесь можно вызывать анимацию и эффекты для игрового поля или клетки.
func on_changeState(command):
	if command.protocol == c_CommandProtocolVersion:
		print(">> ", command)
		match  command.cmd_type:
			Global.ECMDType.NEXT_STEP:
				get_child(command.id).setState(command.player)
			
			Global.ECMDType.FINAL:
				StartButton.visible = true
				FinalLabel.visible = true
				var text = ""
				match command.player:
					Global.EPlayers.PLAYER1:
						text = "WIN"
					Global.EPlayers.PLAYER2:
						text = "LOSE"
				FinalLabel.text = text
				
# Обработчик событий дочерних объектов (клик по объекту)
func on_controlClicked(nId):
	print(">> ", nId)
	if game_logic:
		game_logic.onCellClick(nId)

func _on_Button_pressed():
	for i in columns * columns:
		get_child(i).setState(Global.EPlayers.NONE)
	StartButton.visible = false
	FinalLabel.visible = false
	game_logic.runGame()
	
