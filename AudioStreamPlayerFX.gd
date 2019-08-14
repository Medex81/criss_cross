extends AudioStreamPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func procc_command(command, sender):
	if sender != self:
		print(">> ", command)
		var audio = get_parent().get_node("AudioStreamPlayerFX")
		if audio:
			match  command.cmd_type:
				Global.ECMDType.NEXT_STEP:
					audio.stream = load(Global.PATH_TO_SOUNDFX + "next-step.wav")
					audio.play()
				Global.ECMDType.FINAL:
					match command.player:
						Global.EPlayers.PLAYER1:
							audio.stream = load(Global.PATH_TO_SOUNDFX + "win.wav")
							audio.play()
						Global.EPlayers.PLAYER2:
							audio.stream = load(Global.PATH_TO_SOUNDFX + "lose.wav")
							audio.play()