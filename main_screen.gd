extends Control

var start_button
var booted = false
var to_start = -1
var elapsed = 0
var mod = Color(0,0,0) : set = set_mod

# Called when the node enters the scene tree for the first time.
func _ready():
	$Room.modulate = mod
	Music.stop()
	Music.pitch_scale = 1
	Music.volume_db = 0
	get_tree().paused = false
	booted = true
	if Global.high_score == 0:
		$Room/HighScore.visible = false
		$Room/Score.visible = false
	else:
		$Room/Score.text = str(Global.high_score)

## Starts the game.
func start_game():
	get_tree().change_scene_to_file("res://in_game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if to_start > 0:
		to_start -= delta
		if to_start <= 0:
			start_game()
		var c = pow(to_start, 15)
		mod = Color(c, c, c)
		$LightBuzz.stop()
	elif elapsed < 1:
		var dip_a = randf_range(0, 1)
		var dip_b = randf_range(0, 1)
		var threshold = 0.7
		var a = 1 - 1 / (1 + 100 * pow(elapsed - dip_a, 2))
		var b = 1 - 1 / (1 + 100 * pow(elapsed - dip_b, 2))
		if a * b > threshold:
			var c = a * b * pow(elapsed, 3) * 0.5
			mod = Color(c,c,c)
		else:
			mod = Color(0,0,0)
		
		if !$LightBuzz.playing:
			$LightBuzz.play()
	else:
		mod = Color(1,1,1)

func _on_button_pressed():
	$ButtonSound.play()
	$ButtonSound.seek(0.06)
	to_start = 1

func set_mod(new_mod):
	$Room.modulate = new_mod
	mod = new_mod

func credits_close():
	$Credits.visible = false

func credits_open():
	$Credits.visible = true
