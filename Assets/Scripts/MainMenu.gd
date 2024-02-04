extends Control

const LABEL_COLOR := Color(1.0, 1.0, 1.0, 0.11)
const LABEL_HIGHLIGHT := Color(1.0, 1.0, 1.0, 0.85)

signal start_game 

@onready var selections = $HomeMenu/ContentMargin/Selections
var menu_selections := []
var menu_current_index : int

func _ready():
	for text_label in selections.get_children():
		menu_selections.append(text_label)
	if menu_selections:
		menu_current_index = 0

func _input(event):
	if event.is_action_pressed("right") or event.is_action_pressed("down"):
		change_menu_index(1)
	elif event.is_action_pressed("left") or event.is_action_pressed("up"):
		change_menu_index(-1)
	elif event.is_action_pressed("enter") or event.is_action_pressed("jump"):
		start_game.emit()
		
func change_menu_index(amount: int) -> void:
	menu_selections[menu_current_index].label_settings.font_color = LABEL_COLOR
	menu_current_index = (menu_current_index + amount) % len(menu_selections)
	menu_selections[menu_current_index].label_settings.font_color = LABEL_HIGHLIGHT
