extends Node2D

export var level_tilemap_number = -1
export var tilemap_layer_name = "Tile Layer 1"
export var object_layer_name = "Object Layer 1"

var tilemap

func _ready():
	
	flip_path_control_points($WormPath)
	
	var tilemap_base = LevelTilemaps.get_level_tilemap_base(level_tilemap_number)
	tilemap = tilemap_base.get_node(tilemap_layer_name)
	var objects = tilemap_base.get_node(object_layer_name)
	
	$Worm.setup(tilemap)
	process_object_layer(objects) # Note: call worm.setup() first
	
func flip_path_control_points(wormpath: Path2D): 
	
	# This is needed since 2D and 3D have flipped Y
	
	var curve = wormpath.curve
	if !curve.resource_local_to_scene:
		print("WARNING! Curve resource is NOT local to scene so it will be incorrectly flipped multiple times!")
		push_warning("WARNING! Curve resource is NOT local to scene so it will be incorrectly flipped multiple times!")
	
	var flip_vector = Vector2(1,-1)
	for i in curve.get_point_count():
		
		var pos = curve.get_point_position(i)
		var pos_in = curve.get_point_in(i)
		var pos_out = curve.get_point_out(i)
		
		curve.set_point_position(i, pos * flip_vector)
		curve.set_point_in(i, pos_in * flip_vector)
		curve.set_point_out(i, pos_out * flip_vector)

func process_object_layer(objects: Node2D):
	for object in objects.get_children():
	
		var pos_global = object.position
		var pos_cell = pos_global / float(tilemap.get_cell_size().x)
		
		var x = int(round(pos_cell.x))
		var y = int(round(pos_cell.y))
		
		spawn_entity(object, x, y)
		
		#print(object, " properties: ")
		#var meta = object.get_meta_list()
		#for key in meta:
		#	print(key, " = ", object.get_meta(key))
		

func spawn_entity(object: Node2D, cell_x: int, cell_y: int):
	
	var meta_type = object.get_meta("type")
	var flow_along_curve = false
	var fix_to_curve = false
	var align_to_tangent = false
	var measure_curve_deviation = false
	var scene_to_instance
	
	match meta_type:
		"player":
			scene_to_instance = preload("res://Scenes/Player/Player.tscn")
			flow_along_curve = true
			measure_curve_deviation = true
		"shard":
			scene_to_instance = preload("res://Scenes/Collectibles/Shard.tscn")
			fix_to_curve = true
		"brain":
			scene_to_instance = preload("res://Scenes/Enemy/Brain.tscn")
			fix_to_curve = true
			align_to_tangent = true
		"worm_movement_trigger":
			scene_to_instance = preload("res://Scenes/Worm/WormMovementTrigger.tscn")
			fix_to_curve = true
			align_to_tangent = true
		"dialogue_trigger":
			scene_to_instance = preload("res://Scenes/Triggers/DialogueTrigger.tscn")
			fix_to_curve = true
			align_to_tangent = true
		"enemy_roller":
			scene_to_instance = preload("res://Scenes/Enemy/Roller.tscn")
			flow_along_curve = true
		"enemy_redblock":
			scene_to_instance = preload("res://Scenes/Enemy/RedBlock.tscn")
			fix_to_curve = true
			align_to_tangent = true
		"enemy_brainshield":
			scene_to_instance = preload("res://Scenes/Enemy/BrainShield.tscn")
			fix_to_curve = true
		"control_hint":
			scene_to_instance = preload("res://Scenes/UI/ControlHint.tscn")
			fix_to_curve = true
			
	if scene_to_instance == null:
		print("warning - can't spawn unknown entity type ", meta_type)
		return
		
	var pos_and_tangent = PathRasterizer.lookup_cell_pos_and_tangent(cell_x,cell_y)
	var pos = pos_and_tangent[0]
	var instance = scene_to_instance.instance()
	
	# Set any auto-properties (anything that begins with "prop_" is automatically set)
	var meta = object.get_meta_list()
	for key in meta:
		if key.begins_with("prop_"):
			
			var propkey = key.replace("prop_", "")
			var value = object.get_meta(key)
			#print("set ", propkey, " = ", value)
			instance.set(propkey, value)
			
	add_child(instance)
	instance.global_transform.origin = Vector3(pos.x, pos.y, 0.0) # NOTE: although tilemap is 2D, spawned entities are 3D!
	

	
	# Apply fix_to_curve/flow_along_curve
	if fix_to_curve:
		var fix_to_curve_instance = preload("res://Scenes/Worm/FixToCurve.tscn").instance()
		fix_to_curve_instance.cell_x = cell_x
		fix_to_curve_instance.cell_y = cell_y
		fix_to_curve_instance.align_to_tangent = align_to_tangent
		instance.add_child(fix_to_curve_instance)
	elif flow_along_curve:
		var flow_along_curve_instance = preload("res://Scenes/Worm/FlowAlongCurve.tscn").instance()
		if measure_curve_deviation:
			flow_along_curve_instance.measure_curve_deviation = true
		instance.add_child(flow_along_curve_instance)
			
		
	if flow_along_curve && fix_to_curve:
		print("warning - entity can't both 'flow along curve' and 'fix to curve' simulatenously")
