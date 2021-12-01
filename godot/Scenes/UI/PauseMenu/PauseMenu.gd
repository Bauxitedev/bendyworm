extends Panel

onready var vbox_menu_items = $VBoxContainer/VBoxMenuItems

var configuring = false

var menu_items = [
	{ "name": "resume", "type": "NormalItem", "text": "Resume" }, 
	{ "name": "retry", "type": "NormalItem", "text": "Retry", }, 
	{ "name": "sep1", "type": "SeperatorItem" }, 	
	{ "name": "sfx_vol", "type": "SliderItem", "text": "SFX Volume", }, 
	{ "name": "mus_vol", "type": "SliderItem", "text": "Music Volume", }, 
	{ "name": "fullscreen", "type": "CheckboxItem", "text": "Fullscreen", }, 
	{ "name": "sep2", "type": "SeperatorItem" }, 
	{ "name": "del_save", "type": "NormalItem", "text": "Delete Save and Start Over", }, 
	{ "name": "quit", "type": "NormalItem", "text": "Quit to Desktop", }, 
]

var hovered_item = 0

func _ready():
	hide()
	
	setup_menu_items()
	
func setup_menu_items():

	for menu_item in menu_items:
		
		var menu_item_name = menu_item["name"]
		var menu_item_type = menu_item["type"]
		var scene_instance = load("res://Scenes/UI/PauseMenu/MenuItemTemplates/%s.tscn" % menu_item_type).instance()
		scene_instance.name = menu_item_name
		scene_instance.setup(menu_item)
		
		vbox_menu_items.add_child(scene_instance)
		
	
func show_pause_menu():
	
	if visible:
		return # already visible
		
	hovered_item = 0
	show()
	
func _process(_delta):
	
	for i in len(menu_items):
		
		var modulate = Color(0.5,0.5,0.5)
		if i == hovered_item:
			modulate = Color(1,1,1)
			if configuring:
				modulate = Color(1,1,1) * lerp(0.8, 1.0, round(0.5*(sin(OS.get_ticks_msec() / 80.0)+1)))
		vbox_menu_items.get_child(i).modulate = modulate

func on_unhandled_input(event):

	if !visible:
		return
		
	if event.is_action_pressed("ui_accept"):
		if configuring:
			Audio.play("UISelect")
			configuring = false
			return
		else:
			Audio.play("UISelect")
			var current_type = menu_items[hovered_item]["type"]
			
			vbox_menu_items.get_child(hovered_item).on_select()
			if current_type == "SliderItem":
				configuring = true
				return
			elif current_type == "NormalItem":
				on_menu_item_selected(menu_items[hovered_item]["name"])
	
	if configuring:
		vbox_menu_items.get_child(hovered_item).on_unhandled_input(event)
		return
		
	if event.is_action_pressed("ui_cancel"):
		hide()
		return
		
	if event.is_action_pressed("ui_up"):
		Audio.play("UIMove")
		hovered_item -= 1
		if hovered_item > 0 && hovered_item < len(menu_items) && menu_items[hovered_item]["type"] == "SeperatorItem":
			hovered_item -= 1 # Skip separators
	if event.is_action_pressed("ui_down"):
		Audio.play("UIMove")
		hovered_item += 1
		if hovered_item > 0 && hovered_item < len(menu_items) && menu_items[hovered_item]["type"] == "SeperatorItem":
			hovered_item += 1 # Skip separators
	hovered_item = posmod(hovered_item, len(menu_items))
		
func on_menu_item_selected(item: String):
	match item:
		"resume": hide()
		"retry":
			retry()
		"del_save":
			SaveProgress.delete_progress()
			retry()
		"quit": get_tree().quit()

func retry():
	var ply = Globals.player
	if ply == null:
		print("warning - can't retry: player is null")
	else:
		ply.hurt(999999)
		hide()
