extends Control


signal start_game 
@onready var transitioning := false

@onready var is_adjustable_selected := false
@onready var music_volume : int
@onready var sfx_volume : int
var fullscreen := false
var initial_loading_for_volume_options := true

@onready var setting_name := false
var player_name : String

const LABEL_COLOR := Color(1.0, 1.0, 1.0, 0.15)

const LABEL_HIGHLIGHT_COLORS := [Color(0.89, 0.47, 0.47, 0.85), Color(0.68, 1.0, 0.96, 0.85), Color(0.89, 0.64, 0.94, 0.85), Color(0.73, 0.86, 0.38, 0.85)]
const SPECIAL_COLOR_LOL := Color(1.0, 0.96, 0.45, 0.85)
var LABEL_HIGHLIGHT : Color
var last_highlight_index : int

var menu_functions := []
var menu_properties := []

@onready var selections = $HomeMenu/ContentMargin/Selections
@onready var menu_selections := []
var menu_current_index : int

const jump_sound := preload("res://Assets/Raw/jump.wav") as AudioStreamWAV
const pickup_sound := preload("res://Assets/Raw/pickupGas.wav") as AudioStreamWAV
const sfx_player := preload("res://Assets/Scenes/SFXPlayer.tscn") as PackedScene



func play_pickup() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(pickup_sound)

func play_jump() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(jump_sound)

func _ready():
	var rng = RandomNumberGenerator.new()
	var choice = rng.randi_range(0, len(LABEL_HIGHLIGHT_COLORS)-1)
	if choice == last_highlight_index:
		choice = (choice + 1)%len(LABEL_HIGHLIGHT_COLORS)
	last_highlight_index = choice
	LABEL_HIGHLIGHT = LABEL_HIGHLIGHT_COLORS[choice]
	
	if rng.randi_range(0, 49) == 49:
		LABEL_HIGHLIGHT = SPECIAL_COLOR_LOL
	for text_label in selections.get_children():
		menu_selections.append(text_label)
	if menu_selections:
		menu_current_index = 0
		for text in menu_selections:
			text.label_settings.font_color = LABEL_COLOR
		menu_selections[0].label_settings.font_color = LABEL_HIGHLIGHT
	
	if initial_loading_for_volume_options:
		music_volume = 100
		sfx_volume = 100
		initial_loading_for_volume_options = false
	
	set_text_home()
	$IntroMusic.play()
	request_ready()

func _input(event):
	if transitioning:
		return
	if setting_name:
		if event.is_action_pressed("escape") or event.is_action_pressed("enter") or event.is_action_pressed("jump"):
			if len(player_name) < 3:
				player_name = ""
			play_pickup()
			setting_name = false
			set_text_home()
			$SetNameScreen.visible = false
		elif event is InputEventKey and event.keycode >= 65 and event.keycode <= 90 and not event.echo and event.pressed:
			if len(player_name) < 3:
				player_name += event.as_text()
				var txt = ("Enter a name:\n\n%s" % player_name)
				for i in range((3-len(player_name))):
					txt += "_"
				$SetNameScreen/SetNameText.text = txt
		elif event is InputEventKey and event.keycode == 4194308 and not event.echo and event.pressed:
			if len(player_name) >= 1:
				player_name = player_name.left(-1)
				var txt = ("Enter a name:\n\n%s" % player_name)
				for i in range((3-len(player_name))):
					txt += "_"
				$SetNameScreen/SetNameText.text = txt
		return 
	if is_adjustable_selected:
		if event.is_action_pressed("right"):
			play_jump()
			if menu_current_index == 2:
				var new_vol = min(menu_properties[menu_current_index][0] + 10, 100)
				music_volume = new_vol
				AudioServer.set_bus_volume_db(1, linear_to_db(new_vol/100.0))
			else:
				var new_vol = min(menu_properties[menu_current_index][0] + 10, 100)
				sfx_volume = new_vol
				AudioServer.set_bus_volume_db(2, linear_to_db(new_vol/100.0))
			set_text_options()
		elif event.is_action_pressed("left"):
			play_jump()
			if menu_current_index == 2:
				var new_vol = max(menu_properties[menu_current_index][0] - 10, 0)
				music_volume = new_vol
				AudioServer.set_bus_volume_db(1, linear_to_db(new_vol/100.0))
			else:
				var new_vol = max(menu_properties[menu_current_index][0] - 10, 0)
				sfx_volume = new_vol
				AudioServer.set_bus_volume_db(2, linear_to_db(new_vol/100.0))
			set_text_options()
			
	if event.is_action_pressed("down"):
		play_jump()
		change_menu_index(1)
	elif event.is_action_pressed("up"):
		play_jump()
		change_menu_index(-1)
	elif event.is_action_pressed("enter") or event.is_action_pressed("jump"):
		var played_sound := false
		for function in menu_functions[menu_current_index]:
			function.call()
			if not played_sound:
				played_sound = true
				play_pickup()
	elif event.is_action_pressed("escape"):
		if menu_functions[0] and menu_functions[0][0] != start:
			menu_functions[0][0].call()
			play_pickup()

func change_menu_index(amount: int) -> void:
	menu_selections[menu_current_index].label_settings.font_color = LABEL_COLOR
	while true:
		menu_current_index = (menu_current_index + amount) % len(menu_selections)
		if menu_current_index < 0:
			menu_current_index += len(menu_selections)
		if menu_selections[menu_current_index].text != "":
			break
	menu_selections[menu_current_index].label_settings.font_color = LABEL_HIGHLIGHT
	if menu_properties[menu_current_index]:
		is_adjustable_selected = true
	else:
		is_adjustable_selected = false

func _on_music_finished():
	$LoopMusic.play()

func start(): 
	if not transitioning:
		transitioning = true
		$IntroMusic.stop()
		$LoopMusic.stop()
		start_game.emit()

func select_adjustable():
	is_adjustable_selected = true

func reset_label_colors():
	for label in menu_selections:
		label.label_settings.font_color = LABEL_COLOR
	menu_selections[0].label_settings.font_color = LABEL_HIGHLIGHT
	
func reset_pos():
	menu_current_index = 0
	
func set_player_name():
	setting_name = true
	$SetNameScreen.visible = true 
	if not player_name:
		$SetNameScreen/SetNameText.text = "Enter a name:\n\n___"

func set_text_home():
	menu_functions = [[start], [set_player_name], [set_text_options, reset_pos, reset_label_colors], [exit_game], []]
	menu_properties = [[], [], [], [], []]
	menu_selections[0].text = "Start"
	if player_name:
		menu_selections[1].text = "Name - [%s]" % player_name
	else:
		menu_selections[1].text = "Set Name"
	menu_selections[2].text = "Options"
	menu_selections[3].text = "Exit"
	menu_selections[4].text = ""
	
func set_text_options():
	var sfx_padding_len = 3-len(str(sfx_volume))
	var mus_padding_len = 3-len(str(music_volume))
	var sfx_padding = ""
	var mus_padding = ""
	for i in range(sfx_padding_len):
		sfx_padding += " "
	for i in range(mus_padding_len):
		mus_padding += " "
	menu_functions = [[set_text_home, reset_pos, reset_label_colors], [change_screen_mode, set_text_options], [], [], []]
	menu_properties = [[], [], [music_volume], [sfx_volume], []]
	menu_selections[0].text = "Back"
	if fullscreen:
		menu_selections[1].text = "Exit Fullscreen"
	else:
		menu_selections[1].text = "Go Fullscreen"
	menu_selections[2].text = "Music - %s‹%s›" % [mus_padding, music_volume]
	menu_selections[3].text = "SFX   - %s‹%s›" % [sfx_padding, sfx_volume]
	menu_selections[4].text = ""

func change_screen_mode():
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = true

func exit_game():
	get_tree().quit()
