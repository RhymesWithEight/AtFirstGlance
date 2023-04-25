extends Control

signal quit

@export var circle : Texture
@export var checked : Texture
@export var smudged : Texture
@export var hide_quit = false
@export var paper_sounds : Array[AudioStreamMP3]
@export var paper_slide_sounds : Array[AudioStreamMP3]

var t = preload("res://Themes/Form.tres")
@export var play : Texture
@export var pause : Texture
@export var down = Texture

var votes_to_quit = {1:false, 2:false, 3:false}
var scribble_playing = 0

const time_to_set = 0.4
const goal_rot = 1.0
const goal_pos = Vector2(10.0,10.0)
const box_sizes = {
	"MasterLabel": 150, 
	"EffectLabel": 150, 
	"MusicLabel": 150,
	"LangLabel": 250,
	"TutorialLabel": 100,
	"OutOfGame": 0,
	"Quit1": 100,
	"Quit2": 100,
	"Quit3": 150}
var text_nodes = [
	"Admin", 
	"WaffleTop", 
	"Start", 
	"MasterLabel",
	"EffectLabel", 
	"MusicLabel", 
	"LangLabel",
	"TutorialLabel",
	"OutOfGame", 
	"Quit1", 
	"Quit2", 
	"Quit3"
]

var time_vis = 0.0
var origin_pos = Vector2(-2200.0, 1000.0)
var origin_rot = -45.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if hide_quit:
		%Quit1.visible = false
		%Quit2.visible = false
		%Quit3.visible = false
		%OutOfGame.visible = true
		%TutorialLabel.visible = true
	# Adjusts the starting checkmarks of the tutorial buttons
	if Global.tutorial:
		%TutorialLabel/Yes.icon = checked
		%TutorialLabel/No.icon = circle
	setup_languages()

## Makes the boxes a lil bigger for longer text. Should account for text length changing & languages.
func adjust_lines():
	await get_tree().process_frame
	for child in $Page/Contents.get_children():
		child.custom_minimum_size.y = box_sizes[child.name] + child.get_line_count() * 50

## Creates the language buttons based on available translations
func setup_languages():
	for locale in TranslationServer.get_loaded_locales():
		var button = Button.new()
		var tra = TranslationServer.get_translation_object(locale)
		button.name = locale
		button.text = " " + tra.get_message(TranslationServer.get_locale_name(locale))
		button.theme = t
		button.size_flags_horizontal = 2
		button.focus_mode = Control.FOCUS_NONE
		button.icon = circle
		%LangLabel/Languages.add_child(button)
		button.pressed.connect(change_language.bind(button.name))
		
		if locale == TranslationServer.get_locale().left(2):
			button.icon = checked
			button.disabled = true

## Changes the language.
func change_language(new_language):
	paper_sounds.shuffle()
	$PaperSound.stream = paper_sounds[0]
	$PaperSound.play()
	
	for child in %LangLabel/Languages.get_children():
		child.disabled = false
		child.icon = circle
		if child.name == new_language:
			child.icon = checked
			child.disabled = true
	
	Global.lang = new_language
	reset_buttons()
	adjust_lines()
	
	$Blackout.color.a = 1
	await $PaperSound.finished
	set_start_pos()
	time_vis = 0

## Resets the buttons so it looks like a fresh sheet of paper
func reset_buttons():
	%MasterLabel/MasterButtons.reset_buttons()
	%EffectLabel/EffectButtons.reset_buttons()
	%MusicLabel/MusicButtons.reset_buttons()
	%Quit1/No.icon = checked
	%Quit1/Yes.icon = circle
	%Quit2/No.icon = checked
	%Quit2/Yes.icon = circle
	%Quit3/VolumeButtons.reset_buttons()
	if Global.tutorial:
		%TutorialLabel/Yes.icon = checked
		%TutorialLabel/No.icon = circle
	else:
		%TutorialLabel/Yes.icon = circle
		%TutorialLabel/No.icon = checked
	votes_to_quit = {1:false, 2:false, 3:false}

## Makes and randomizes the slide sound for the sheet entering frame
func paper_slide():
	paper_slide_sounds.shuffle()
	$PaperSlideSound.stream = paper_slide_sounds[0]
	$PaperSlideSound.play()

## Sets the start position of the paper for it to slide in
func set_start_pos():
	paper_slide()
	$Page.position = Vector2(-2200, randi_range(-1000, 1000))
	origin_pos = $Page.position
	$Page.rotation_degrees = -45.0
	origin_rot = $Page.rotation_degrees

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Background.visible:
		if time_vis <= time_to_set:
			time_vis += delta
			var b = 0.1
			var a = b + b * b / time_to_set
			var c = - b / time_to_set
			var diff = a / (b + time_vis) + c
			$Page.rotation_degrees = lerp(origin_rot, goal_rot, 1 - diff)
			$Page.position.x = lerp(origin_pos.x, goal_pos.x, 1 - diff)
			$Page.position.y = lerp(origin_pos.y, goal_pos.y, 1 - diff)
			flicker_lights(time_vis / time_to_set)
		elif !$PaperSound.playing:
			$Blackout.color.a = 0
			$Page.position = goal_pos
			$Page.rotation_degrees = goal_rot
	if $ScribbleSound.playing:
		scribble_playing += delta
		if scribble_playing > 0.5:
			$ScribbleSound.stop()
			scribble_playing = 0

## Settings open button pressed. Saves when closed.
func openclose_pressed():
	set_start_pos()
	$ClickUp.play()
	$Background.visible = !$Background.visible
	if $Background.visible:
		adjust_lines()
		get_tree().paused = true
		$OpenClose.icon = play
		time_vis = 0
	else:
		get_tree().paused = false
		$OpenClose.icon = pause

## Pullchain down noise, changes icon
func _on_open_close_button_down():
	$OpenClose.icon = down
	$ClickDown.play()


## Master volume slider moved.
func master_vol_changed(value):
	Global.master_vol = value
	scribble()

## Effect volume slider moved.
func effect_vol_changed(value):
	Global.effect_vol = value
	scribble()

## Music volume slider moved.
func music_vol_changed(value):
	Global.music_vol = value
	scribble()

## Scribble noise. Saves unless it's from a quit button.
func scribble(save = true):
	if save:
		Global.save_game()
	$ScribbleSound.play()
	$ScribbleSound.seek(randf_range(0.0, 16.0))

## Processes quit button press. Quits the game if all three pressed.
func on_quit_pressed(number, quitnum):
	scribble(false)
	#Add or remove a vote to quit
	if number == 100:
		votes_to_quit[quitnum] = true
		
		#Check if you have all three votes
		var votes = 0
		for num in votes_to_quit:
			if votes_to_quit[num]:
				votes += 1
		if votes == 3:
			quit.emit()
		
	else:
		votes_to_quit[quitnum] = false
	
	#Some weird stuff because I don't know how to use button groups all that well lol
	if quitnum == 1 or quitnum == 2:
		var target = $Page.find_child("Quit" + str(quitnum))
		var yes = target.find_child("Yes")
		var no = target.find_child("No")
		if number == 100:
			yes.icon = checked
			no.icon = smudged
		else:
			yes.icon = smudged
			no.icon = checked

## Flickers the lights on like an old light
func flicker_lights(progress):
	if !hide_quit:
		var dip_a = randf_range(0, 1)
		var dip_b = randf_range(0, 1)
		var threshold = 0.8
		var a = 1 - 1 / (1 + 100 * pow(progress - dip_a, 2))
		var b = 1 - 1 / (1 + 100 * pow(progress - dip_b, 2))
		if a * b > threshold:
			var c = a * b * pow(progress, 3) * 0.5
			$Blackout.color.a = 0.2 - c
		else:
			$Blackout.color.a = 0
	else:
		$Blackout.color.a = 0

func change_icons(group, pressed):
	for button in group:
		if button.icon == checked:
			button.icon = smudged
	
	pressed.icon = checked

## Ties page visibility to background visibility
func _on_background_visibility_changed():
	$Page.visible = $Background.visible

func tutorial_pressed(b):
	var yes = $Page/Contents/TutorialLabel/Yes
	var no = $Page/Contents/TutorialLabel/No
	scribble(false)
	if b:
		if !Global.tutorial:
			no.icon = smudged
		Global.tutorial = true
		change_icons([yes,no], yes)
	else:
		Global.tutorial = false
		change_icons([yes, no], no)

