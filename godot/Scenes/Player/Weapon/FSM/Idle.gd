extends "res://Scenes/Player/Weapon/FSM/FSMWeaponStateBase.gd"

func _process(delta):
	get_fsm().get_fsm_holder().charge_amount -= 3.0 * delta
	
func pull_trigger():
	.pull_trigger()
	get_fsm().switch_to_state("Charging")
	
func release_trigger():
	.release_trigger()
