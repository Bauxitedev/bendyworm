extends Spatial

var time = 0

onready var health_holder = $HealthHolder
onready var sprite = $SpriteBase/Sprite3D
onready var flasher = $SpriteBase/Sprite3D/Flasher

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	sprite.scale = Vector3(1,1,1) * (1.0 + clamp(tan(time*-3.0), -2.0, 2.0) * 0.02)


func _on_HealthHolder_on_hurt(_dmg):
	flasher.flash()

func _on_HealthHolder_on_death():
	FXSpawner.spawn("BrainExplode", global_transform.origin, true)
	Events.trigger_on_brain_death()
	Audio.play("BossDie")
	queue_free()
