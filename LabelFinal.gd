extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# При завершении игры делаем кнопку старта активной
func procc_command(command, sender):
	if sender != self:
		print(">> ", command)
		match  command.cmd_type:
			Global.ECMDType.FINAL:
				visible = true
				match command.player:
					Global.EPlayers.PLAYER1:
						text = "WIN"
						get_node("../AnimationPlayer").play("final_label")
						$"../Particles2DFirework".set_emitting(true)
						$"../Particles2DFirework".restart()
					Global.EPlayers.PLAYER2:
						text = "LOSE"
						get_node("../AnimationPlayer").play("final_label")
			Global.ECMDType.READY:
				visible = false
