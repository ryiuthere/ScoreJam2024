extends Control


signal start_game 
@onready var transitioning := false

@onready var is_adjustable_selected := false
@onready var music_volume : int
@onready var sfx_volume : int

@onready var setting_name := false
var player_name : String

const LABEL_COLOR := Color(1.0, 1.0, 1.0, 0.11)
const LABEL_HIGHLIGHT := Color(0.68, 1.0, 0.96, 0.85)

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
	for text_label in selections.get_children():
		menu_selections.append(text_label)
	if menu_selections:
		menu_current_index = 0
		for text in menu_selections:
			text.label_settings.font_color = LABEL_COLOR
		menu_selections[0].label_settings.font_color = LABEL_HIGHLIGHT
	if not music_volume:
		music_volume = 100
	if not sfx_volume:
		sfx_volume = 100
	
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
	menu_functions = [[start], [set_player_name], [set_text_options, reset_pos, reset_label_colors], [], []]
	menu_properties = [[], [], [], [], []]
	menu_selections[0].text = "Start"
	menu_selections[1].text = "Set Name"
	menu_selections[2].text = "Options"
	menu_selections[3].text = "Leaderboards"
	menu_selections[4].text = ""
	
func set_text_options():
	menu_functions = [[set_text_home, reset_pos, reset_label_colors], [], [], [], []]
	menu_properties = [[], [], [music_volume], [sfx_volume], []]
	menu_selections[0].text = "Back"
	menu_selections[1].text = "Controls"
	menu_selections[2].text = "Music - ‹%s›" % music_volume
	menu_selections[3].text = "SFX - ‹%s›" % sfx_volume
	menu_selections[4].text = ""
