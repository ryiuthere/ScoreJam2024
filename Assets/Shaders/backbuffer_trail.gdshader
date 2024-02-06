shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_nearest;

void fragment() {
	COLOR = texture(screen, 1.0-SCREEN_UV, 0.0);
}
