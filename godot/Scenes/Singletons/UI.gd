extends Node

onready var fade_rect = $FadeRect
onready var tween = $Tween
var duration_out
onready var fade_timer = $FadeRect/FadeTimer
onready var ui_root = $VP/UIRoot
onready var dialogue = ui_root.dialogue

onready var blurry_bg = $BlurryBG
var blurriness = 0.0 setget set_blurriness, get_blurriness

func _process(delta):
	
	var fade_rect_modulate_target = Color(1,1,1,1)
	
	var fade_speed = 3
	if get_tree().paused:
		set_blurriness(get_blurriness() + fade_speed * delta)
		fade_rect_modulate_target.a = 0
	else:
		set_blurriness(get_blurriness() - fade_speed * delta)
		
	# Note - fade rect modulate and fade rect color are two different things.
	# Modulate is only used to smoothly hide the fade when a dialogue/pause menu appears.
	fade_rect.modulate =  lerp(fade_rect.modulate, fade_rect_modulate_target, clamp(delta*10, 0.0, 1.0)) # Prevent fade from obscuring dialogue/pause menu (TODO this is a bit... buggy)
	
		
		
func set_blurriness(value):
	blurriness = clamp(value, 0.0, 1.0)
	blurry_bg.visible = !is_zero_approx(blurriness)
	
	var mat: ShaderMaterial = blurry_bg.material
	mat.set_shader_param("blurriness", smoothstep(0.0, 1.0, blurriness))
	
func get_blurriness():
	return blurriness

# This is idempotent now, so if you call this repeatedly it should always work consistently
func fade_in_out(color: Color, duration_in: float, duration_out_param: float):
	
	duration_out = duration_out_param
	
	tween.stop_all()
	
	fade_rect.color =  Color(0,0,0,0)
	tween.interpolate_property(fade_rect, "color", color * Color(1,1,1,0), color, duration_in, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	tween.start()

	fade_timer.start(duration_in) # if the timer is already running this resets it

func _on_FadeTimer_timeout():
	
	tween.stop_all()
	
	tween.interpolate_property(fade_rect, "color", fade_rect.color, fade_rect.color * Color(1,1,1,0), duration_out, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	tween.start()

func show_dialogue(text_lines: PoolStringArray):
	ui_root.show_dialogue(text_lines)

func _unhandled_input(event): # TODO or maybe _input_
	
	# NOTE: the UI singleton MUST be "on pause always process mode"
	# Otherwise the dialogue input events won't be triggered when paused!
	ui_root.on_unhandled_input(event)

func add_proxy(proxy: Node):
	ui_root.add_child(proxy)
