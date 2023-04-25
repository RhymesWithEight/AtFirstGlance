extends Control

@export var render_belless : Texture
@export var pulse_belless : Texture

var start_button
var booted = false
var to_start = -1
var elapsed = 0
var mod = Color(0,0,0) : set = set_mod
var printing = 0
var printing_end
var ripped = false
const printing_moves = [
	[0.187, 0.457], 
	[0.617, 1.140], 
	[1.301, 1.462], 
	[1.676, 2.170],
	[2.357, 2.524],
	[2.741, 3.241],
	[3.427, 3.706]]

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if !$Credits.visible and $Stats.anchor_top == 1:
			$Settings.openclose_pressed()
		credits_close()
		$Stats.anchor_top = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Room.modulate = mod
	Music.stop()
	Music.pitch_scale = 1
	Music.volume_db = 0
	get_tree().paused = false
	booted = true
	if Global.high_score <= 1:
		$Room/HighScore.visible = false
		$Room/Score.visible = false
		$Room.texture = render_belless
		$ButtonGlow.texture = pulse_belless
		$BellButton.disabled = true
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
		pulse_glow(delta)
		mod = Color(1,1,1)
	
	if printing > 0:
		var elapsed = 5 - printing
		for range in printing_moves:
			if elapsed > range[0] and elapsed < range[1]:
				$Stats.anchor_top -= delta * 0.2
		printing -= delta
		if elapsed > 4.0:
			if !$RipSound.playing:
				if !ripped:
					$RipSound.play()
					ripped = true
			else:
				var past = elapsed - 4
				$Stats.rotation_degrees = pow(4*past, 3)
		if elapsed > 4.3:
			$Stats.anchor_top = clamp($Stats.anchor_top - delta * 0.8, 0, 1)
			if elapsed >= 5:
				$Stats.anchor_top = 0
			if $Stats.anchor_top == 0:
				printing = 0
				$PrintSound.stop()
				ripped = false
				$Stats.draggable = true

func pulse_glow(delta):
	if $ButtonGlow.modulate.g == 0:
		$ButtonGlow.modulate.a += delta / 3
		if $ButtonGlow.modulate.a >= 1:
			$ButtonGlow.modulate.g = 1
	else:
		$ButtonGlow.modulate.a -= delta / 3
		if $ButtonGlow.modulate.a <= 0:
			$ButtonGlow.modulate.g = 0

func _on_button_pressed():
	$ButtonSound.play()
	$ButtonSound.seek(0.06)
	to_start = 1

func set_mod(new_mod):
	$Room.modulate = new_mod
	$Stats.modulate = new_mod
	if to_start > 0:
		$ButtonGlow.modulate.a = pow(new_mod.r, 0.2)
	mod = new_mod

func credits_close():
	$Credits.visible = false

func credits_open():
	$Credits.visible = true



func _on_bell_button_pressed():
	if printing == 0:
		$Stats.draggable = false
		$BellSound.play()
		$BellSound.seek(0.3)
		printing = 5
		$PrintSound.play()
