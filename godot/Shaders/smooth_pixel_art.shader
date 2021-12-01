shader_type canvas_item;

// shader translated from https://github.com/godotengine/godot/issues/20023

vec2 saturate(vec2 v) 
{
	return clamp(v, vec2(0.0), vec2(1.0));
}

void fragment()
{
	vec2 tex = UV;
	vec2 resolution = vec2(textureSize(TEXTURE, 0));

	vec2 pixel = vec2(1.0) / resolution; // size of 1 pixel
	tex -= pixel * 0.5;
	vec2 tex_pixels = tex * resolution;
	vec2 deltaPixel = fract(tex_pixels) - 0.5;
	vec2 ddXY = fwidth(tex_pixels)*1.0; // same as: sqrt(ddx(tex_pixels) * ddx(tex_pixels) + ddy(tex_pixels) * ddy(tex_pixels))
	
	vec2 lod = log2(ddXY) - 1.0;
	vec4 uv = vec4(tex + (saturate(deltaPixel / saturate(ddXY) + 0.5) - deltaPixel) * pixel, lod); 

	COLOR = textureLod(TEXTURE, uv.xy, uv.w);
}