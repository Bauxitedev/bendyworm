extends MarginContainer

onready var label = $WormLevelLabel

func _process(_delta):
	visible = Globals.player != null
	label.text = "Worm %s" % SaveProgress.current_level_num
