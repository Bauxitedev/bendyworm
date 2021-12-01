extends Node

var sfx_vol  setget set_sfx_vol
var mus_vol  setget set_mus_vol
var fullscreen  setget set_fullscreen

func _ready():
	set_sfx_vol(0.5)
	set_mus_vol(0.5)
	if OS.has_feature("standalone"):
		set_fullscreen(true)
		#Globals.main.fsm.initial_state = "Intro"

func linear_to_db(vol):
	
	# Multiply by 0.8 because the audio still clips sometimes
	return pow(vol * 0.8, 0.1) * 80 - 80
	
func set_sfx_vol(value):
	sfx_vol = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	
func set_mus_vol(value):
	mus_vol = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func set_fullscreen(value):
	fullscreen = value
	OS.window_fullscreen = fullscreen
