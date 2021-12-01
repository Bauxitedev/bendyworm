extends "res://Scenes/Player/Weapon/FSM/FSMWeaponStateBase.gd"

onready var raycast = $LaserOrigin/RayCast
onready var hitindicator = $LaserOrigin/HitIndicator
onready var laserbeam = $LaserOrigin/LaserBeam
onready var lasercylinder = $LaserOrigin/LaserBeam/Cylinder
onready var laserorigin = $LaserOrigin
onready var muzzleroot = $LaserOrigin/MuzzleRoot
onready var muzzleparticles = $LaserOrigin/MuzzleParticles
onready var audio_laserloop = $AudioLaserLoop

var laserbeam_color setget set_laserbeam_color, get_laserbeam_color
onready var initial_laserbeam_color = Color(1.2, 1.44, 1.6)

# TODO: local_to_scene doesn't work since FSM states are duplicate()'d, not instance()'d.
# It's local_to_scene, not local_to_duplicate.
# As a result, doing "onready var initial_laserbeam_color = get_laserbeam_color()" doesn't work either.
# Because the beam color may have been modified on a previous instance of the Shooting state.
# So it uses an invisible color as the base color the second time you enter the state.
# Workaround: just hardcode the initial beam color for now, but that means you can't preview it in the editor...

func set_laserbeam_color(value):
	var mat: SpatialMaterial = lasercylinder.get_surface_material(0)
	mat.albedo_color = value
	
func get_laserbeam_color():
	var mat: SpatialMaterial = lasercylinder.get_surface_material(0)
	return mat.albedo_color

func enter():
	.enter()
	Audio.play("ShootStart")
	audio_laserloop.play()

func pull_trigger():
	.pull_trigger()
	
func release_trigger():
	.release_trigger()

func _process(delta):
	var fsm_holder = get_fsm().get_fsm_holder()
	fsm_holder.charge_amount -=  0.15 * delta
	
	# Note - alpha doesn't affect additive blending
	
	# This smoothly drops from 1 to 0 when the charge beam is almost depleted
	var energy_depleted_multiplier = smoothstep(0.0, 0.1, fsm_holder.charge_amount)
	
	var brightness = range_lerp(sin(80 * OS.get_ticks_msec() / 1000.0), -1, 1, 0.9, 1.0) * energy_depleted_multiplier
	hitindicator.scale = Vector3.ONE * energy_depleted_multiplier * rand_range(0.8,1.2)
	muzzleroot.scale = Vector3.ONE * energy_depleted_multiplier * rand_range(0.8,1.2)
	set_laserbeam_color(initial_laserbeam_color * Color(brightness, brightness, brightness))
	
	if energy_depleted_multiplier < 0.999:
		muzzleparticles.emitting = false
	
	audio_laserloop.pitch_scale = max(0.01, energy_depleted_multiplier)
	audio_laserloop.volume_db = Config.linear_to_db(sqrt(max(energy_depleted_multiplier, 0.01)))
	
	if fsm_holder.charge_amount <= 0.0:
		get_fsm().switch_to_state("Idle")
		set_process(false) # Prevents switching twice

func _physics_process(delta):
	
	if raycast.is_colliding():
		hitindicator.show()
		laserbeam.show()		
		
		var hitpoint = raycast.get_collision_point() 
		hitindicator.global_transform.origin = hitpoint
		
		var fsm_holder = get_fsm().get_fsm_holder()
		if fsm_holder.charge_amount > 0.1:
			FXSpawner.spawn("Spark", hitpoint, true)

		laserbeam.scale.x = laserorigin.global_transform.origin.distance_to(hitpoint)
		
		var victim = raycast.get_collider()
		if "health_holder" in victim:
			victim.health_holder.hurt(200 * delta)
		
	else:
		hitindicator.hide()
		laserbeam.hide()
