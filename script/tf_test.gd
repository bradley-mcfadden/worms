# tf_test.gd contains the topmost code for a level.

extends Node2D

export(PackedScene) var eggs

# var death_screen: Node
# var enemies_dead_screen: Node
onready var primary_player: Node
onready var depth_manager: Node = $DepthManager
onready var ui: Node = $UI
onready var elapsed_time := 0.0
onready var count_elapsed_time := true

func _ready() -> void:
	$Music.play()
	depth_manager.add_items($Players.get_players())
	depth_manager.add_items($Enemies.get_enemies())
	depth_manager.add_items($Obstacles.get_obstacles())
	depth_manager.add_items($Decorations.get_decorations())
	depth_manager.add_items($Interactibles.get_interactibles())
	var portals := $Portals.get_children()
	for portal in portals:
		var _res: int = depth_manager.connect("layer_changed", portal, "_on_DepthManager_layer_changed")
		_res = depth_manager.connect("layer_peeked", portal, "_on_DepthManager_layer_changed")
	depth_manager.add_items(portals)
	depth_manager.set_current_layer(0)
	var enemies := $Enemies.get_children()
	for enemy in enemies:
		var _res: int = enemy.connect("noise_produced", $NoiseManager, "_on_noise_produced")
		_res = enemy.connect("bullet_created", self, "attach_bullet")
	$NoiseManager.listeners.append_array(enemies)
	$Background.set_layer(0)
	$Enemies.paths = $Paths
	# $CanvasLayer/DepthGauge.change_depth(0)
	# death_screen = $CanvasLayer/DeathScreen
	# enemies_dead_screen = $CanvasLayer/AllEnemiesDead
	primary_player = $Players/SpawnKinematic
	primary_player.background = $Background

	$UI.fade_in()
	_init_connections()
	primary_player.emit_signals_first_time()
	primary_player.set_dirt_color($Background.sample_colors(16))
	_init_player_skin()


func _init_player_skin() -> void:
	var current_skin_name: String = PlayerSave.save_data[PlayerSave.KEY_CURRENT_SKIN]
	var player_skin := Skins.skin_by_name(current_skin_name)
	var skin_material: Resource = load(player_skin["material"])
	primary_player.material = skin_material


func _init_connections() -> void:
	var _err := $Enemies.connect("all_enemies_dead", self, "_on_all_enemies_dead")
	_err = $Players.connect("all_players_dead", self, "_on_all_players_dead")
	_err = ui.get_node("DeathScreen").connect("restart", self, "_on_restart")
	_err = ui.get_node("AllEnemiesDead").connect("lay_eggs", self, "_on_lay_eggs")
	_err = $DepthManager.connect("layer_changed", $Background, "_on_layer_changed")
	var ability_display := ui.get_node("AbilitiesDisplay")
	_err = primary_player.connect("abilities_ready", ability_display, "_on_abilities_ready")
	_err = primary_player.connect("ability_is_ready_changed", ability_display, "_on_ability_is_ready_changed")
	_err = primary_player.connect("ability_is_ready_changed_cd", ability_display, "_on_ability_is_ready_changed_cd")
	_err = primary_player.connect("died", $Players, "_on_Player_died")
	_err = primary_player.connect("health_state_changed", $Music, "_on_health_state_changed")
	_err = primary_player.connect("health_state_changed", ui.get_node("NearDeathBorder"), "_on_health_state_changed")
	_err = primary_player.connect("layer_visibility_changed", depth_manager, "_on_layer_visibility_changed")
	_err = primary_player.connect("noise_produced", $NoiseManager, "_on_noise_produced")
	_err = primary_player.connect("segment_changed", depth_manager, "_on_segment_changed")
	_err = primary_player.connect("switch_layer_pressed", depth_manager, "_on_switch_layer_pressed")
	var health_bar := ui.get_node("HealthBar")
	_err = primary_player.connect("segment_took_damage", health_bar, "_on_Segment_took_damage")
	_err = primary_player.connect("size_changed", health_bar, "_on_Worm_size_changed")
	_err = primary_player.connect("died", health_bar, "_on_Worm_died")

	ui.connect_to_dm(depth_manager)


func _process(delta: float) -> void:
	update()
	if count_elapsed_time:
		elapsed_time += delta


func get_players() -> Array:
	return $Players.get_players()


func attach_bullet(bullet: Node) -> void:
# 
# attach_bullet adds the current bullet as a child of the scene.
# bullet to make a child of this scene.
#
	add_child(bullet)
	var _ret = bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
	depth_manager.add(bullet.get_layer(), bullet)


func reset() -> void:
#
# reset the current scene to its initial state.
#
	count_elapsed_time = true
	elapsed_time = 0.0

	ui.reset()
	$Enemies.reset_all_enemies()
	$Players.reset_all_players()
	$Music.play()
	$Interactibles.reset()
	$Obstacles.reset()


func get_current_camera_2d() -> Camera2D:
#
# get_current_camera_2d returns the current active camera.
# returns - Current active camera in scene.
#
	var viewport = get_viewport()
	if not viewport:
		return null
	var cameras_group_name = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(cameras_group_name)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null


func _on_lay_eggs() -> void:
	# write elapsed time to the save file
	var level_idx := Levels.level_idx
	var level_progress: Dictionary = PlayerSave.save_data[PlayerSave.KEY_LEVEL_PROGRESS][level_idx]
	var previous_time: float = level_progress[PlayerSave.KEY_LEVEL_TIME]
	if elapsed_time < previous_time or previous_time < 0:
		level_progress[PlayerSave.KEY_LEVEL_TIME] = elapsed_time
		var _ret := PlayerSave.update_level_progress(level_idx, level_progress)
	# write current index as "highest level completed"
	var prev_highest_level: int = PlayerSave.save_data[PlayerSave.KEY_HIGHEST_LEVEL]
	if level_idx > prev_highest_level:
		var _ret := PlayerSave.set_highest_level_completed(level_idx)

	$Music.playing = false
	# enemies_dead_screen.visible = false
	var cpu_con = $CpuController
	var worm = primary_player
	worm.set_active_controller(cpu_con)
	cpu_con.straighten_out(len(worm.body)*0.1+0.2)
	yield(cpu_con, "command_finished")
	cpu_con.curl("left", len(worm.body)*0.1+1.0)
	yield(cpu_con, "command_finished")
	var egg_ins = eggs.instance()
	worm.add_child(egg_ins)
	worm.move_child(egg_ins, 0)
	egg_ins.global_position = worm.wide_camera.global_position
	$LayEggs.play()
	yield(egg_ins, "animation_finished")
	Levels.next_level_or_main()
	$UI.fade_out()


func _on_all_enemies_dead() -> void:
	count_elapsed_time = false
	ui._on_all_enemies_dead()


func _on_all_players_dead() -> void:
	count_elapsed_time = false
	$Music.playing = false
	ui._on_all_players_dead()
	# death_screen.visible = true
	# death_screen.fade_in()


func _on_bullet_destroyed(bullet: Node) -> void:
	depth_manager.remove(bullet)


func _on_restart() -> void:
	reset()
