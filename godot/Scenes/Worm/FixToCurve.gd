extends Spatial

export(int) var cell_x = 0
export(int) var cell_y = 0
export var align_to_tangent = false

onready var target = get_parent()
# This causes the parent object to go along with the worm at a fixed cell in the tilemap

func _physics_process(delta):
	fix_to_curve(delta)
		

func fix_to_curve(delta):
	
	var worm = Globals.worm
	
	if !worm:
		print("warning: FixToCurve can't find worm")
		return
	
	var cell_curve_pos_and_tangent = PathRasterizer.lookup_cell_pos_and_tangent(cell_x, cell_y)
	
	if cell_curve_pos_and_tangent == null:
		print("warning: invalid cell pos: ", cell_x, ", ", cell_y)
		return

	var cell_curve_pos = cell_curve_pos_and_tangent[0]

	target.global_transform.origin.x = cell_curve_pos.x
	target.global_transform.origin.y = cell_curve_pos.y
	target.global_transform.origin.z = 0.0
	
	if align_to_tangent:
		
		# Rotate so Y aligns with the curve's tangent
		
		var local_up = target.global_transform.basis.y.normalized()
		var target_up = Vector3(cell_curve_pos_and_tangent[1].x, cell_curve_pos_and_tangent[1].y, 0.0)
		
		var align_speed = 10
		
		var up_diff = local_up.cross(target_up)
		var up_diff_len = up_diff.length()
		if up_diff_len > 1e-5:
			target.global_rotate(up_diff / up_diff_len, up_diff_len * clamp(align_speed * delta, 0.0, 1.0))
	
