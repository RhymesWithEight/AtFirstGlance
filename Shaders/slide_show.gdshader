shader_type canvas_item;

uniform float progression = 0.0;
uniform vec2 center = vec2(1.0, 1.7321);

void fragment() {
	vec2 corner = vec2(0.5, 0.5);
	if((UV.x < 0.1)&&(UV.y < 0.1)){
		corner = vec2(0.1, 0.1);
	}
	if((UV.x < 0.1)&&(UV.y > 0.9)){
		corner = vec2(0.1, 0.9);
	}
	if((UV.x > 0.9)&&(UV.y < 0.1)){
		corner = vec2(0.9, 0.1);
	}
	if((UV.x > 0.9)&&(UV.y > 0.9)){
		corner = vec2(0.9, 0.9);
	}
	
	float dist_from_edge = min(min(min(UV.x, UV.y), 1.0 - UV.x), 1.0 - UV.y);
	if(dist_from_edge < 0.1){
		COLOR.a = dist_from_edge * 10.0;
		if(distance(corner, UV) < 0.2){
			COLOR.a = fma(-10.0, distance(corner, UV), 1.0);
		}
	}
	
	vec2 diff = center - UV;
	float angle = atan(diff.y / diff.x);
	float threshold = progression * PI / 3.0 + atan(center.y / center.x) / 2.0;
	if(angle < threshold){
		COLOR.a = 0.0;
	}
}
