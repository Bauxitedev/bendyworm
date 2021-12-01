extends "res://Scenes/FSM/FSMStateBase.gd"

var current_level = null

onready var retry_timer = $RetryTimer
onready var win_timer = $WinTimer

var level_path_template = "res://Levels/Level%d.tscn"

func enter():
	.enter()
	Events.connect("on_player_death", self, "_events_on_player_death")
	Events.connect("on_brain_death", self, "_events_on_brain_death")
	
	SaveProgress.load_progress()
	Music.play("MainSong")
	
	load_level()
	
func level_exists(lvl_num):
	var scene_path = level_path_template % lvl_num
	return ResourceLoader.exists(scene_path)
	
func load_level():
	
	if is_instance_valid(current_level):
		current_level.queue_free()
	
	var scene_path = level_path_template % SaveProgress.current_level_num
	if level_exists(SaveProgress.current_level_num):
		current_level = load(scene_path).instance()
		add_child(current_level)
		Globals.level_root = current_level
	else:
		print("warning - level doesn't exist, stuck in limbo, this should never happen")
		
	

func _unhandled_input(event):
	
	# TODO cheat codes here, remove em
	return
	if event is InputEventKey && event.is_pressed():
		if event.scancode == KEY_1:
			SaveProgress.current_level_num -= 1
			SaveProgress.save_progress()
			reset_level()
		if event.scancode == KEY_2:
			SaveProgress.current_level_num += 1
			SaveProgress.save_progress()
			reset_level()
		if event.scancode == KEY_3:
			for enemy in get_tree().get_nodes_in_group("ENEMY"):
				enemy.health_holder.hurt(999999)
		if event.scancode == KEY_4:
			for enemy in get_tree().get_nodes_in_group("ENEMY"):
				enemy.health_holder.hurt(160)
		if event.scancode == KEY_5:
			Globals.player.collect_shard()
		if event.scancode == KEY_0:
			get_fsm().switch_to_state("Intro")
			
func reset_level():
	get_fsm().switch_to_state("MainGame")

func _events_on_player_death():
	if win_timer.is_stopped():
		print("you died, retrying same level...")
		UI.fade_in_out(Color.black, 2.0, 2.0)
		retry_timer.start()
	else:
		print("you died after defeating the brain - you win anyway")
	
func _events_on_brain_death():
	if retry_timer.is_stopped():
		print("you win, moving to next level...")
		win_timer.start()
		UI.fade_in_out(Color.white, 4.0, 2.0)
	else:
		print("you died before defeating the brain - you lose anyway")

func _on_RetryTimer_timeout():
	reset_level()

func _on_WinTimer_timeout():
	
	if level_exists(SaveProgress.current_level_num+1):
		SaveProgress.current_level_num += 1 
		SaveProgress.save_progress()
		reset_level()
	else:
		# Going to credits so don't save
		get_fsm().switch_to_state("Credits")
