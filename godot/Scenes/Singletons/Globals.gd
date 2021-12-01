extends Node

var worm = null setget set_worm, get_worm
var level_root = null setget set_level_root, get_level_root
var player = null setget set_player, get_player
var main # Note - since the Main node is never destroyed, this is guaranteed to be valid

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#########################

func set_worm(value):
	worm = value

func get_worm():
	if is_instance_valid(worm):
		return worm
	else:
		print("warning - worm missing")
		return null
	
#########################
	
func set_level_root(value):
	level_root = value

func get_level_root():
	if is_instance_valid(level_root):
		return level_root
	else:
		print("warning - level_root missing")
		return null

#########################

func set_player(value):
	player = value

func get_player():
	if is_instance_valid(player):
		return player
	else:
		return null
		
#########################

func color_lerp_hsv(a: Color, b: Color, amount: float):
	
	var a_hsv = Vector3(a.h, a.s, a.v)
	var b_hsv = Vector3(b.h, b.s, b.v)
	
	var lerped_hsv = a_hsv.linear_interpolate(b_hsv, amount)
	return Color.from_hsv(lerped_hsv.x, lerped_hsv.y, lerped_hsv.z)


