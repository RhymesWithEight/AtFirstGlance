shader_type canvas_item;

uniform float proportion;

void fragment() {
	if(1.0 - UV.y > proportion){
		discard;
	}
}
