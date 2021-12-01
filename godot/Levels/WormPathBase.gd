tool
extends Path2D

var default_font

var tilemap: TileMap

func _ready():
	
	if !Engine.is_editor_hint():
		return
		
	

func _process(_delta):
	
	if Engine.is_editor_hint():
		update()
		
func _draw():
	
	if !Engine.is_editor_hint():
		return
		
	if default_font == null:
		default_font = Control.new().get_font("font")
		
	if tilemap == null:
		var tilemap_base = LevelTilemaps.get_level_tilemap_base(get_parent().level_tilemap_number)
		tilemap = tilemap_base.get_node(get_parent().tilemap_layer_name)
		print(tilemap_base, " loaded!")
		
	# Draw lengths along curve for easier editing
	var tile_size = tilemap.cell_size.x
	var curve_len = curve.get_baked_length()
	var tiles_w =  tilemap.get_used_rect().size.x
	var tiles_h =  tilemap.get_used_rect().size.y
	var line_height = 10
	
	var max_offset = curve_len - (tiles_w*tile_size + 2*tile_size)
	
	for offset in range(0,curve_len, 100):
		var pos = curve.interpolate_baked(offset, true)
		
		var color = Color.white
		if offset < tiles_w * tile_size:
			color *= Color(1,1,0)
		if offset > max_offset:
			color *= Color(1,0,1)

		draw_circle(pos, 10, color)
		draw_string(default_font, pos -  Vector2(0,line_height), "%s pixels" % [offset], color)
		draw_string(default_font, pos + Vector2(0,line_height), "%s tiles" % [floor(offset / tile_size)], color)
		
		var pos2 = curve.interpolate_baked(offset+tile_size, true)
		var tangent = (pos2-pos).normalized().tangent()
		
		draw_circle(pos + tangent * tile_size * tiles_h / 2.0, 6, color * Color(1,1,1,0.5))
		draw_circle(pos - tangent * tile_size * tiles_h / 2.0, 6, color * Color(1,1,1,0.5))
		
	
	
	
