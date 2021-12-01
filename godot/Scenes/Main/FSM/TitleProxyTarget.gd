extends Control

var pressed_start = false
onready var press_start = $VBoxContainer/PressStart
onready var center_container = $CenterContainer
onready var vbox_container = $VBoxContainer
onready var tween = $Tween

func _process(_delta):
	press_start.self_modulate.a = range_lerp(fmod(OS.get_ticks_msec() / 1000.0, 0.8), 0, 0.8, 1.0, 0.6)

func on_unhandled_input(event):
	if pressed_start:
		return
		
	if event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel"):
		pressed_start = true
		Audio.play("UISelect")
		
		UI.fade_in_out(Color.black, 0.9, 1.5)
		$AnimationPlayer.play("TitleScreenPressStart")
		
		tween.interpolate_property(center_container, "rect_position", center_container.rect_position, rect_position - Vector2(0,1000), 1.0, Tween.TRANS_QUART, Tween.EASE_IN)
		tween.interpolate_property(vbox_container, "rect_position", vbox_container.rect_position, rect_position + Vector2(0,1000), 1.0, Tween.TRANS_QUART, Tween.EASE_IN)
		tween.start()
