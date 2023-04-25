extends TextureRect

@export var t : Theme
var draggable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$StatsGrid.columns = Global.challenge_errors.size() + 1
	create_challenges()
	create_num_times()
	create_avg_error()
	create_percent_abv()
	create_percent_bel()

func create_challenges():
	for challenge in Global.challenge_errors:
		create_label("REP" + challenge.to_upper())

func create_num_times():
	create_label("NUMCHALLENGE", true)
	for challenge in Global.challenge_errors:
		var errors = Global.challenge_errors[challenge]
		var tries = errors.size()
		create_label(str(tries))

func create_avg_error():
	create_label("AVGERROR", true)
	for challenge in Global.challenge_errors:
		var errors = Global.challenge_errors[challenge]
		var abs_total = 0
		for error in errors:
			abs_total += abs(error)
		var avg = abs_total / errors.size()
		create_label(str(int(avg)) + "%")

func create_percent_bel():
	create_label("PERCENTBEL", true)
	for challenge in Global.challenge_errors:
		var errors = Global.challenge_errors[challenge]
		var num = 0.0
		for error in errors:
			if error <= 0:
				num += 1.0
		
		var per = num / errors.size()
		create_label(str(int(per * 100)) + "%")

func create_percent_abv():
	create_label("PERCENTABV", true)
	for challenge in Global.challenge_errors:
		var errors = Global.challenge_errors[challenge]
		var num = 0.0
		for error in errors:
			if error > 0:
				num += 1.0
		
		var per = num / errors.size()
		create_label(str(int(per * 100)) + "%")

func create_label(text: String, wraps = false):
	var label = Label.new()
	label.theme = t
	label.add_theme_font_size_override("font_size", 35)
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_FILL
	if wraps:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
	$StatsGrid.add_child(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	anchor_bottom = anchor_top + 1

func _on_gui_input(event):
	if draggable:
		if event is InputEventScreenDrag:
			var proportion = event.relative.y / Global.resolution.y
			anchor_top = clamp(anchor_top + proportion, 0, 1)
		elif event is InputEventScreenTouch:
			if !event.pressed:
				if anchor_top > 0.3:
					anchor_top = 1
					rotation = 0
				else:
					anchor_top = 0
		
