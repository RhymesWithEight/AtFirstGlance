shader_type canvas_item;

void fragment() {
	COLOR.rgb = textureLod(TEXTURE, UV, 5.0).rgb;
}