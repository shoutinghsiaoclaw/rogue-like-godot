extends Node2D

var player: CharacterBody2D
var current_floor: int = 1
var max_floors: int = 5

func _ready():
	print("=== Simple Rogue-like ===")
	print("Floor: ", current_floor, "/", max_floors)
	print("WASD to move")
	generate_floor()

func generate_floor():
	print("Generating floor ", current_floor)
	# TODO: Generate dungeon

func _process(delta):
	pass
