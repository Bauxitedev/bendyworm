extends Control

var finished = false
var skipping = false

func _process(_delta):
	$AnimationPlayer.playback_speed = 8.0 if skipping else 1.0

func on_unhandled_input(event):
	
	if event.is_action_pressed("ui_accept"):
		if finished:
			Audio.play("UISelect")
			UI.fade_in_out(Color.white, 1.0, 1.5)
			$TransitionTimer.start()
			finished = false # Prevent triggering twice
		else:
			skipping = true
	if event.is_action_released("ui_accept"):
		skipping = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "CreditsAnim":
		finished = true


func _on_TransitionTimer_timeout():
	Globals.main.fsm.switch_to_state("TitleScreen")
