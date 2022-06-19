extends Node

signal all_enemies_dead()

func get_players() -> Array:
	return get_parent().get_players()


func _on_Enemy_died(node, from, overkill):
	node.queue_free()
	# add a corpse or something
	if get_child_count() == 0:
		emit_signal("all_enemies_dead")
