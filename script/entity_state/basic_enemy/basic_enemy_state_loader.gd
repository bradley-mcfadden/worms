# BasicEnemyStateLoader is a class that loads AI states at runtime. This is required
# to avoid circular dependencies without using a SceneTree.
extends Object

class_name BasicEnemyStateLoader


static func chase(fsm: Fsm, entity: Node) -> Object:
# chase returns an instance of chase_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a chase_state.gd instance
	return load("res://script/entity_state/basic_enemy/chase_state.gd").new(fsm, entity)


static func dead(fsm: Fsm, entity: Node) -> Object:
# dead returns an instance of dead_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a dead_state.gd instance
	return load("res://script/entity_state/basic_enemy/dead_state.gd").new(fsm, entity)


static func melee_attack(fsm: Fsm, entity: Node) -> Object:
# melee_attack returns an instance of melee_attack_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a melee_attack-state.gd instance
	return load("res://script/entity_state/basic_enemy/melee_attack_state.gd").new(fsm, entity)


static func ranged_attack(fsm: Fsm, entity: Node) -> Object:
# ranged_attack returns an instance of ranged_attack_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a ranged_attack_state.gd instance
	return load("res://script/entity_state/basic_enemy/ranged_attack_state.gd").new(fsm, entity)


static func patrol(fsm: Fsm, entity: Node) -> Object:
# patrol returns an instance of patrol_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a patrol_state.gd instance
	return load("res://script/entity_state/basic_enemy/patrol_state.gd").new(fsm, entity)


static func search(fsm: Fsm, entity: Node) -> Object:
# search returns an instance of search_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a search_state.gd instance
	return load("res://script/entity_state/basic_enemy/search_state.gd").new(fsm, entity)


static func seek(fsm, entity, position):
# chase returns an instance of chase_state.gd
# fsm - FSM to provide the new state
# entity - Entity controlled by FSM
# return a chase_state.gd instance
	return load("res://script/entity_state/basic_enemy/seek_state.gd").new(fsm, entity, position)
