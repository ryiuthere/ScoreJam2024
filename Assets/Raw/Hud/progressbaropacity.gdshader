shader_type canvas_item;
uniform float fuel_amt;
uniform float opacity;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (UV.g < (1.0-fuel_amt)) {COLOR.rgba = vec4(0.0);}
	else if (COLOR.a > 0.01) {COLOR.a = opacity;}
}
