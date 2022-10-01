extends WormController


signal command_finished


func set_action(action: String, value: bool):
    if not last_action_map.has(action): return
    last_action_map[action] = curr_action_map[action]
    curr_action_map[action] = value


func curl(direction: String = "left", duration: float = 4.0):
    var action: String
    if direction == 'left':
        action = 'move_left'
    elif direction == 'right':
        action = 'move_right'
    else:
        emit_signal("command_finished")

    set_action("move_forward", true)
    # yield(get_tree().create_timer(50.0), "timeout")
    var total_time = 0.0
    var last = 0
    var time = 0.5
    while (total_time < duration):
        set_action(action, last % 2 == 0)
        var itime = 0.1 if last % 2 == 0 else time
        time -= 0.018
        time = max(0.0, time)
        yield(get_tree().create_timer(itime), "timeout")
        total_time += itime
        last += 1
    set_action("move_forward", false)
    set_action(action, false)
    emit_signal("command_finished")


func straighten_out(duration: float = 3.2):
    set_action("move_forward", true)
    yield(get_tree().create_timer(duration), "timeout")
    set_action("move_forward", false)
    emit_signal("command_finished")
