extends Control

var min_x := -1500.0
var max_x := 40

var t := 0.0
const max_t := 3.0

func _ready():
	$AudioStreamPlayer.play(0.7)

func _process(delta):
	t += delta
	var progress = clamp(abs(max_t / 2 - t) - max_t / 2 + 1, 0.0, 1.0)
	move_slide(progress)
	if t > max_t:
		get_tree().change_scene_to_file("res://main_screen.tscn")
	
	if t > max_t - 1 and !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func move_slide(progress: float):
	var retro_over = 0.2
	var a = max_x - min_x
	var c = retro_over / 2
	var b = (-a / min_x - 1) / pow(c, 2)
	$Slide.position.x = a / (1 + b * pow(progress - c, 2)) + min_x + 40
