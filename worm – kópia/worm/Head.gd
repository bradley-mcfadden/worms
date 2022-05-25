extends "res://worm/segment.gd"

var anim_player:AnimationPlayer

const IDLE = "idle"
const MOUTH_CHOMP = "mouth_chomp"
const MOUTH_OPEN_WIDE = "mouth_open_wide"
const CHOMP_TO_IDLE = "chomp_to_idle"


func _ready():
	anim_player = $AnimationPlayer
	anim_player.play(IDLE)
