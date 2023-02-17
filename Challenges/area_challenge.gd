extends TextureRect

var chosen_color
var colors_list = []
var percentage : get = get_percentage
var question_text = tr("AREAQ")
var question_color
var background_color
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var tex = NoiseTexture2D.new()
	tex.width = 500
	tex.height = 500
	tex.generate_mipmaps = false
	
	var noise = FastNoiseLite.new()
	noise.frequency = randf_range(0.0005, 0.002)
	noise.seed = randi()
	
	var gradient = Gradient.new()
	var color_num = randi_range(2, 3)
	var offset_num = color_num - 1
	var offset_width = 0.8 / offset_num
	
	var offsets = []
	var i = 1.0
	while i <= offset_num:
		var place = randf_range((i-0.9) * offset_width, (i+0.1) * offset_width)
		offsets.append(place)
		offsets.append(place)
		i += 1
	
	gradient.offsets = offsets
	
	i = 1.0
	var colors = Global.generate_colors(color_num)
	
	chosen_color = colors[0]
	colors_list = colors
	
	colors.shuffle()
	var colors_dup = []
	
	i = 0
	while i < colors.size():
		colors_dup.append(colors[i])
		if i > 0 and i < colors.size() - 1:
			colors_dup.append(colors[i])
		i += 1
	
	gradient.colors = colors_dup
	
	tex.color_ramp = gradient
	tex.noise = noise
	
	question_color = chosen_color
	background_color = Color.from_hsv(randf(), randf(), randf_range(0.1, 0.2))
	
	texture = tex
	

func get_percentage():
	var image = texture.get_image().duplicate()
	image.shrink_x2()
	var image_size = image.get_size()
	var num = 0.0
	var x = 0
	var y = 0
	while y < image_size.y:
		x = 0
		while x < image_size.x:
			if abs(image.get_pixel(x, y).h - chosen_color.h) < 0.01:
				num += 1
			x += 1
		y += 1
	return num / (image_size.x * image_size.y) * 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func fade_out(prop):
	var left = 1 - prop
	modulate.a = left
