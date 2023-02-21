# cpu_controller_test.gd 
# A small script that tests the movement of cpu_controller.gd.
# It loops between the curl and straighten_out commands.
# It should be visually inspected to make sure that the movement
# looks OK.

extends Node2D

# Movement commands to rotate through
var commands := ["curl", "straighten_out"]
var idx := 0

func _ready() -> void:
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
