shader_type canvas_item;

void fragment() {
	vec4 current = texture(TEXTURE, UV);
	float avg = (current.r + current.g + current.b) / 3.0;
	vec3 grey = vec3(avg);
	COLOR.rgb = textureLod(TEXTURE, UV, 10.0).rgb;
}
