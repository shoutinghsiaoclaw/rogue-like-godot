extends Node2D

func _ready():
	var game = GameManager.new()
	game.name = "Game"
	add_child(game)
