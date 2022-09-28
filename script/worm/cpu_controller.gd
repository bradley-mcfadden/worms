extends WormController


func set_action(action: String, value: bool):
    if not last_action_map.has(action): return
    last_action_map[action] = curr_action_map[action]
    curr_action_map[action] = value
    