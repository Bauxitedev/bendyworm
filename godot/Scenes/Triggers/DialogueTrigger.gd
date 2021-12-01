extends Area

var triggered = false
export var dialogue_name = "invalid" setget set_dialogue_name
var dialogue_text_lines = ["dialogue_missing"]

func set_dialogue_name(value):
	dialogue_name = value
	dialogue_text_lines = UI.dialogue.get_dialogue_text(dialogue_name).split("\n$$$\n")

func _on_DialogueTrigger_body_entered(body):
	
	if triggered:
		return
		
	if !body.is_in_group("PLAYER"):
		return
	
	UI.show_dialogue(dialogue_text_lines) 
	triggered = true
	
	queue_free()
