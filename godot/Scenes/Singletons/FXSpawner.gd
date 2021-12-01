extends Spatial

func spawn(name: String, position: Vector3, flow_along_curve: bool):
	var placeholder: InstancePlaceholder = get_node(name)
	var instance = placeholder.create_instance()
	
	#var instance = effects[name].duplicate() # NOTE - bug in godot: duplicating scenes does NOT duplicate any resources it uses
	# EVEN if they are local_to_scene! See https://github.com/godotengine/godot-proposals/issues/317
	
	# NOTE - calling InstancePlaceholder.create_instance already adds it to the node tree! 
	# So we gotta remove it first...
	remove_child(instance) 
	# ...then add it back to the level (so it gets destroyed when we move to another level)
	Globals.level_root.add_child(instance) 
	
	instance.global_transform.origin = position
	
	if flow_along_curve:
		instance.add_child(preload("res://Scenes/Worm/FlowAlongCurve.tscn").instance())
	
	return instance
