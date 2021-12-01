extends Node2D

export var flow_speed = 0.0
export var reset_flow_offset = false
export(NodePath) var path2d_nodepath
var flow_offset = 0.0
var target_flow_offset = 0.0

var curve: Curve2D
var tiles_w
var tiles_h
var tile_size
var tilemap: TileMap
onready var curve_mesh3d = $CurveMesh3D
onready var collision3d = $Collision3D
	
func _ready():
	Globals.worm = self
	
	var path2d = get_node(path2d_nodepath)
	curve = path2d.curve
	
func setup(tilemap: TileMap): # Called by parent
	self.tilemap = tilemap
	var tileset: TileSet = tilemap.tile_set
	
	var tex =  tileset.tile_get_texture(tileset.get_tiles_ids()[0]) # TODO this assumes every tileset contains only 1 texture
	var mat: ShaderMaterial = curve_mesh3d.material_override
	mat.set_shader_param("albedo_texture", tex)
	
	tiles_w = tilemap.get_used_rect().size.x
	tiles_h = tilemap.get_used_rect().size.y
	tile_size = tilemap.cell_size.x # TODO assuming tiles are square
	
	# Important so we can call lookup_cell_pos in the first frame
	PathRasterizer.update_rasterization(curve, flow_offset, tilemap)
	
func get_max_flow_offset():
	# 2 extra tiles at the end for margin used for tangent calculation	
	return curve.get_baked_length() - ((tiles_w + 2) * tile_size)
	
func _physics_process(delta):
	
	var max_flow_offset = get_max_flow_offset()
	if target_flow_offset > max_flow_offset:
		print("warning: someone set target_flow_offset too high (%s vs max %s) " % [target_flow_offset, max_flow_offset])
		target_flow_offset = max_flow_offset
	
	var flow_offset_diff = target_flow_offset - flow_offset
	
	if abs(flow_offset_diff) > 0.1:
		var max_flow_speed = 50
		var lerp_speed = 5
		var target_flow_speed = clamp(flow_offset_diff * 4.0, -max_flow_speed, max_flow_speed)
		flow_speed = lerp(flow_speed, target_flow_speed, clamp(lerp_speed * delta, 0.0, 1.0)) * 0.95
	
	flow_offset += flow_speed * delta
	flow_offset = clamp(flow_offset, 0.0, max_flow_offset)
	#print("flow_offset = %s (max %s), target = %s" % [flow_offset, max_flow_offset, target_flow_offset])

	if reset_flow_offset:
		flow_offset = 0
		reset_flow_offset = false
		
	PathRasterizer.update_rasterization(curve, flow_offset, tilemap)
	curve_mesh3d.mesh = PathRasterizer.rasterize_to_mesh_instance()
	PathRasterizer.rasterize_to_collision(collision3d) # now fast in 3d!
		

func _on_Collision3D_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		print("TEST clicked on the worm")
