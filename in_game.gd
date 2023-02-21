extends Control

## All of the prepared challenges.
@export var challenges : Array[PackedScene]

var current_time = 0
var score = 0 : set = update_score
const error_min_alpha = 0.3
var total_error = 0 : set = update_total_error
var guess = 0 : set = update_guess
var error_left
var error_right
var challenge

var lost = false

var error
var error_num = 0 : get = get_error_num
var prev_background_color = Color(0,0,0)
var next_background_color = Color(0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var image = Image.create(1000, 1000, true, Image.FORMAT_RGB8)
	$Slide/SlideContents.texture = ImageTexture.create_from_image(image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time -= delta
	if current_time >= 0:
		phase_1(current_time)
		if Global.tutorial:
			$Tutorial.visible = true
			get_tree().paused = true
	elif current_time >= -0.5:
		phase_2(-2 * current_time)
	elif current_time >= -1:
		phase_3(-2 * current_time - 1)
	elif current_time >= -1.5:
		phase_4(-2 * current_time - 2)
	else:
		phase_5(-2 * current_time - 3)
	
	if !lost:
		ramp_up_fan(delta)
		if -2 >= current_time:
			current_time = 4.0
	else:
		ramp_down_fan(delta)

## First part of a round. Resets the parts to the right location & updates the timer.
func phase_1(time):
	if !Music.playing:
		Global.play_new_music()
	reset_parts()
	update_timer(time)

## Second part of a round. 
## Starts fading out the question & timer, & calculates the error.
func phase_2(progress):
	fade_out(progress / 2)
	if error == null:
		calculate_error()
	else:
		expand_error(progress / 0.2)

## Third part of a round. 
## Finishes fading out, moves slide off screen.
func phase_3(progress):
	fade_out(progress / 2 + 0.5)
	next_background_color = Color(0,0,0)
	$Guess.modulate.a = 1 - progress
	if !$SlideChange.playing:
		$SlideChange.playing = true
	move_challenge(progress)

## Fourth part of a round. 
## Starts moving the error bar and gets rid of the old slide.
func phase_4(progress):
	move_error(progress / 2)
	$Timer.modulate.a = 0
	$QuestionBox.modulate.a = 0
	if !lost:
		$Slide.position.x = -1500
		if challenge != null:
			challenge.queue_free()
			if total_error >= 100:
				lost = true

## Fifth and final part of a round.
## Finishes moving the error bar, creates the next challenge, and moves it in place.
func phase_5(progress):
	if lost:
		lose()
	move_error(progress / 2 + 0.5)
	if total_error + abs(error_num) < 100:
		flicker_lights(progress)
	if challenge == null:
		next_challenge()
	else:
		move_challenge(1 - progress)

## Ramps up fan noise.
func ramp_up_fan(delta):
	if !lost:
		if $FanNoise.pitch_scale <= 1:
			$FanNoise.pitch_scale += delta
		else:
			$FanNoise.pitch_scale = 1

## Ramps down fan noise.
func ramp_down_fan(delta):
	if $FanNoise.pitch_scale >= 0.3:
		$FanNoise.pitch_scale -= 2 * delta
		Music.pitch_scale -= 2 * delta
		Music.volume_db -= 3 * delta
	else:
		Music.stop()
		
	$FanNoise.volume_db -= 5 * delta

## Calculates the guess's error and places the error bar.
func calculate_error():
	if total_error <= 100 and challenge != null:
		error = challenge.percentage - guess
		Global.log_error(challenge.name, error)
		
		$Error.color = Color.RED
		$Error.color.a = error_min_alpha
		if error > 0:
			error_right = $Guess.anchor_right + abs(error) / 100
			error_left = $Guess.anchor_right
		elif error < 0:
			error_left = $Guess.anchor_right - abs(error) / 100
			error_right = $Guess.anchor_right
		
		$Error.anchor_left = $Guess.anchor_right
		$Error.anchor_right = $Guess.anchor_right

func expand_error(progress):
	if progress <= 1:
		if error > 0:
			$Error.anchor_right = error_left + progress * (error_right - error_left)
		else:
			$Error.anchor_left = error_right - progress * (error_right - error_left)
	else:
		$Error.anchor_right = error_right
		$Error.anchor_left = error_left

## Moves the error bar every frame, down to the total error at the bottom.
func move_error(progress):
	if error != null:
		$Error.anchor_top = pow(progress, 2)
		$Error.anchor_bottom = 2*progress - 2 * progress + 1
		
		$Error.color.a = -1 * (1 - error_min_alpha) * pow(progress - 1, 2) + 1
		var distance = error_left - $TotalError.anchor_right
		$Error.anchor_left = $TotalError.anchor_right + distance * pow(1 - progress, 2)
		$Error.anchor_right = $Error.anchor_left + abs(error) / 100
		if progress >= 1:
			total_error += abs(error)
			error = null

## Instantiates the next challenge, or a scorecard if you lost.
func next_challenge():
	guess = 0
	if total_error + abs(error_num) < 100:
		create_challengecard()
		score += 1
	else:
		prev_background_color = next_background_color
		next_background_color = Color(0.1, 0.08, 0.05)
		create_scorecard()

## Creates a challenge & puts it on the slide
func create_challengecard():
	var index = randi_range(0, challenges.size() - 1)
	var Draw = challenges[index]
	var new_challenge = Draw.instantiate()
	$Screenshotter.add_child(new_challenge)
	new_challenge.position = Vector2(0,0)
	challenge = new_challenge
	$QuestionBox/Question.text = challenge.question_text
	$QuestionBox.self_modulate = challenge.question_color
	$QuestionBox.modulate.a = 0
	prev_background_color = next_background_color
	next_background_color = challenge.question_color.darkened(0.8)
	
	$Screenshotter.render_target_update_mode = 1
	await get_tree().process_frame
	
	var scrsht = $Screenshotter.get_texture().get_image()
	scrsht.generate_mipmaps()
	$Slide/SlideContents.texture.update(scrsht)

## Creates a scorecard & puts it on the slide
func create_scorecard():
	$Slide/SlideContents.visible = false
	var date = Global.date
	var today_score = Label.new()
	challenge = today_score
	today_score.text = tr("SCORE") + str(score)
	today_score.anchor_right = 0.5
	today_score.anchor_top = 0.1
	var today_date = Label.new()
	today_date.text = str(date)
	today_date.anchor_right = 1.0
	today_date.anchor_left = 0.5
	today_date.anchor_top = 0.1
	var celebrate = Label.new()
	celebrate.anchor_right = 1.0
	celebrate.anchor_top = 0.4
	var labels = [today_score, today_date, celebrate]
	
	if score <= Global.high_score:
		var highest_score = Label.new()
		highest_score.anchor_top = 0.6
		highest_score.anchor_right = 0.5
		var highest_date = Label.new()
		highest_date.anchor_top = 0.6
		highest_date.anchor_left = 0.5
		highest_date.anchor_right = 1.0
		labels.append(highest_score)
		labels.append(highest_date)
		highest_score.text = tr("SCORE") + str(Global.high_score)
		highest_date.text = Global.high_score_date
		celebrate.text = tr("HIGHESTSCORE")
		if score == Global.high_score:
			Global.set_saveable("high_score", score)
	else:
		celebrate.text = tr("NEWHIGHSCORE")
		Global.set_saveable("high_score", score)
		Global.set_saveable("high_score_date", Global.date)
	
	for label in labels:
		label.theme = load("res://Themes/Theme.tres")
		label.horizontal_alignment = 1
		$Slide.add_child(label)
	
	Global.set_saveable("current_score", 0)

## Fades out the timer & question box
func fade_out(progress):
	if total_error < 100 and challenge != null:
		$Timer.text = "0.0"
		$Timer.modulate.a = 1 - progress
		$QuestionBox.modulate.a = 1 - progress

## Flickers the question box on like an old light
func flicker_lights(progress):
	var dip_a = randf_range(0, 1)
	var dip_b = randf_range(0, 1)
	var threshold = 0.8
	var a = 1 - 1 / (1 + 100 * pow(progress - dip_a, 2))
	var b = 1 - 1 / (1 + 100 * pow(progress - dip_b, 2))
	if a * b > threshold:
		$QuestionBox.modulate.a = 0.2 + a * b * pow(progress, 3) * 0.5
	else:
		$QuestionBox.modulate.a = 0

## Moves the challenge and updates screen. argument between -0.5 to -1.0
func move_challenge(progress):
	if challenge != null or lost:
		var max_x = 40
		var min_x = -1500.0
		var retro_over = 0.2
		var a = max_x - min_x
		var c = retro_over / 2
		var b = (-a / min_x - 1) / pow(c, 2)
		$Slide.position.x = a / (1 + b * pow(progress - c, 2)) + min_x
		update_colors(progress)

## Updates the colors of the background nodes
func update_colors(progress):
	var color = next_background_color.lerp(prev_background_color, progress)
	$Background.color = color
	$Screen.modulate = color
	$Slide/SlideBody.self_modulate = color.lightened(0.2)

## Changes the timer value
func update_timer(new_time):
	var time_text = str(roundf(new_time*10)/10)
	if time_text.length() == 1:
		time_text += ".0"
	$Timer.text = time_text

## Moves everything to where it should be when the guessing is up
func reset_parts():
	update_colors(0)
	$Slide.position.x = -40
	$Timer.modulate.a = 1
	
	if total_error + abs(error_num) < 100:
		$QuestionBox.modulate.a = 1
	else:
		$QuestionBox.modulate.a = 0
	$Error.anchor_top = 0
	$Error.anchor_left = 0
	$Error.anchor_right = 0
	$Error.anchor_bottom = 1
	$Error.color.a = error_min_alpha
	$Guess.modulate.a = 1

## Setter for guess. Moves the guess bar
func update_guess(new_guess):
	$Guess.anchor_right = new_guess / 100
	guess = new_guess

## Setter for total error. Automates lose condition & moves total error bar
func update_total_error(new_total_error):
	$TotalError.anchor_right = float(new_total_error) / 100
	total_error = new_total_error

## Setter for score, changes the score text.
func update_score(new_score):
	$Score.text = str(new_score)
	Global.set_saveable("current_score", new_score)
	Global.set_saveable("current_score_date", Global.date)
	score = new_score
	

## Getter for error num, a version of error that always returns a number
func get_error_num():
	if error == null:
		return 0
	else:
		return error

## Allows the player to guess
func _unhandled_input(event):
	if current_time > 0:
		var new_locale
		if event is InputEventScreenTouch:
			if event.pressed:
				new_locale = event.position.x / 10.8
		if event is InputEventScreenDrag:
			new_locale = event.position.x / 10.8
		
		if new_locale is float:
			if !(event.position.x > 955 and event.position.y < 225 and event.position.y > 100):
				guess = new_locale

## Brings you back to the main screen.
func lose():
	get_tree().change_scene_to_file("res://main_screen.tscn")

## Finishes the tutorial
func _on_tutorial_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		Global.tutorial = false
		$Tutorial.visible = false
		get_tree().paused = false
		_unhandled_input(event)
