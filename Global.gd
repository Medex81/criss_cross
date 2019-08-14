extends Node

# Идентификаторы состояний объекта
enum EPlayers{ NONE, PLAYER1, PLAYER2 }
enum ECMDType { NEXT_STEP, FINAL, READY }
const c_cmdProtocolVersion = 1
const MANAGE_GAME_SCENE = "manage_game_scene"
const MANAGE_GAME_SCENE_FUNC = "procc_command"
const PATH_TO_SOUNDFX = "res://Assets/soundFX/"

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

func sendCommand(command, sender):
	get_tree().call_group(Global.MANAGE_GAME_SCENE, Global.MANAGE_GAME_SCENE_FUNC, command, sender)

# =================== Команды управления =============================
func createCommandNextStep():
	var command = {
		"protocol": c_cmdProtocolVersion,
		"cmd_type": ECMDType.NEXT_STEP,
		"id": -1,
		"player": EPlayers.NONE
	}
	return command
	
func createCommandFinal():
	var command = {
		"protocol": c_cmdProtocolVersion,
		"cmd_type": ECMDType.FINAL,
		"player": EPlayers.NONE,
		"arr_idx": []
	}
	return command
	
func createCommandReady():
	var command = {
		"protocol": c_cmdProtocolVersion,
		"cmd_type": ECMDType.READY
	}
	return command
# ===================================================================
# 	Переключатель сцен
var current_scene = null

func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

    call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
    # Immediately free the current scene,
    # there is no risk here.
    current_scene.free()

    # Load new scene.
    var s = ResourceLoader.load(path)

    # Instance the new scene.
    current_scene = s.instance()

    # Add it to the active scene, as child of root.
    get_tree().get_root().add_child(current_scene)

    # Optional, to make it compatible with the SceneTree.change_scene() API.
    get_tree().set_current_scene(current_scene)

