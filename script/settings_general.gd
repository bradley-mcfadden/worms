#
# settings_general.gd
# Submenu of settings that handles settings that don't fit in other categories.
#

extends SettingsScrollContainer


signal update_labels


func _ready() -> void:
	_init_values()
	_init_connections()


func _init_values() -> void:
	var gconfig: Dictionary = Configuration.sections.general

	$Cols/R/RichTextCheck.pressed = gconfig.use_text_animations
	$Cols/R/EnemyBloodstainEffectsButton.pressed = gconfig.show_enemy_blood_effects
	$Cols/R/ProgressivePlayerModelButton.pressed = gconfig.show_player_blood_effects
	$Cols/R/ParticleEffectsButton.selected = gconfig.particle_effects
	$Cols/R/ShowSplashesCheck.pressed = gconfig.show_splash_startup


func _init_connections() -> void:
	var check_buttons := [
		$Cols/R/RichTextCheck,
		$Cols/R/EnemyBloodstainEffectsButton,
		$Cols/R/ProgressivePlayerModelButton,
		$Cols/R/ParticleEffectsButton,
		$Cols/R/PlayerSaveButton,
	]
	for btn in check_buttons:
		btn.connect("toggled", self, "_on_button_toggled")
		btn.connect("focus_entered", self, "_on_control_focus_entered")
		btn.connect("focus_exited", self, "_on_control_focus_exited")


func _on_RichTextCheck_toggled(state: bool):
	Configuration.sections.general.use_text_animations = state
	GeneralConfigLoader.apply_use_text_animations()
	emit_signal("update_labels")


func _on_EnemyBloodstainEffectsButton_toggled(button_pressed: bool) -> void:
	Configuration.sections.general.show_enemy_blood_effects = button_pressed
	GeneralConfigLoader.apply_show_enemy_blood_effects()


func _on_ProgressivePlayerModelButton_toggled(button_pressed: bool) -> void:
	Configuration.sections.general.show_player_blood_effects = button_pressed
	GeneralConfigLoader.apply_show_player_blood_effects()


func _on_ParticleEffectsButton_item_selected(index: int) -> void:
	Configuration.sections.general.particle_effects = index
	GeneralConfigLoader.apply_particle_effects()


func _on_PlayerSaveButton_pressed() -> void:
	show_delete_save_confirm()


func show_delete_save_confirm() -> void:
	$ConfirmDialog.popup_with_message("Delete save data?", "Are you sure?")


func _on_ConfirmDialog_confirmed():
	PlayerSave.delete()
	get_tree().quit()
