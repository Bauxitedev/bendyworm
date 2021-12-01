extends "res://Scenes/Player/Weapon/FSM/FSMWeaponStateBase.gd"

	
func _process(delta):
	var fsm_holder = get_fsm().get_fsm_holder()
	fsm_holder.charge_amount +=  0.3 * delta
	
	if fsm_holder.charge_amount >= 1.0:
		get_fsm().switch_to_state("Shooting")
		set_process(false) # Prevents switching twice
	
func pull_trigger():
	.pull_trigger()
	
func release_trigger():
	.release_trigger()
	get_fsm().switch_to_state("Idle")


