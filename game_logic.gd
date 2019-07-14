extends Node

# Размерность квадратной матрицы модели
const c_nColumns = 3
# Матрица состояний модели
var aModel = []
var aEmptyCells = []
# Минимальная длина совпадающего массива 
const minMatchArrLen = 3
# Маркер конца массива
const c_nArrEnd = -1
# Текущий ход делает
var eStepForPlayer = Global.EPlayers.NONE
# Калбек медиатора для оповещения о изменении состояния модели посредством команды.
signal changState(command)

# Получить массив элементов столбика с объектом 
func _getColArray(IDPos:Vector2):
	var colIndArray = []
	for y in range(c_nColumns):
		colIndArray.append((y * c_nColumns) + IDPos.x)
	#print("_getColArray > ", colIndArray)
	return colIndArray

# Получить массив элементов строки с объектом	
func _getRowArray(IDPos:Vector2):
	var rowIndArray = []
	for x in range(c_nColumns):
		rowIndArray.append((IDPos.y * c_nColumns) + x)
	#print("_getRowArray > ", rowIndArray)
	return rowIndArray

# Получить массив элементов наискось слева снизу - вправо вверх	
func _getLBRTArray(IDPos:Vector2):
	# Расчитывает исходную позицию для диагонали
	var offsetPos = Vector2(IDPos.x, IDPos.y)
	# Минимальное смещение до края игрового поля
	var offset = min(offsetPos.x, (c_nColumns - 1) - offsetPos.y)
	offsetPos.x -= offset
	offsetPos.y += offset
	
	# Проходим по клеткам и записываем индексы наискось
	var LDRTIndArray = []
	while offsetPos.y > -1 && offsetPos.x < c_nColumns:
		LDRTIndArray.append((offsetPos.y * c_nColumns) + offsetPos.x)
		offsetPos.y -= 1
		offsetPos.x += 1
	#print("_getLBRTArray > ", LDRTIndArray)
	return LDRTIndArray

# Получить массив элементов наискось слева вверх - вправо низ	
func _getLTRBArray(IDPos:Vector2):
	var offsetPos = Vector2(IDPos.x, IDPos.y)
	var offset = min(offsetPos.x, offsetPos.y)
	offsetPos.x -= offset
	offsetPos.y -= offset
	
	var LTRBIndArray = []
	while offsetPos.x < c_nColumns && offsetPos.y < c_nColumns:
		LTRBIndArray.append((offsetPos.y * c_nColumns) + offsetPos.x)
		offsetPos.x += 1
		offsetPos.y += 1
	#print("_getLTRBArray > ", LTRBIndArray)
	return LTRBIndArray

# Получить массив массивов элементов подходящих по условию(несколько подряд одного типа)	
func _getMatchArrays(aArray):
	var matchArrs = []
	# Добавляем маркер конца массива для обработки последнего элемента
	aArray.append(c_nArrEnd)
	# Инициализируем тип элемента - типом первого элемента во входящем массиве это исключает переключение типов на первом элементе
	var curType = aModel[aArray.front()]
	var curArray = []
	# Проходим по входящему массиву, ищем последовательности типов заданной длины
	for i in aArray:
		#print("_processMatch(aArray) > ", aModel[i])
		# Смена типа или конец массива с обработкой последнего элемента
		if curType != aModel[i] || i == c_nArrEnd:
			#print("_getMatchArrays(curType != aModel[i]) > ", " mincount>",minMatchArrLen, " type>",curType, " array>", aArray)
			# Найденная последовательность подходим и тип не пустой
			if curArray.size() >= minMatchArrLen && curType != Global.EPlayers.NONE:
				matchArrs.append(curArray.duplicate())
				#print("_processMatch(add match) > ", curArray)
			# На маркере конца массива выходим чтобы не обратиться за типом по несуществующему индексу
			if i == c_nArrEnd:
				break
			curArray.clear() 
			curType = aModel[i]
		# Добавляем следующий элемент во временный массив
		curArray.append(i)
	return matchArrs

# Обрабатываем совпадение по размеру допустимой последовательности
func _processMatch(aIdxArray):
	if len(aIdxArray):
		#print("_processMatch > ", len(aIdxArray))		
		# Действия при совпадении, указываем разные виды совпадений и обработчики для них.
		for m in aIdxArray:
			print("match> ", aModel[m.front()], " arr>", m)
			# Любое совпадение
			eStepForPlayer = Global.EPlayers.NONE
			# шаблон команды
			var command = Global.createCommandFinal()
			# Массив индексов победной комбинации
			command.arr_idx = m.duplicate()
			# Победитель
			command.player = aModel[m.front()]
			# Отправляем команду подписавшимся объектам на обработку
			emit_signal("changState", command)
			print("final> ", aModel[m.front()])
# Запускаем игру, инициализируем игровые объекты
func runGame():
	#print("func _init()")
	# Инициализация матрицы
	aModel.clear()
	aEmptyCells.clear()
	for i in c_nColumns * c_nColumns:
		aModel.append(Global.EPlayers.NONE)
		aEmptyCells.append(i);
	# Первый шаг делает игрок... 
	eStepForPlayer = Global.EPlayers.PLAYER1
	# Специальный массив для оставшихся пустых клеток с его помощью мы будем расчитывать следующий ход
	#aEmptyCells = aModel.duplicate();
	randomize()
	# Выбран первым ход игровой логики
	if eStepForPlayer == Global.EPlayers.PLAYER2:
		_processNextStep(aEmptyCells[randi() % aEmptyCells.size()])

# Обработка следующего шага(состояния) игры.
# Здесь мы можем устанавливать и проверять состояние модели игры, отправлять объект команды смены состояния в медиатор.
# Можно получить объект команды от удалённого игрока или выбрать от имени игры.
func _processNextStep(nId:int):
	# Нажали на пустую клетку и игра ещё не закончена
	if aModel[nId] == Global.EPlayers.NONE && eStepForPlayer != Global.EPlayers.NONE:
		# Убираем индекс клетки с текущим ходом из списка пустых
		aEmptyCells.erase(nId)
		# Меняем состояние клетки.
		aModel[nId] = eStepForPlayer
		# Отправляем объект команды в медиатор или удалённому пользователю.
		# Составляем словарь с камандой.
		# шаблон команды
		var command = Global.createCommandNextStep()
		# Индекс клетки
		command.id = nId
		# Победитель
		command.player = eStepForPlayer
		# Отправляем команду подписавшимся объектам на обработку
		emit_signal("changState", command)
		
		print("set step player> ", eStepForPlayer, " id>", nId)
		# Проверяем условие для игрового события обусловленного правилами.
		# Проверка установки "3 в ряд"
		var IDPos = Vector2(nId % c_nColumns, nId / c_nColumns)
		print("check point > ", IDPos)
		# Вертикальная
		_processMatch(_getMatchArrays(_getColArray(IDPos)))
		# Горизонтальная
		_processMatch(_getMatchArrays(_getRowArray(IDPos)))
		# Наискось ВЛ-ПН
		_processMatch(_getMatchArrays(_getLTRBArray(IDPos)))
		# Наискось НЛ-ПВ
		_processMatch(_getMatchArrays(_getLBRTArray(IDPos)))
		print("state1 > ", eStepForPlayer)
		# Игра не завершена
		if eStepForPlayer != Global.EPlayers.NONE:
			# Ничья, ходов больше нет
			if aEmptyCells.empty():
				# шаблон команды
				var commandLose = Global.createCommandFinal()
				# Победитель
				commandLose.player = Global.EPlayers.NONE
				# Отправляем команду подписавшимся объектам на обработку
				emit_signal("changState", commandLose)
				eStepForPlayer = Global.EPlayers.NONE
				print("final none")
				return
			# Смена хода
			eStepForPlayer = Global.EPlayers.PLAYER1 if eStepForPlayer == Global.EPlayers.PLAYER2 else Global.EPlayers.PLAYER2
			print("state2 > ", eStepForPlayer)
			# Ход от имени игровой логики если есть пустые клетки
			if eStepForPlayer == Global.EPlayers.PLAYER2:
				print("state3 > ", eStepForPlayer)
				print("rand > ", randi())
				print("aEmptyCells > ", aEmptyCells)
				var pos = aEmptyCells[randi() % aEmptyCells.size()]
				print("game step idx > ", pos)
				_processNextStep(aEmptyCells[randi() % aEmptyCells.size()])

# Обработка события клика по клетке
func onCellClick(nId:int):
	if eStepForPlayer != Global.EPlayers.NONE:
		print(aModel[nId], nId)
		_processNextStep(nId)