extends Node

var save_filename = "save.sav"

var current_level_num = 1

func _ready():
	pass
	
func save_progress():
	
	var json = to_json({ "current_level_num": current_level_num })
	
	var save_file = File.new()
	var err = save_file.open(save_filename, File.WRITE) # Truncates the current savefile if it exists
	if err != OK:
		print("failed to open save file for writing: ", err)
		return
		
	save_file.store_string(json)
	save_file.close()
	
	print("saved: ", json)
	

func load_progress():
	var save_file = File.new()
	if !save_file.file_exists(save_filename):
		print("no savefile found")
		return null

	save_file.open(save_filename, File.READ)
	var text = save_file.get_as_text()
	var json = parse_json(text)
	current_level_num = json["current_level_num"]
	
	print("loaded:", json)
	
func delete_progress():
	
	var save_file = File.new()
	if !save_file.file_exists(save_filename):
		print("no savefile to delete")
		return
		
	# WELP, this doesn't work in exported mode, so just gonna write lvl 1 to the save file instead
	#var dir = Directory.new()
	#var err = dir.remove(save_filename)
	#if err != OK:
	#	print("file deletion failed: ", err)
	#else:
#		print("save deleted succesfully")
	
	
	current_level_num = 1
	save_progress()
	
