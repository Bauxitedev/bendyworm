extends Area

onready var sprite = $SpriteBase
var collected = false

func _process(delta):
	sprite.rotate_y(delta * rand_range(0.5,1.5))


func _on_Shard_body_entered(body):
	
	if collected:
		return
	
	if body.is_in_group("PLAYER"):
		body.collect_shard()
		queue_free()
		
		collected = true # Prevent double trigger
		
		FXSpawner.spawn("CollectShard", global_transform.origin, true)
		
