extends WormController


func _input(event: InputEvent):
	for action in curr_action_map.keys():
		if event.is_action_pressed(action):
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = true
		else:
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = false


func _physics_process(_delta: float):
	for action in curr_action_map.keys():
		if Input.is_action_pressed(action):
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = true
		else:
			last_action_map[action] = curr_action_map[action]
			curr_action_map[action] = false