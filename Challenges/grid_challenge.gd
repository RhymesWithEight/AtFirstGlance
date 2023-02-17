extends GridContainer

var chosen_color
var percentage
var question_text = tr("GRIDQ")
var question_color
var background_color
# Called when the node enters the scene tree for the first time.
func _ready():
	var dim = randi_range(3, 8)
	columns = dim
	
	var num_colors = randi_range(2, 3)
	var colors = Global.generate_colors(num_colors)
	chosen_color = colors[0]
	
	add_blocks(dim, colors)
	
	background_color = Color(
		randf_range(0.1, 0.2), 
		randf_range(0.1, 0.2), 
		randf_range(0.1, 0.2))
	
	question_color = chosen_color

func add_blocks(dim, colors):
	var i = 1
	var chosen = 0
	while i <= dim * dim:
		var block = ColorRect.new()
		block.size_flags_horizontal = 3
		block.size_flags_vertical = 3
		var k = randi_range(0, colors.size() - 1)
		var color = colors[k]
		block.color = color
		if k == 0:
			chosen += 1
		block.pivot_offset = block.size / 2
		add_child(block)
		i += 1
	percentage = float(chosen) / (dim * dim) * 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func fade_out(prop):
	var left = 1 - prop
	modulate.a = left
