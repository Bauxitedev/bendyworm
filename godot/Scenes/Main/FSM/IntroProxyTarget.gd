extends Control

onready var logo_sprite = $LogoContainer/Control/Logo
onready var logo_sprite2 = $LogoContainer/Control/Logo2

func _process(delta):
	
	logo_sprite.rotation += 0.3 * delta
	logo_sprite2.rotation += 0.27 * delta

func on_unhandled_input(_event):
	pass

