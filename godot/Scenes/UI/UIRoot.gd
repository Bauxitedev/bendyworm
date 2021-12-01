extends Control

onready var dialogue = $DialogueContainer/Dialogue
onready var pause_menu = $PauseMenuContainer/PauseMenu


func add_proxy(proxy: Node):
	$ProxyHolder.add_child(proxy)

func _process(_delta):
	get_tree().paused = dialogue.visible || pause_menu.visible
	
func show_dialogue(text_lines: PoolStringArray):
	dialogue.show_dialogue(text_lines)

func on_unhandled_input(event):

	pause_menu.on_unhandled_input(event)
	dialogue.on_unhandled_input(event)
	
	var in_main_game = Globals.main.fsm.get_state() == "MainGame"

	
	# Note: this must be below "pause_menu.on_unhandled_input(event)" or the pause menu closes instantly again
	if !get_tree().paused && event.is_action_pressed("ui_cancel"):
		if !in_main_game:
			pass
			# print("can't open pause menu - not in main game")
		else:
			pause_menu.show_pause_menu()
