extends Area

export var target_flow_offset = 0.0


func _on_WormMovementTrigger_body_entered(body):
	if body.is_in_group("PLAYER"):
		print("worm movement triggered set to ", target_flow_offset)
		Globals.worm.target_flow_offset = target_flow_offset
