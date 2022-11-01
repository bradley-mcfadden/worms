# MIT License
# 
# Copyright (c) 2019 Ben Bishop
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# godot_credits.gd
#
# This script provides a scrolling credits screen. It's a bit basic right now
# and should have some extra flair on the side. 

extends Control

const section_time := 2.0
const line_time := 0.3
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color("#ff8a8a")
var subtitle_color := Color("#ff6161")

var scroll_speed := base_speed
var speed_up := false

onready var line := $CreditsContainer/Line
var started := false
var finished := false

var next_is_header := false
var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"frenzy",
		"A game by Bradley McFaddem"
	],[
		"Programming",
		"Bradley McFadden",
		"",
		"Original worm controller code based on",
		"https://github.com/mlokogrgel1/worm/tree/master/worm%20–%20kópia/worm",
		"",
		"Credits code based on",
		"Ben Bishop",
		"https://github.com/benbishopnz/godot-credits"
	],[
		"Art"
		"",
		"Sprites, models, backgrounds",
		"Bradley McFadden",
		""
		"Handdrawn art",
		"Rhys",
		"",
		"Moss texture",
		"Jeremy Bishop",
		"https://unsplash.com/photos/9UOF4oliKUY",
	],[
		"Music",
		"Bradley McFadden"
	],[
		"Sound Effects",
		"Bradley McFadden",
		"",
		"Gunshot sound",
		"https://freesound.org/people/andrest2003/sounds/524912/",
		"",
		"Knife slash sound",
		"https://freesound.org/people/Anthousai/sounds/336586/",
		"",
		"Grunt sound",
		"https://freesound.org/people/punisherman/sounds/370036/",
		"",
		"Gib sound",
		"https://freesound.org/people/Rock%20Savage/sounds/81042/"
	],[
		"Play testers",
		"Demitrius",
		"Rhys",
		"Celine",
		"Raphy",
		"Neil"
	],[
		"Tools used",
		"",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Models created with Blender",
		"https://www.blender.org",
		"",
		"Pixel art created with Aseprite",
		"https://www.aseprite.org",
		"",
		"Sound effects generated using LabChirp",
		"http://labbed.net/software/labchirp/",
		"",
		"Music created using JuumBox and LMMS",
		"https://jummbus.bitbucket.io/",
		"https://lmms.io/"
		"",
		"Image manipulation with GIMP",
		"https://www.gimp.org/",
		"",
		"Spritesheets packed using TexturePackerPro",
		"https://www.codeandweb.com/texturepacker",
		"",
		"Terrain textures generated with Poly",
		"https://withpoly.com"
	],[
		"Special thanks",
		"My beautiful cat, Sylvester",
		"My supportive girlfriend Celine",
		"Each and every one of my friends <3"
	]
]


func _process(delta: float) -> void:
	var scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= scroll_speed
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish() -> void:
	if not finished:
		finished = true
		var _r = get_tree().change_scene("res://scene/TitleScreen.tscn")


func add_line() -> void:
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if next_is_header:
		new_line.add_color_override("font_color", subtitle_color)
		next_is_header = false
	if curr_line == 0:
		new_line.add_color_override("font_color", title_color)
	if new_line.text == "":
		next_is_header = true
	new_line.visible = true
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
