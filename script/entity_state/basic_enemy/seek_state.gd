#
# BasicEnemySeekState will make the AI go to a particular location.
# Upon seeing an enemy, it will go into a chase state.
# Upon reaching the location, it will go into search state.
#
extends EntityState

class_name BasicEnemySeekState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "SeekState"
const PROPERTIES := {
	color = Color.blueviolet,
	speed = 500,
	threshold = 32,
	fov = 90,
}

var target: Vector2
var walk_anim := "walk"
var idle_anim := "idle"
var noise_location = null # Vector2, usually


func _init(_fsm: Fsm, _entity: Node, _target: Vector2) -> void:
    fsm = _fsm
    entity = _entity
    target = _target


func on_enter() -> void:
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"


func _physics_process(delta: float) -> void:
    var player = entity.check_for_player()
    if player != null:
        if entity.has_ranged_attack or entity.has_melee_attack:
            fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
        else:
            fsm.replace(BasicEnemyStateLoader.fear(fsm, entity))
        return
    if noise_location != null:
        fsm.replace(BasicEnemyStateLoader.seek(fsm, entity, noise_location))
        print("Going to chase noise!")
        return
    entity.set_target(target)
    var ss = entity.set_interest()
    if ss == SeekState.SEEK_TARGET:
        if entity.animation_player.current_animation != walk_anim:
            entity.animation_player.play(walk_anim)
    else:
        if entity.animation_player.current_animation != idle_anim:
            entity.animation_player.play(idle_anim)
            fsm.replace(BasicEnemySearchState.new(fsm, entity))
            return

    entity.set_danger()
    entity.choose_direction()
    entity.move(delta)


func on_exit() -> void:
	pass


func on_noise_heard(position: Vector2) -> void:
    print("SearchState heard a noise")
    noise_location = position