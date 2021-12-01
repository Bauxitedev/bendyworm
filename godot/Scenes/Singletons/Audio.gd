extends Spatial

var sounds = {}

onready var playing_global_sounds = $PlayingGlobalSounds

func _ready():
	for c in $SoundTemplates.get_children():
		$SoundTemplates.remove_child(c) # IMPORTANT - do NOT queue_free, we want to keep it in memory
		sounds[c.name] = c
		
func play(name: String, pitch: float = 1.0):
	var instance = sounds[name].duplicate()
	playing_global_sounds.add_child(instance) 
	instance.pitch_scale *= pitch
	instance.play()
	instance.connect("finished", instance, "queue_free")
	
	return instance

		
func play_spatial(name: String, position: Vector3, flow_along_curve: bool):
	var instance = sounds[name].duplicate()
	Globals.level_root.add_child(instance)
	instance.global_transform.origin = position
	instance.play()
	instance.connect("finished", instance, "queue_free")
	
	if flow_along_curve:
		instance.add_child(preload("res://Scenes/Worm/FlowAlongCurve.tscn").instance())
	
	return instance
