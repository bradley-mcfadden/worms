#
# settings_general.gd
# Submenu of settings that handles settings that don't fit in other categories.
#

extends SettingsScrollContainer


signal update_labels


func _on_RichTextCheck_toggled(state: bool):
	Configuration.sections["general"]["use_text_animations"] = state
	emit_signal("update_labels")