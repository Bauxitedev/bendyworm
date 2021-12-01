extends PanelContainer

onready var label = $VBoxContainer/Label
onready var icon = $VBoxContainer/Arrow
onready var texts = $Texts

var current_line setget set_current_line
var text_lines
var text_progress 

func get_dialogue_text(key: String):
	
	if !texts.has_node(key):
		push_error("Unknown piece of dialogue: '%s'" % key)
		assert(false)
		
	return texts.get_node(key).dialogue_text

func set_current_line(line_num):
	current_line = line_num
	var text = text_lines[current_line]
	label.bbcode_text = text
	
	text_progress = 0.0

func _ready():
	hide()
	
func _process(delta):
	
	var text_scroll_speed = 50 # chars per second
	
	if Input.is_action_pressed("ui_accept"):
		text_scroll_speed *= 4.0

	if visible:
		text_progress += text_scroll_speed * delta 
		label.visible_characters = text_progress
		
		icon.visible = label.percent_visible >= 1 && fmod(OS.get_ticks_msec() / 1000.0, 1.0) > 0.5

func on_unhandled_input(event):

	if !visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		
		if label.percent_visible >= 1:
			Audio.play("UISelect")
			
			if current_line+1 >= len(text_lines):
				hide()
				return
			set_current_line(current_line + 1) # NOTE: need to call setter explicitly here
			

func show_dialogue(text_lines_param: PoolStringArray):
	
	show()
	Audio.play("UISelect")
	
	text_progress = 0.0
	
	current_line = 0
	text_lines = text_lines_param
	set_current_line(current_line)

