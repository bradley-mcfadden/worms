# blood_explode.gd
# Script attached to a CPUParticles2D, allowing the
# color of its particles to be changed more easily.s

tool 
extends CPUParticles2D

export(Color) var gore_color setget set_gore_color


func set_gore_color(col: Color) -> void:
#
# set_gore_color
# col - Color to update the particle start color to.
#
	color = col
	gore_color = col
