extends Control

export(ViewportTexture) var texture

func _process(_delta):
	update()
	
func _draw():
	
	var texture_size = texture.get_size()
	var container_size = self.rect_size
	
	# Check scale ratios
	var scale_ratio_x = container_size.x / float(texture_size.x)
	var scale_ratio_y = container_size.y / float(texture_size.y)
	
	# Pick the smallest one
	var scale_ratio = min(scale_ratio_x, scale_ratio_y)
	
	# Floor it
	var scale_ratio_int = max(1, int(floor(scale_ratio)))
	
	var x = round(container_size.x / 2.0 - (texture_size.x * scale_ratio_int) / 2.0)
	var y = round(container_size.y / 2.0 - (texture_size.y * scale_ratio_int) / 2.0)
	var w = texture_size.x * scale_ratio_int
	var h = texture_size.y * scale_ratio_int
	
	var region = Rect2(x,y,w,h)
	draw_texture_rect(texture, region, false)
