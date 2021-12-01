extends Spatial

export var flatten = true
export var measure_curve_deviation = false
var curve_deviation = 0 # How far the object is distantiated from the curve - only measured if measure_curve_deviation is true

onready var target = get_parent()
# This causes the parent object to flow along with the worm

func _physics_process(delta):
	go_with_the_flow(delta)
		

func go_with_the_flow(delta):
	
	var worm = Globals.worm
	
	if !worm:
		print("warning: FlowAlongCurve can't find worm")
		return
	
	var target_pos_2d = Vector2(target.global_transform.origin.x, target.global_transform.origin.y)
	
	var flow_speed = worm.flow_speed
	var dist_along_curve = worm.curve.get_closest_offset(worm.to_local(target_pos_2d))
	var closest_point_on_curve = worm.to_global(worm.curve.get_closest_point(worm.to_local(target_pos_2d)))
	var curve_tangent_diff = target_pos_2d - closest_point_on_curve
	
	var dist_along_curve_target = dist_along_curve + flow_speed * delta
	
	var new_pos_along_curve = worm.curve.interpolate_baked(dist_along_curve_target, true) # TODO is this global space???
	new_pos_along_curve += curve_tangent_diff # TODO using the same tangent as the previous frame = wrong right? 
	
	var new_pos_along_curve_diff = new_pos_along_curve - target_pos_2d
		
	# TODO this doesn't work with rigid bodies sadly
	target.global_transform.origin.x += new_pos_along_curve_diff.x
	target.global_transform.origin.y += new_pos_along_curve_diff.y
	
	if flatten:
		target.global_transform.origin.z = 0
	
	if measure_curve_deviation:
		curve_deviation = closest_point_on_curve.distance_to(target_pos_2d)
