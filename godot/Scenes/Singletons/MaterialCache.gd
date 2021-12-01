extends Spatial

# This is needed to avoid shader compilation stutter, see https://www.youtube.com/watch?v=kbDj9V2MZvw
# And https://github.com/godotengine/godot/issues/13954#issuecomment-622950495

var particle_materials = [
	preload("res://Materials/Particles/CollectShard.tres"),
	preload("res://Materials/Particles/EnemyExplode.tres")
]

var spatial_materials = [
	preload("res://Materials/FX/CollectShardFlare.tres"),
	preload("res://Materials/FX/CollectShardSpark.tres")
]
func _ready():
	
	print("MaterialCache initialized")
	
	# Update - the stutter seems to be a little less now with this trick?
	# Now on laptop it only stutters after collecting the first shard.
	# Any shard after that is now smooth as butter
	
	for material in particle_materials:
		
		var instance = Particles.new()
		instance.process_material = material
		instance.amount = 1
		instance.emitting = true
		instance.one_shot = true

		add_child(instance)

	for material in spatial_materials:
		
		var instance = MeshInstance.new() 
		instance.material_override = material
		add_child(instance)
