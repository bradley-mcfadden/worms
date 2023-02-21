#
# InputLoader.gd is a singleton that acts as a bridge between
# Configuration and InputMap.
# Specifically, it loads the mappings specified in Configuration
# and applies them to the InputMap.
#

extends Node


func _enter_tree() -> void:
	load_mappings()


func load_mappings() -> void:
#
# load_mappings 
# This function takes the current control scheme as specified in Configuration,
# and creates InputEvents that are added to the input map for the scheme.
#
	# Get current control scheme
	var scheme: String = Configuration.sections["controls"]["current_scheme"]
	print("Load scheme %s" % scheme)
	# Get bindings for control scheme
	var bindings: Dictionary = Configuration.sections["controls"][scheme]

	for action in bindings.keys():
		var entry: Dictionary = bindings[action]
		var event: InputEvent = event_from_binding(entry)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		print("Add event %s for action %s" % [action, event])


func event_from_binding(entry: Dictionary) -> InputEvent:
#
# event_from_binding
# For a given Dictionary with keys:
# "type" : String
# "scancode" : int, # Keyboard scancode for event
# "control" : boolean, # Is control pressed?
# "shift" : boolean, # "Is shift pressed?"
# "alt" : boolean, # "Is alt pressed?"
# create a matching Inputevent, and return it.
#
	match entry["type"]:
		Configuration.CONTROL_KEY_TYPE:
			var event := InputEventKey.new()
			event.alt = entry["alt"]
			event.scancode = entry["scancode"]
			event.control = entry["ctrl"]
			event.shift = entry["shift"]
			event.device = 0
			return event
		_:
			print("Error, invalid event binding type")
			return InputEvent.new()


func input_event_to_config_entry(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var dict := {
			"type" : Configuration.CONTROL_KEY_TYPE,
			"scancode" : event.scancode,
			"shift" : event.shift,
			"alt" : event.alt,
			"ctrl" : event.control
		}
		return dict
	else:
		return {}


func string_from_event(event: InputEvent) -> String:
#
# string_from_event
# For the given InputEvent, return a nicely formatted text representation
# of what the input is.
#   
	if event is InputEventKey:
		var ctrl := "Ctrl+" if event.control else ""
		var alt := "Alt+" if event.alt else ""
		var shift := "Shift+" if event.shift else ""
		var sc_str := OS.get_scancode_string(event.scancode)
		return "%s%s%s%s" % [ctrl, alt, shift, sc_str]
	else:
		return "???"
