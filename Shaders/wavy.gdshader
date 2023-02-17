shader_type canvas_item;

uniform sampler2D alpha_texture;
uniform float progression;

void fragment() {
	vec4 start_tex = texture(TEXTURE, UV);
	vec4 sample_tex = texture(alpha_texture, UV);
	start_tex = start_tex * pow(sample_tex.r - 0.05, progression * 5.0) - 0.05;
	COLOR = start_tex;
}
