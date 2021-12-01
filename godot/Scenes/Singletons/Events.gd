extends Node

# Global event system. Connect your entity to its signals in your _ready() callback to get notified about important events

signal on_player_spawn
signal on_player_death
signal on_player_acquire_cannon
signal on_brain_death

func trigger_on_player_spawn():
	emit_signal("on_player_spawn")

func trigger_on_player_death():
	emit_signal("on_player_death")

func trigger_on_player_acquire_cannon():
	emit_signal("on_player_acquire_cannon")
	
func trigger_on_brain_death():
	emit_signal("on_brain_death")
