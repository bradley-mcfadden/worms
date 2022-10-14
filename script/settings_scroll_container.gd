#
# settings_scroll_container.gd
# Provides signals for common UI actions of submenus of settings. 
#

extends ScrollContainer


class_name SettingsScrollContainer


signal button_pressed
signal button_focus_in
signal button_focus_out
signal slider_handle_moved
signal button_enabled
signal button_disabled