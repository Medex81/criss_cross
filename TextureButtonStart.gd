extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# При завершении игры делаем кнопку старта активной
func procc_command(command, sender):
	if sender != self:
		print(">> ", command)
		match  command.cmd_type:
			Global.ECMDType.FINAL:
				disabled = false

# При старте игры делаем кнопку неактивной для запрета запуска следующей игры до завершения текущей 
func _on_TextureButtonStart_pressed():
	disabled = true
	game_logic.runGame()
