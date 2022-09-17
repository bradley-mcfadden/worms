tool 
extends CPUParticles2D



export(Color) var gore_color setget set_gore_color

func set_gore_color(col: Color):
	color = col
	gore_color = col
