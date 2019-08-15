extends Control

# Объект "клетка".
# Реагирует на физические воздействия объектов своего или нижнего уровня меняя состояние и отображение.
# Уведомляет о своём состоянии или событиях происходящих с ней объект более высокого уровня.
# Может иметь автономную логику поведения в рамках установленных объектом более высокого уровня.

# Числовой идетнификатор объекта.
var id = 0
var bForceFrame = false

# Идентификаторы состояний объекта
enum { NONE, CRIST, ZERO}
# Текущее состояние объекта, по умолчанию первое.
var eState = NONE
# Список строк для установки в объект в зависимости от состояния
var aOutput_str = ["", "X", "O"]

# Сигналы о событиях происходящих с объектом.
# Клик по объекту, передаём идентификатор объекта
signal clicked(cell_id)

# Инициализация объекта после подключения к дереву.
func _ready():
	setState(eState)
	
# Установка нового состояния объекта	
func setState(new_state):
	# Устанавливаем наборы свойств объекта характерные для устанавливаемого состояния.
	eState = new_state
	match eState:
		NONE:
			$Label.text = aOutput_str[NONE]
		CRIST:
			$Label.text = aOutput_str[CRIST]
		ZERO:
			$Label.text = aOutput_str[ZERO]
			
# Венуть состояние объекта.
func getState():
	return eState

# События ввода пользователя.
func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal( "clicked", id )
		$AnimationPlayer.play("cell_click")

func _on_Control_mouse_entered():
	if !bForceFrame:
		$NinePatchRectSel.visible = true

func _on_Control_mouse_exited():
	if !bForceFrame:
		$NinePatchRectSel.visible = false
	
func setForceFrame(frameState):
	bForceFrame = frameState
	$NinePatchRectSel.visible = bForceFrame
