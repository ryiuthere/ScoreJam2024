shader_type canvas_item;

uniform float deform_x = 0.0;
uniform float deform_y = 0.0;
uniform float squish_factor = 0.0;
uniform float component_floor = 0.0;
uniform bool scale_squish;

void vertex() {
	float squish_scalar = squish_factor; 
	if (scale_squish) {squish_scalar *= 2.0;}
	vec2 deformation_vector = vec2(deform_x+1.0, deform_y+1.0) - vec2(deform_y, deform_x) * squish_scalar;
	deformation_vector.x = max(deformation_vector.x, component_floor);
	deformation_vector.y = max(deformation_vector.y, component_floor);
	VERTEX.xy *= deformation_vector;
}
