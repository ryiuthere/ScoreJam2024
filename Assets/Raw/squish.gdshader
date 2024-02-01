shader_type canvas_item;

uniform vec2 deform = vec2(0.0);
uniform float horiz_deform_scale = 5.0;
uniform float cross_factor = 0.4;

void vertex() {
	vec2 deform_strength = abs(deform);
	float horiz_deform = min(deform_strength.x, deform_strength.y);
	float sprite_width = abs(VERTEX.x);
	
	if (sign(deform.y) != sign(VERTEX.y)) {
		VERTEX.x += horiz_deform * horiz_deform_scale * sprite_width * sign(deform.x);
	}
	
	vec2 scale = 1.0 - deform_strength;
	
	vec2 buffer = VERTEX;
	VERTEX.x = buffer.x * scale.x / scale.y;
	VERTEX.y = buffer.y * scale.y / scale.x;
	VERTEX.xy += deform * sprite_width * cross_factor;
}
