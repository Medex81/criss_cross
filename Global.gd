extends Node

# Идентификаторы состояний объекта
enum EPlayers{ NONE, PLAYER1, PLAYER2 }
enum ECMDType { NEXT_STEP, FINAL }
const c_cmdProtocolVersion = 1

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

