#
# egg_collectible.gd is an interactible that styles
# itself after a named skin and unlocks that skin
# when the player runs into it.
#
extends Area2D


class_name EggCollectible, "res://icons/egg.svg"


export (int) var layer := 0
export (String) var unlocks_skin := "classic"
export (String) var unlock_name := "egg_classic"


func _ready() -> void:
	apply_style()


func apply_style() -> void:
	var skin_data := Skins.skin_by_name(unlocks_skin)
	if skin_data.empty(): 
		return
	var skin_material: Resource = load(skin_data.material)
	material = skin_material


func reset() -> void:
	modulate = Color.white
	visible = true


func _on_hide(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.1)
	$Tween.start()


func _on_show(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.1)
	$Tween.start()


func _on_EggCollectible_body_entered(body):
	if body.has_method("is_alive") and body.is_alive():
		collect_skin()


func collect_skin() -> void:
	$Collected.play()
	visible = false
	# write name of skin to player save file
	var _ret := PlayerSave.add_collectible(unlock_name)
	var level_idx := Levels.level_idx
	var level_progress: Dictionary = PlayerSave.save_data[PlayerSave.KEY_LEVEL_PROGRESS][level_idx]
	level_progress[PlayerSave.KEY_LEVEL_COLLECTED].append(unlock_name)
	_ret = PlayerSave.update_level_progress(level_idx, level_progress)
	_on_hide(layer)
	yield($Tween, "tween_completed")
	visible = false
