extends Spatial

signal on_death
signal on_hurt(damage)

var is_dead = false
var hp: float
export var max_hp: float = 100.0

func get_health_ratio():
	return hp / max_hp

func _ready():
	hp = max_hp
	
func hurt(dmg: float):
	if is_dead:
		print("STOP! He's already dead!")
		return
		
	hp -= dmg
	emit_signal("on_hurt", dmg)
	
	if hp <= 0:
		hp = 0
		is_dead = true
		emit_signal("on_death")
		
func heal(dmg: float):
	if is_dead:
		print("Too late to heal now, he's already dead!")
		return
		
	hp += dmg
	hp = min(hp, max_hp)
