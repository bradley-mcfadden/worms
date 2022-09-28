extends Node


class_name WormController


onready var curr_action_map := {
	"move_forward" : false,
	"move_left" : false,
	"move_right" : false,
	"peek_layer_up" : false,
	"peek_layer_down" : false,
	"layer_up" : false,
	"layer_down" : false,
}
onready var last_action_map := {
	"move_forward" : false,
	"move_left" : false,
	"move_right" : false,
	"peek_layer_up" : false,
	"peek_layer_down" : false,
	"layer_up" : false,
	"layer_down" : false,
}


func set_abilities_count(count: int):
	# set_abilities_count creates actions for ability1..abilityn
	for i in range(count):
		var idx := "ability" + str(i + 1)
		curr_action_map[idx] = false
		last_action_map[idx] = false 


func is_action_pressed(action: String) -> bool:
	# is_action_pressed return true if action is currently pressed
	return curr_action_map.has(action) && curr_action_map[action] == true


func is_action_just_released(action: String) -> bool:
	# is_action_just_released returns true if action was true, and is now false
	if not curr_action_map.has(action):
		return false
	
	var curr_action: bool = curr_action_map[action]
	var last_action: bool = last_action_map[action]

	return last_action && (not curr_action)


func is_action_just_pressed(action: String) -> bool:
	# is_action_just_released returns true if action was false, and is now true
	if not curr_action_map.has(action):
		return false
	
	var curr_action: bool = curr_action_map[action]
	var last_action: bool = last_action_map[action]

	return (not last_action) && (curr_action)