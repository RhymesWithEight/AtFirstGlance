extends ColorRect

var percentage
var question_text
const question_color = Color(0.4, 0.4, 0.3)

var picked_animal
const buffer = 150
const scales = {"Giraffe": 0.3, "Elephant": 0.3, "Gazelle": 0.3, "Lion": 0.3, "Ostrich": 0.3}
const plurals = {
	"Giraffe": "GIRAFFES",
	"Elephant": "ELEPHANTS", 
	"Gazelle": "GAZELLES",
	"Lion": "LIONS",
	"Ostrich": "OSTRICHES"}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_animals()
	question_text = tr("ANIMALSQ").format({ANIMAL = tr(plurals[picked_animal])})
	randomize_background()

# Moves the background photo around to simulate different photos
func randomize_background():
	var w = $Background.texture.get_width()
	var h = $Background.texture.get_height()
	
	var x_roll = randi_range(0, w - 1000)
	var y_roll = randi_range(0, h - 1000)
	
	$Background.region_rect.position = Vector2(x_roll, y_roll)

func add_animals():
	var num_animals = randi_range(5, 10)
	var num_types = randi_range(3, 5)
	var num_first = ceil(randf_range(0.2, 0.8) * num_animals)
	percentage = float(num_first) / num_animals * 100
	var available = Global.animals.keys().duplicate()
	while available.size() > num_types:
		available.shuffle()
		available.pop_back()
	var sprites = []
	while sprites.size() < num_animals:
		var animal = Sprite2D.new()
		add_child(animal)
		
		var min_distance = size.length() / num_animals * 0.8
		
		var needs_spread = true
		while needs_spread:
			animal.position = Vector2(
				randi_range(buffer, 1000-buffer), 
				randi_range(buffer, 1000-buffer))
			var closest = 4000
			for sprite in sprites:
				var d = (animal.position - sprite.position).length()
				if d < closest:
					closest = d
			if closest > min_distance:
				needs_spread = false
		
		sprites.append(animal)
		
		var kind
		if sprites.size() <= num_first:
			kind = available[0]
			if sprites.size() == num_first:
				picked_animal = available.pop_front()
		else:
			available.shuffle()
			kind = available[0]
		
		animal.texture = Global.animals[kind]
		animal.scale = Vector2(scales[kind], scales[kind])
		animal.modulate = Color(0.9, 0.85, 0.8)
		animal.rotation_degrees = randi_range(-10, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
