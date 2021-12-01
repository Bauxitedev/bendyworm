extends "res://Scenes/UI/PauseMenu/MenuItemTemplates/BaseItem.gd"

var checked = false

func setup(menu_item: Dictionary):
	$HBoxContainer/Label.text = menu_item["text"]

func on_select():
	
	checked = !checked
	
	if checked:
		$HBoxContainer/CheckBox.texture = preload("res://Textures/UI/CheckboxFG.png")
	else:
		$HBoxContainer/CheckBox.texture = preload("res://Textures/UI/CheckboxBG.png")

	Config.set(name, checked)
