extends Node

var queue = []
onready var tween = $Tween

var crossfading_to # Note - apparently Strings can't be nullable so don't put ": String" here or it crashes at runtime
var lowest_volume = -80
var highest_volume = 0
var can_start_new_song = true
var crossfade_duration = 1.0

onready var songs = get_node("Songs")

func _ready():
	for song_node in songs.get_children():
		song_node.volume_db = lowest_volume

func get_song_node(song: String) -> AudioStreamPlayer:
	return songs.get_node(song) as AudioStreamPlayer
	
func play(song: String):
	queue.append(song)

func _process(_delta):
	
	if can_start_new_song && len(queue) > 0:
		
		var song_to_play = queue.pop_front()
		
		var crossfading_from = crossfading_to
		crossfading_to = song_to_play
		
		if crossfading_from == crossfading_to:
			# Not crossfading from a song to itself
			return
		
		var song_node_to = get_song_node(crossfading_to)
		song_node_to.play(0)
		
		if crossfading_from == null:
			# No song to crossfade from so start at highest volume
			song_node_to.volume_db = highest_volume
			return
			
		var song_node_from = get_song_node(crossfading_from)		
		
		
		tween.interpolate_property(song_node_from, "volume_db", song_node_from.volume_db, lowest_volume, crossfade_duration, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		tween.interpolate_property(song_node_to, "volume_db", song_node_to.volume_db, highest_volume, crossfade_duration, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		tween.start()		

		can_start_new_song = false


func _on_Tween_tween_all_completed():
	can_start_new_song = true

	# Stop all songs that are fully faded out
	for song_node in songs.get_children():
		if is_equal_approx(song_node.volume_db, lowest_volume):
			song_node.stop()
