extends Area

func _ready():
	
	$Sprite3D.translation.z += rand_range(-1,1) * 0.01 # Prevent z-fighting

func _on_RedBlock_body_entered(body):
	if body.is_in_group("PLAYER"):
		body.hurt(999999)
