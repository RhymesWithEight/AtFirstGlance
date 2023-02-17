extends GridContainer

@export var circle : Texture
@export var checked : Texture
@export var smudged : Texture
@export var number_on : int
@export var channel : String
signal volume(number)

var clicked_buttons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.pressed.connect(volume_chosen.bind(child))
	reset_buttons()

func disable():
	for child in get_children():
		child.disabled = true

func reset_buttons():
	clicked_buttons.clear()
	for child in get_children():
		child.icon = circle
		if child.name.to_int() == Global.get(channel + "_vol") or child.name == str(number_on):
			child.icon = checked
			clicked_buttons.append(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func volume_chosen(button, stop_emit = false):
	for others in clicked_buttons:
		others.icon = smudged
	button.icon = checked
	print("button pressed")
	clicked_buttons.append(button)
	if !stop_emit:
		volume.emit(button.name.to_int())

func press(num):
	volume_chosen(find_child(num.to_string()), true)
