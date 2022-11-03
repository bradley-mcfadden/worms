#
# settings_graphics.gd
# Submenu of settings that handles graphics settings.
#

extends SettingsScrollContainer


func _ready() -> void:
    _init_values()
    _init_connections()


func _init_values() -> void:
    pass


func _init_connections() -> void:
    var buttons := [
        $Cols/R/Borderless,
        $Cols/R/Fullscreen,
        $Cols/R/ScaleViewportToWindow,
        $Cols/R/Resolution,
        $Cols/R/WindowSize
    ]
    for btn in buttons:
        btn.connect("focus_entered", self, "_on_control_focus_entered")
        btn.connect("focus_exited", self, "_on_control_focus_exited")
        btn.connect("pressed", self, "_on_button_pressed")

    var option_btns := [
        $Cols/R/Resolution,
        $Cols/R/WindowSize
    ]
    for btn in option_btns:
        btn.connect("item_focused", self, "_on_control_focus_entered")
        btn.connect("item_selected", self, "_on_button_toggled", true)


func _on_ScaleViewportToWindow_toggled(button_pressed: bool) -> void:
	pass # Replace with function body.


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	pass # Replace with function body.


func _on_Borderless_toggled(button_pressed: bool) -> void:
	pass # Replace with function body.


func _on_WindowSize_item_selected(index: int) -> void:
	pass # Replace with function body.


func _on_Resolution_item_selected(index: int) -> void:
	pass # Replace with function body.
