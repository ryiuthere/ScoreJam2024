extends Node2D

var gameplay_scene = preload("res://Assets/Scenes/Gameplay.tscn").instantiate()
var mainmenu_scene = preload("res://Assets/Scenes/MainMenu.tscn").instantiate()

var current_scene = mainmenu_scene
@onready var loading_screen_timer := $LoadingTimer
@onready var loading_screen_cover := $ScreenCover

func _ready():
	add_child(mainmenu_scene)
	mainmenu_scene.start_game.connect(_on_transition)
	gameplay_scene.return_to_main.connect(_on_transition)
	gameplay_scene.ready.connect(_on_load_completed)
	mainmenu_scene.ready.connect(_on_load_completed)

func switch_to_scene(target: Node) -> void:
	remove_child(current_scene)
	add_child(target)
	current_scene = target
	
func play_unloading_animation() -> void:
	loading_screen_timer.start()
	var tween = create_tween() 
	tween.tween_property(loading_screen_cover, "color", Color(0.0, 0.0, 0.0, 1.0), (loading_screen_timer.wait_time/1.8))
	
func play_loading_animation() -> void:
	var tween = create_tween() 
	tween.tween_property(loading_screen_cover, "color", Color(0.0, 0.0, 0.0, 0.0), (loading_screen_timer.wait_time/1.5))

func _on_loading_timer_timeout():
	if current_scene == mainmenu_scene:
		switch_to_scene(gameplay_scene)
	elif current_scene == gameplay_scene:
		switch_to_scene(mainmenu_scene)

func _on_transition() -> void:
	play_unloading_animation()
	
func _on_load_completed() -> void:
	play_loading_animation()
