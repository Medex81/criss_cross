extends GridContainer

# Объект контейнер для расстановки по сетке с указанным количеством столбцов.
# Создаёт объекты "клекта" в указанном из модуля "game_logic" количестве (квадратная матрица).
# Является медиатором для модуля логики и объектов типа "клетка".
# Выполняет управляющие функции для событий игрового поля (общие анимации и еффекты)
# Called when the node enters the scene tree for the first time.
func _ready():
	var control = preload("res://Control.tscn")
	columns = game_logic.c_nColumns
	# Подключим калбек от модуля логики для обработки изменения состояния модели.
	game_logic.disconnect("changState", self, "on_changeState")
	game_logic.connect("changState", self, "on_changeState")	
	
	for i in columns * columns:
		var new_control = control.instance()
		# Установим идентификатор создаваемого объекта
		new_control.id = i
		# Подключим сигнал от созданного объекта к медиатору (текущему объекту).
		new_control.connect("clicked", self, "on_controlClicked")
		add_child(new_control)
		
# Калбек для модуля логики, будет вызываться при изменении состояния объектов сцены.
# Здесь можно вызывать анимацию и эффекты для игрового поля или клетки.
func procc_command(command, sender):
	if sender != self:
		print(">> ", command)
		match  command.cmd_type:
			Global.ECMDType.NEXT_STEP:
				get_child(command.id).setState(command.player)
			Global.ECMDType.READY:
				for i in columns * columns:
					get_child(i).setState(Global.EPlayers.NONE)
					get_child(i).setForceFrame(false)
			Global.ECMDType.FINAL:
				for id in command.arr_idx:
					get_child(id).setForceFrame(true)
					
# Обработчик событий дочерних объектов (клик по объекту)
func on_controlClicked(nId):
	print(">> ", nId)
	if game_logic:
		game_logic.onCellClick(nId)