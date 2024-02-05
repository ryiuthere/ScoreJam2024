extends Control


signal start_game 
@onready var transitioning := false

# enum OPTIONS_MENU {BACK, CONTROLS, MUSIC_VOLUME, SFX_VOLUME}
# enum LEADERBOARDS_MENU {BACK, FIRST, SECOND, THIRD, YOU}

const LABEL_COLOR := Color(1.0, 1.0, 1.0, 0.11)
const LABEL_HIGHLIGHT := Color(1.0, 1.0, 1.0, 0.85)
var menu_functions := []

@onready var selections = $HomeMenu/ContentMargin/Selections
@onready var menu_selections := []
var menu_current_index : int

const jump_sound := preload("res://Assets/Raw/jump.wav") as AudioStreamWAV
const sfx_player := preload("res://Assets/Scenes/SFXPlayer.tscn") as PackedScene

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
	
	set_text_home()
	$IntroMusic.play()
	request_ready()

func _input(event):
	if event.is_action_pressed("down"):
		play_jump()
		change_menu_index(1)
	elif event.is_action_pressed("up"):
		play_jump()
		change_menu_index(-1)
	elif event.is_action_pressed("enter") or event.is_action_pressed("jump"):
		for function in menu_functions[menu_current_index]:
			function.call()
		
func change_menu_index(amount: int) -> void:
	menu_selections[menu_current_index].label_settings.font_color = LABEL_COLOR
	while true:
		menu_current_index = (menu_current_index + amount) % len(menu_selections)
		if menu_current_index < 0:
			menu_current_index += len(menu_selections)
		if menu_selections[menu_current_index].text != "":
			break
	menu_selections[menu_current_index].label_settings.font_color = LABEL_HIGHLIGHT

func _on_music_finished():
	$LoopMusic.play()
	
func start(): 
	if not transitioning:
		transitioning = true
		start_game.emit()

func set_text_home():
	menu_functions = [[start], [], [], [], []]
	menu_selections[0].text = "Start"
	menu_selections[1].text = "Set Name"
	menu_selections[2].text = "Options"
	menu_selections[3].text = "Leaderboards"
	menu_selections[4].text = ""
