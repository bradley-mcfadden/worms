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
    apply_show_splash_startup()
    apply_particle_effects()
    apply_show_enemy_blood_effects()
    apply_show_enemy_blood_effects()


func apply_use_text_animations() -> void:
    pass


func apply_show_splash_startup() -> void:
    pass


func apply_particle_effects() -> void:
    pass


func apply_show_enemy_blood_effects() -> void:
    pass


func apply_show_player_blood_effects() -> void:
    pass