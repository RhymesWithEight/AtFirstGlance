extends ColorRect

var circle_positions = []
var circle_radii = []
var percentage
const buffer = 200
const question_color = Color(0.2, 0.2, 1.0)
var question_text = tr("WATERQ")


func _draw():
	for i in circle_radii.size():
		var rad = circle_radii[i]
		var pos = circle_positions[i]
		if i == 0:
			draw_circle(pos, rad, Color.BEIGE)
		else:
			draw_circle(pos, rad, Color.BLUE)
		
		draw_arc(pos, rad, 0, TAU, 60, Color.BLACK, 5, true)
# Called when the node enters the scene tree for the first time.
func _ready():
	percentage = randf() * 100
	
	get_radii()
	get_positions()
	
	queue_redraw()

func get_radii():
	circle_radii.append(randi_range(100, 200))
	var remaining_water = pow(circle_radii[0], 2) * PI * percentage / 100
	while remaining_water > 0:
		var max_rad = sqrt(float(remaining_water) / PI)
		var rad = randi_range(30, 80)
		if rad > max_rad:
			rad = max_rad
			remaining_water = 0
		else:
			remaining_water -= pow(rad, 2) * PI
		circle_radii.append(rad)

func get_positions():
	for i in circle_radii.size():
		var rad = circle_radii[i]
		var pos
		
		var needs_spread = true
		var tries = 0
		while needs_spread and tries < 5:
			tries += 1
			needs_spread = false
			pos = Vector2(randi_range(buffer, 1000-buffer), randi_range(buffer, 1000-buffer))
			if !circle_positions.is_empty():
				for j in circle_positions.size():
					var pos2 = circle_positions[j]
					var rad2 = circle_radii[j]
					if (pos - pos2).length() < (rad + rad2 + 10):
						needs_spread = true
						break
						
			else:
				needs_spread = false
		
		circle_positions.append(pos)

func draw_antialiased_circle(pos : Vector2, radius : float, c : Color, num_points : int):
	var points : PackedVector2Array
	var angle_diff = 2 * PI / num_points
	
	var i = 0
	while i <= num_points:
		i += 1
		points.append(pos + radius * Vector2(cos(i * angle_diff), sin(i * angle_diff)))
	
	draw_polyline(points, c, 5.0, true)
