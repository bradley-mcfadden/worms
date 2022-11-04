# 
# GeneralConfigLoader
# Responsible for applying the Configuration values in the "general"
# section of Configurations.sections.
#

extends Node


var gconfig: Dictionary


func _enter_tree() -> void:
    gconfig = Configuration.sections["general"]
    apply_use_text_animations()


func apply_use_text_animations() -> void:
    pass