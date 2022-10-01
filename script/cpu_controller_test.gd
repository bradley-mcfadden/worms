extends Node2D


var commands := ["curl", "straighten_out"]
var idx := 0

func _ready():
	$SpawnKinematic.set_active_controller($CpuController)
	$CpuController.call(commands[0])


func _on_command_finished():
	print("command finished")
	idx = (idx + 1) % len(commands)
	if idx < len(commands): 
		if commands[idx] == 'curl':
			$CpuController.curl('left', len($SpawnKinematic.body)/10.0 + 1)
		else:
			$CpuController.call(commands[idx])
