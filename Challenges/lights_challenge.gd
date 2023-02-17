extends ColorRect

## The texture of a light that's on.
@export var light_on_tex : Texture
## The texture of a light that's off.
@export var light_off_tex : Texture

var question_text
var question_color
var background_color = Color.from_hsv(randf(), 0.1, 0.5)
var percentage = {}
var buffer = 100
var top_points = []

func _draw():
	for point in top_points:
		var above = Vector2(point.x, 0)
		draw_line(point, above, Color(0.05,0.05,0.05), 3, true)

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_lights()
	queue_redraw()

func populate_lights():
	var lights_num = randi_range(8, 18)
	var amount_on = 0.0
	var lights = []
	for i in range(lights_num):
		var sprite = Sprite2D.new()
		
		var min_distance = size.length() / lights_num
		
		var needs_spread = true
		while needs_spread:
			sprite.position = Vector2(
				randi_range(buffer, 1000-buffer), 
				randi_range(buffer, 1000-buffer))
			var closest = 4000
			for light in lights:
				var d = (light.position - sprite.position).length()
				if d < closest:
					closest = d
			if closest > min_distance:
				needs_spread = false
		
		sprite.scale = Vector2(0.3, 0.3)
		
		var s = light_on_tex.get_height() * sprite.scale.x
		top_points.append(Vector2(sprite.position.x, sprite.position.y - s / 2))
		
		var lit = randi_range(0,1)
		if lit:
			sprite.texture = light_on_tex
			amount_on += 1
		else:
			sprite.texture = light_off_tex
		add_child(sprite)
		lights.append(sprite)
	
	percentage = amount_on / lights_num * 100
	
	var lit = randi_range(0,1)
	var type
	if lit:
		type = tr("LIT")
		question_color = Color(150.0 / 255, 120.0 / 255, 0.0 / 255)
		percentage = amount_on / lights_num * 100
	else:
		type = tr("NOTLIT")
		question_color = Color(20.0 / 255, 30.0 / 255, 60.0 / 255)
		percentage = (lights_num - amount_on) / lights_num * 100
	question_text = tr("LIGHTSQ").format({LIT_OR_NOT = type})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func fade_out(prop):
	var left = 1 - prop
	modulate.a = left

func _on_resized():
	for child in get_children():
		child.scale = size / 4000
