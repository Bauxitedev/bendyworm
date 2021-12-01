shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// shader translated from https://github.com/godotengine/godot/issues/20023
uniform sampler2D albedo_texture;
uniform vec4 albedo_color: hint_color = vec4(1,1,1,1);
uniform float circle_progress = 1.0; //0..1

vec2 saturate(vec2 v) 
{
	return clamp(v, vec2(0.0), vec2(1.0));
}

void fragment()
{
	vec2 tex = UV;
	vec2 resolution = vec2(textureSize(albedo_texture, 0));
	float pi = 3.14159265359;
	
	//Circular progress bar (NOTE this code runs for all pixel art not just ones with a circular progress bar. May be slow? Test on your laptop)
	if (circle_progress != 1.0) {
		float circle_angle = circle_progress * pi * 2.0;
		float current_angle = atan((tex.x-0.5)*-1.0, tex.y-0.5) + pi;
		if (current_angle > circle_angle) { discard; }
	}

	vec2 pixel = vec2(1.0) / resolution; // size of 1 pixel
	tex -= pixel * 0.5;
	vec2 tex_pixels = tex * resolution;
	vec2 deltaPixel = fract(tex_pixels) - 0.5;
	vec2 ddXY = fwidth(tex_pixels)*1.0; // same as: sqrt(ddx(tex_pixels) * ddx(tex_pixels) + ddy(tex_pixels) * ddy(tex_pixels))
	
	vec2 lod = log2(ddXY) - 1.0;
	vec4 uv = vec4(tex + (saturate(deltaPixel / saturate(ddXY) + 0.5) - deltaPixel) * pixel, lod); 

	vec4 sampled = textureLod(albedo_texture, uv.xy, uv.w);
	ALBEDO = sampled.rgb * albedo_color.rgb;
	ALPHA = sampled.a * albedo_color.a;
}