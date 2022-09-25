# Boiler plate code for an entity state.
# Each of these fields and methods needs to be present in a class that
# extends EntityState.
# Depending on the entity, the properties keys can be swapped.
extends EntityState

class_name BasicEnemySeekState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "SeekState"
const PROPERTIES := {
	color = Color.blueviolet,
	speed = 350,
	threshold = 32,
	fov = 90,
}

var target: Vector2
var walk_anim := "walk_gun"
var idle_anim := "idle_gun"
var noise_location = null

func _init(_fsm, _entity, _target: Vector2):
    fsm = _fsm
    entity = _entity
    target = _target


# on_enter calls code once when switching to this state
func on_enter():
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"


# called every _physics_process in parent
func _physics_process(delta):
    var player = entity.check_for_player()
    if player != null:
        fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
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

    entity.set_danger()
    entity.choose_direction()
    entity.move(delta)


# on_exit is called when switching out of this state
func on_exit():
	pass


func on_noise_heard(position: Vector2):
    print("SearchState heard a noise")
    noise_location = position