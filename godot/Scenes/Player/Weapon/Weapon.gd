extends Spatial

export(NodePath) var chargingcircle_path
var charge_amount = 0.0 setget set_charge_amount, get_charge_amount

onready var fsm = $FSM

func set_charge_amount(value):
	charge_amount = clamp(value, 0.0, 1.0)
	
func get_charge_amount():
	return charge_amount

func _process(_delta):
	var chargingcircle = get_node(chargingcircle_path)
	chargingcircle.circle_progress = charge_amount

func pull_trigger():
	fsm.call_on_state("pull_trigger")
	
func release_trigger():
	fsm.call_on_state("release_trigger")
	
