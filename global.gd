extends Node

signal lang_changed

var music_vol = 100 : set = change_music_vol
var effect_vol = 100 : set = change_effect_vol
var master_vol = 100 : set = change_master_vol
var high_score = 0
var high_score_date
var current_score = 0
var current_score_date
var resolution : get = get_resolution
var date : get = get_date
var tutorial = false
var lang = "en" : set = change_lang

## An array of errors for each challenge, for stats purposes.
var challenge_errors = {} 

@export var music : Array[AudioStream]
var played = [] : set = update_played
var saved = false

## Animal pngs for the animal challenge. Loaded here to save load time in game. In theory.
@export var animals : Dictionary

const palette_centers = [0.0, 0.5, 0.75]

const xyz_to_rgb_matrix = Basis(
	Vector3(3.2404542, -1.5371385, -0.4985314),
	Vector3(-0.9692660, 1.8760108, 0.0415560),
	Vector3(0.0556434, -0.2040259, 1.0572252)
	)

const p_copun = Vector2(0.747, 0.253)
const d_copun = Vector2(1.080, -0.800)
const t_copun = Vector2(0.171, 0.000)

var saveable = [
	"music_vol", 
	"effect_vol", 
	"master_vol", 
	"high_score", 
	"high_score_date",
	"current_score",
	"current_score_date",
	"challenge_errors",
	"lang"
	]


func set_saveable(variable : String, new_val):
	set(variable, new_val)
	if !saved:
		save_game()
		saved = true

func change_master_vol(new_vol):
	AudioServer.set_bus_volume_db(0, (new_vol - 100) * 0.4)
	if new_vol == 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
	master_vol = new_vol

func change_effect_vol(new_vol):
	AudioServer.set_bus_volume_db(1, (new_vol - 100) * 0.4)
	if new_vol == 0:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	effect_vol = new_vol

func change_music_vol(new_vol):
	AudioServer.set_bus_volume_db(2, (new_vol - 100) * 0.4)
	if new_vol == 0:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	music_vol = new_vol

func _ready():
	load_game()
	if high_score < 2:
		tutorial = true
	music.shuffle()
	Music.stream = music[0]
	played.append(music[0])
	Music.finished.connect(play_new_music)
	
	if current_score > high_score:
		high_score = current_score
		high_score_date = current_score_date
		current_score = 0

func play_new_music():
	var options = music.duplicate()
	if music.size() == played.size():
		played.clear()
	
	for exception in played:
		options.erase(exception)
	
	options.shuffle()
	Music.stream = options[0]
	played.append(options[0])
	Music.play()

func update_played(new_played):
	if new_played.size() == music.size():
		played = []
	else:
		played = new_played

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if saved:
		saved = false

func change_lang(new_lang):
	TranslationServer.set_locale(new_lang)
	lang = new_lang
	lang_changed.emit(new_lang)
	save_game()

func generate_colors(num_colors):
	var color_picks = []
	var available = palette_centers.duplicate()
	while color_picks.size() < num_colors:
		available.shuffle()
		var hue = available.pop_back() + randf_range(0, 0.05)
		var sat = 0.6 + randf_range(-0.1, 0.1)
		var val = 0.7 + randf_range(-0.1, 0.1)
		color_picks.append(Color.from_hsv(hue, sat, val))
	return color_picks

func get_n_items_from_array(n : int, array : Array):
	var result = []
	var available = array.duplicate()
	var i = 1
	while i <= n:
		available.shuffle()
		result.append(available.pop_back())
		i += 1
	return result

func get_resolution():
	return get_viewport().get_visible_rect().size

func heaviside(value):
	if value > 0:
		return 1
	else:
		return 0

func get_date():
	var new_date = Time.get_date_dict_from_system()
	return str(new_date["month"]) + "/" + str(new_date["day"]) + "/" + str(new_date["year"]).right(2)

## Creates a log of a guess error
func log_error(node_name : String, error : float):
	var chal_name = node_name.trim_suffix("Challenge")
	
	if challenge_errors.has(chal_name):
		challenge_errors[chal_name].push_back(error)
	else:
		challenge_errors[chal_name] = [error]

func save_game():
	var save = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var dict = {}
	for v in saveable:
		dict[v] = get(v)
	
	var json_string = JSON.stringify(dict)
	save.store_line(json_string)

func load_game():
	var save = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save != null:
		var json_string = save.get_line()
		var dict = JSON.parse_string(json_string)
		for v in dict:
			set(v, dict[v])
	else:
		lang = OS.get_locale().left(2)
