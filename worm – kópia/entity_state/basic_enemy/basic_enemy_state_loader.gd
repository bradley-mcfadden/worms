extends Object

class_name BasicEnemyStateLoader


static func chase(fsm, entity):
    return load("res://entity_state/basic_enemy/chase_state.gd").new(fsm, entity)


static func dead(fsm, entity):
    # return BasicEnemyDeadState.new(fsm, entity)
    return load("res://entity_state/basic_enemy/dead_state.gd").new(fsm, entity)


static func melee_attack(fsm, entity):
    # return BasicEnemyMeleeAttackState.new(fsm, entity)
    return load("res://entity_state/basic_enemy/melee_attack_state.gd").new(fsm, entity)


static func ranged_attack(fsm, entity):
    # return BasicEnemyRangedAttackState.new(fsm, entity)
    return load("res://entity_state/basic_enemy/ranged_attack_state.gd").new(fsm, entity)


static func patrol(fsm, entity):
    # return BasicEnemyPatrolState.new(fsm, entity)
    return load("res://entity_state/basic_enemy/patrol_state.gd").new(fsm, entity)


static func search(fsm, entity):
    # return BasicEnemySearchState.new(fsm, entity)
    return load("res://entity_state/basic_enemy/search_state.gd").new(fsm, entity)