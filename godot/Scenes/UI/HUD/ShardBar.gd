extends HBoxContainer



onready var shard_sprite_count = get_child_count()

func _process(_delta):
	
	var player = Globals.player
	
	if player == null:
		return
		
	var shard_count = player.shard_counter
	
	for i in shard_sprite_count:
		
		var shard_sprite = get_child(i)
		
		if i >= shard_count:
			shard_sprite.modulate = Color(0.1, 0.1, 0.1)
		else:
			shard_sprite.modulate = Color(1,1,1)
			
		
