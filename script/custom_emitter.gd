# 
# custom_emitter attempts to enforce the amount of particle effects applied
# by calculating the amount required to be emitted by the configuration
# (all/half/none) before running the particle system. 
#
extends CPUParticles2D


onready (int) var base_amount = amount 


func set_emitting(is_emitting: bool) -> void:
#
# set_emitting
# is_emitting - Should the particle system be emitting right now?
# An override for set_emitting that scales the amount of particles to
# be emitted.
#
    amount = base_amount * amount_factor
    .set_emitting(is_emitting)


func amount_factor() -> float:
#
# amount_factor
# return - Factor that particles should be multiplied by from Confiuration.
# (all/half/none) -> (1.0/0.5/0.0)
#
    var factor := 1.0
    match Configuration.sections.general.particle_effects:
        0: 
            factor = 1.0
            break
        1: 
            factor = 0.5
            break
        2: 
            factor = 0.0
            break
    return factor

    