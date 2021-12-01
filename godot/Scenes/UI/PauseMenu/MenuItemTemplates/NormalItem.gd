extends "res://Scenes/UI/PauseMenu/MenuItemTemplates/BaseItem.gd"

func setup(menu_item: Dictionary):
	$Label.text = menu_item["text"]

