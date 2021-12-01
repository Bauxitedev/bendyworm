extends VBoxContainer

onready var health_bar = $HealthBar
onready var shard_bar = $Panel/ShardBar

func _process(_delta):
	
	var ply = Globals.player
	if ply != null:
		show()
	else:
		hide()
