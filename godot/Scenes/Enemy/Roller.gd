extends KinematicBody

var vel = Vector3(0,0,0)

onready var sprite_eye = $SpriteEye
onready var sprite_frame = $SpriteFrame
onready var hurt_area = $HurtArea
var noise = OpenSimplexNoise.new()

onready var sprite_frame_flasher = $SpriteFrame/Flasher
onready var tween_phys = $TweenPhysics
onready var health_holder = $HealthHolder

var frame_scale_target = Vector3(1,1,1)
var can_hurt = true

func _ready():
	noise.period = 0.5
	noise.seed = get_instance_id()
	
	# Make the eyes blink randomly per-enemy
	var mat: ShaderMaterial = sprite_eye.material_override
	var tex: AnimatedTexture = mat.get_shader_param("albedo_texture")
	tex.fps = rand_range(2,10)
	
func update_sprites(delta):
	
	sprite_frame.rotate_z(-vel.x * 0.1 * delta)
	sprite_frame.scale = sprite_frame.scale.linear_interpolate(frame_scale_target, clamp(10.0*delta, 0.0, 1.0))

func _physics_process(delta):
	
	update_sprites(delta)
	
	vel += Globals.gravity * delta
	vel *= 0.99 # Damp
	
	# TODO only do this if the player is in range
	
	var ply = Globals.player
	if ply != null:
		var follow_speed = 15.0
		
		var horiz_diff = ply.global_transform.origin.x - global_transform.origin.x
		var horiz_diff_vec = Vector3(1,0,0) * horiz_diff
		var horiz_diff_vec_len = horiz_diff_vec.length()
		var max_diff_vec = 10.0
		
		if horiz_diff_vec.length() > max_diff_vec:
			horiz_diff_vec *= max_diff_vec / horiz_diff_vec_len
		
		vel += horiz_diff_vec * follow_speed * delta
		
	# Add perlin noise to make it feel more alive
	vel.x += 500 * noise.get_noise_1d(OS.get_ticks_msec() / 1000.0) * delta

	vel = move_and_slide(vel, Vector3(0,1,0), true, 2)
	
	if can_hurt:
		for body in hurt_area.get_overlapping_bodies():
			if body.is_in_group("PLAYER"):
				shock(body)
		
func shock(player):
	player.hurt(30)
	Audio.play_spatial("RollerShock", global_transform.origin, true)
	sprite_frame_flasher.flash()
	sprite_frame.scale = Vector3(1,1,1) * 1.3
	
	var diff = player.global_transform.origin - global_transform.origin
	var impulse = diff.normalized() * 100
	player.apply_impulse(impulse)
	
	can_hurt = false
	$HurtTimer.start()


func _on_HurtTimer_timeout():
	can_hurt = true

func _on_HealthHolder_on_death():
	FXSpawner.spawn("EnemyExplode", global_transform.origin, true)
	Audio.play_spatial("RollerDie", global_transform.origin, true)
	queue_free()

func _on_HealthHolder_on_hurt(_damage):
	sprite_frame_flasher.flash()
