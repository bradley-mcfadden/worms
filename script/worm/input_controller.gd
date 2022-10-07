#
# input_controller.gd is a standard controller for the worm that reads
# from the Input singleton to set the action states in the controller.
#

extends WormController


func _physics_process(_delta: float) -> void:
	for action in curr_action_map.keys():
		if Input.is_action_pressed(action):
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = true
		else:
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = false