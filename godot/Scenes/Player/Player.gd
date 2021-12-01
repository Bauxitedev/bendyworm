extends KinematicBody

var vel = Vector3(0,0,0)
var jump_speed = 80
var should_snap_to_floor = true

onready var groundcast_l = $GroundCastL
onready var groundcast_r = $GroundCastR
onready var roofcast = $RoofCast
onready var spritebase = $SpriteBase
onready var sprite = $SpriteBase/FlipBase/Sprite3D
onready var cam = $Camera
onready var jumptimer =  $JumpTimer
onready var weapon = $SpriteBase/FlipBase/Weapon
onready var flipbase = $SpriteBase/FlipBase
onready var tween_idle = $TweenIdle  # For non-physics related tweens
onready var health_holder = $HealthHolder
onready var charging_circle = $SpriteBase/ChargingCircle

var first_frame = true # TODO little hack to prevent the player from randomly deviating from its spawn point
var can_variable_jump = false
var change_animation = true
var jump_button_held = false
var coyote_timer = 0
var can_use_cannon = false
var shard_counter = 0
var died = false

var sprite_color: Color setget set_sprite_color, get_sprite_color
onready var initial_sprite_color = get_sprite_color()
var sprite_color_mult = 1.0
var sprite_color_mult_target = 1.0
		
func _ready():
	cam.set_as_toplevel(true)
	Globals.player = self
	Events.trigger_on_player_spawn()
	
func _process(delta):
	orient_sprite_to_floor(delta)
	
	sprite_color_mult = lerp(sprite_color_mult, sprite_color_mult_target, clamp(5.0 * delta, 0.0, 1.0)) # TODO delta wrong?
	
	var col = initial_sprite_color * sprite_color_mult
	col.a = initial_sprite_color.a
	set_sprite_color(col)
	
	
func set_sprite_color(value):
	var mat: ShaderMaterial = sprite.material_override
	mat.set_shader_param("albedo_color", value)
func get_sprite_color():
	var mat: ShaderMaterial = sprite.material_override
	return mat.get_shader_param("albedo_color")
	
func collect_shard():
	shard_counter += 1
	Audio.play("ShardCollect", pow(pow(2, 1/12.0), shard_counter*2-2))
	if shard_counter == 5:
		activate_cannon()
		
func activate_cannon():
	Events.trigger_on_player_acquire_cannon()
	Audio.play("PlayerUpgrade")
	can_use_cannon = true
	
	#var target_color = get_sprite_color() * 1.5
	#target_color.a = 1.0 # Prevent doubling alpha
	
	tween_idle.interpolate_property(self, "sprite_color_mult_target",  1.0, 1.5, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween_idle.start()
	

func is_actually_on_ground(): # Without coyote time
	return groundcast_l.is_colliding() || groundcast_r.is_colliding()
	
func is_on_ground(): # With coyote time
	return coyote_timer > 0
	
func is_on_roof():
	return roofcast.is_colliding() 

func get_ground_normal():
	var normal = Vector3(0,0,0)
	
	if groundcast_l.is_colliding():
		normal += groundcast_l.get_collision_normal()
		
	if groundcast_r.is_colliding():
		normal += groundcast_r.get_collision_normal()
		
	if normal.length() < 1e-5:
		return null
		
	return normal.normalized()
	
func orient_sprite_to_floor(delta):
	
	var align_speed = 10.0
	
	var norm = get_ground_normal()
	if norm == null:
		norm = Vector3(0, 1, 0)
	
	var sprite_forward = spritebase.global_transform.basis.y
	
	var cross = sprite_forward.cross(norm)
	if cross.length() > 1e-5:
		spritebase.global_rotate(cross.normalized(), clamp(delta * align_speed, 0.0, 1.0) * cross.length())
	
	
func snap_camera_to_curve(delta):
	
	var worm = Globals.worm
	
	if !worm:
		print("warning: FlowAlongCurve can't find worm")
		return
	
	var curve: Curve2D = worm.curve
	var target_pos_2d = Vector2(global_transform.origin.x, global_transform.origin.y)
	var closest = curve.get_closest_point(worm.to_local(target_pos_2d))
	var closest_global = worm.to_global(closest)
	
	if first_frame: # Snap instantly on the first frame
		cam.global_transform.origin.x = closest_global.x 
		cam.global_transform.origin.y = closest_global.y
		return
	
	var lerp_speed = 20.0
	cam.global_transform.origin.x = lerp(cam.global_transform.origin.x, closest_global.x, clamp(lerp_speed * delta, 0.0, 1.0))
	cam.global_transform.origin.y = lerp(cam.global_transform.origin.y, closest_global.y, clamp(lerp_speed * delta, 0.0, 1.0))
	
	
func _physics_process(delta):
	
	snap_camera_to_curve(delta)
	
	global_transform.origin.z = 0 # flatten
	
	if first_frame:
		first_frame = false
		return
		
	coyote_timer = max(0, coyote_timer - delta)
	if is_actually_on_ground():
		coyote_timer = 0.2 # x seconds of coyote time
	
	var vel_add = Vector3(0,0,0)
	var is_running = false
	
	if !died:
		
		# Little hack: since analog stick drift overrides the dpad, it randomly causes dropped inputs.
		# So to fix this: have two seperate input maps and combine them
		var move_input_digital = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var move_input_analog = Input.get_action_strength("analog_right") - Input.get_action_strength("analog_left")
		var move_input = clamp(move_input_digital + move_input_analog, -1, 1)
		
		#print("left = ", Input.get_action_strength("ui_left"), " | right = ", Input.get_action_strength("ui_right"))
		var deadzone = 0.1
		
		if move_input < -deadzone:
			vel_add += Vector3(move_input, 0, 0)
			is_running = true
			flipbase.scale.x = -1
		if move_input > deadzone:
			vel_add += Vector3(move_input, 0, 0)
			is_running = true
			flipbase.scale.x = 1
		
		if change_animation:
			if is_actually_on_ground():
				if is_running:
					sprite.play("Run")
				else:
					sprite.play("Idle")
			else:
				if vel.y > 0:
					sprite.play("Jump")
				else:
					sprite.play("Fall")
				
		
	# Acceleration/damping	
	var ground_lerp_speed = 8 # TODO don't use a too high accel. or you can climb any slope
	var air_lerp_speed = 2 # This prevents shooting up slopes
	vel.x = lerp(vel.x, 100 * vel_add.x, clamp((ground_lerp_speed if is_actually_on_ground() else air_lerp_speed) * delta, 0.0, 1.0)) 
		
	# Gravity
	# TODO SLOPE FIX IS THIS, but do "vel.y = 0" in rotated space to fix it definitely
	#if !is_actually_on_ground():
	#	vel -= Vector3(0,100,0) * delta
	#elif should_snap_to_floor:
	#	vel.y = 0 # TODO do this in local player space, otherwise you slow down way too much when walkng up slopes
	vel += Globals.gravity * delta
	
	if !is_actually_on_ground() || !should_snap_to_floor:
		vel = move_and_slide(vel, Vector3(0,1,0), true) # TODO stop_on_slope doesn't seem to work
	else:
		var snap_vec = Vector3(0,-7,0) # TODO -10 seems too long?
		vel = move_and_slide_with_snap(vel, snap_vec, Vector3(0,1,0), true) # TODO stop_on_slope doesn't seem to work
	
	# Variable jump (only if not on a roof to prevent shooting sideways)
	if is_on_roof():
		can_variable_jump = false
	if jump_button_held && can_variable_jump:
		vel.y = jump_speed
		
	# Check curve deviation (if too big, player fell out of the level)
	var flow_along_curve_path = "FlowAlongCurve"
	if has_node(flow_along_curve_path):
		var flow_along_curve = get_node(flow_along_curve_path)
		var deviation = flow_along_curve.curve_deviation
		if deviation > 180: # TODO this should be: tilemap.height * tile_size / 2 right?
			print("WARNING - player fell out of the level")
			health_holder.hurt(999999)
	else:
		print("warning - player's FlowAlongCurve cannot be found")
		
func _unhandled_input(event):
	
	if died:
		return
	
	if event.is_action_pressed("jump"):
		if !jump_button_held:
			if is_on_ground():
				jump()
		jump_button_held = true
		
	if event.is_action_released("jump"):
		jump_button_held = false
		can_variable_jump = false # prevent double jumping
		
	if event.is_action_pressed("shoot"):
		if can_use_cannon:
			weapon.pull_trigger()
		else:
			Audio.play("Error")
	if event.is_action_released("shoot"):
		if can_use_cannon:		
			weapon.release_trigger()
			
		
func hurt(dmg: float):
	health_holder.hurt(dmg)
	
func apply_impulse(impulse: Vector3):
	vel += impulse
	become_airborne()
	
func jump():
	vel.y = jump_speed
	Audio.play("Jump") # TODO this sound plays twice implicating you can always jump twice
	sprite.play("Jump")
	change_animation = false
	become_airborne()
	
func become_airborne():
	should_snap_to_floor = false
	can_variable_jump = true
	jumptimer.start()
		
func _on_Sprite3D_animation_finished():
	change_animation = true

func _on_JumpTimer_timeout():
	can_variable_jump = false
	should_snap_to_floor = true

func _on_HealthHolder_on_death():
	Events.trigger_on_player_death()
	died = true
	weapon.queue_free() # TODO ensure you don't call any methods on it after you do this
	charging_circle.queue_free()  # TODO ensure you don't call any methods on it after you do this
	sprite.play("Death")
	Audio.play("PlayerDie")

func _on_HealthHolder_on_hurt(_damage):
	Audio.play("PlayerHurt")
	sprite_color_mult = sprite_color_mult_target * 1.4
