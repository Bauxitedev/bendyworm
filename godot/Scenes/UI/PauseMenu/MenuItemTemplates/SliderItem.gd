extends "res://Scenes/UI/PauseMenu/MenuItemTemplates/BaseItem.gd"

var value = 0.5

func setup(menu_item: Dictionary):
	$HBoxContainer/Label.text = menu_item["text"]

func on_unhandled_input(event):
	
	var updated = false
	
	if event.is_action_pressed("ui_left", true):
		value -= 0.1
		updated = true
	if event.is_action_pressed("ui_right", true):
		value += 0.1
		updated = true
		
	if updated:
		value = clamp(value, 0.0, 1.0)
		Config.set(name, value)
		Audio.play("UIMove")
	
func _process(_delta):
	
	$HBoxContainer/MarginContainer/ProgressBar.value = value
