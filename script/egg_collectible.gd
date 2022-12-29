#
# egg_collectible.gd is an interactible that styles
# itself after a named skin and unlocks that skin
# when the player runs into it.
#
extends Area2D


class_name EggCollectible, "res://icons/egg.svg"


export (int) var layer := 0
export (String) var unlocks_skin := "classic"


func _ready() -> void:
	apply_style()


func apply_style() -> void:
	var skin_data := Skins.skin_by_name(unlocks_skin)
	if skin_data.empty(): return
	material = load(skin_data["material"])


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