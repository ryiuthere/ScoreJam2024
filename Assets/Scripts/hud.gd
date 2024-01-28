extends Control

var fuelbar : Sprite2D
@export var player_node : CharacterBody2D

func _ready():
	fuelbar = %Fuelbar
	set_fuel(1.0)
	
func _process(_delta):
	set_fuel(player_node.fuel_amt)

func set_fuel(amt):
	fuelbar.material.set_shader_parameter("fuel_amt", amt)
