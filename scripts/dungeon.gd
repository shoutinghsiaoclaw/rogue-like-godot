extends Node2D

class_name DungeonGenerator

const TILE_SIZE: int = 32
const ROOM_WIDTH: int = 15
const ROOM_HEIGHT: int = 10

var grid: Dictionary = {}  # Vector2i -> tile type
var player_start: Vector2i
var enemies: Array = []
var items: Array = []

enum Tile { FLOOR, WALL, DOOR, STAIRS }

func generate(floor: int) -> void:
	print("Generating floor ", floor)
	grid.clear()
	enemies.clear()
	items.clear()
	
	_create_room(Rect2i(2, 2, ROOM_WIDTH, ROOM_HEIGHT))
	player_start = Vector2i(ROOM_WIDTH / 2, ROOM_HEIGHT / 2)
	
	_spawn_enemies(floor)
	_spawn_items(floor)
	
	# Spawn stairs at random floor position
	var stairs_pos = _random_floor_position()
	grid[stairs_pos] = Tile.STAIRS
	print("Dungeon generated! Floor: ", floor)

func _create_room(rect: Rect2i):
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var pos = Vector2i(x, y)
			if x == rect.position.x or x == rect.end.x - 1 or y == rect.position.y or y == rect.end.y - 1:
				grid[pos] = Tile.WALL
			else:
				grid[pos] = Tile.FLOOR

func _random_floor_position() -> Vector2i:
	var attempts = 0
	while attempts < 100:
		var x = randi_range(3, ROOM_WIDTH - 3)
		var y = randi_range(3, ROOM_HEIGHT - 3)
		var pos = Vector2i(x, y)
		if grid.get(pos) == Tile.FLOOR:
			return pos
		attempts += 1
	return Vector2i(5, 5)

func _spawn_enemies(floor: int):
	var enemy_count = 2 + floor
	for i in range(enemy_count):
		var pos = _random_floor_position()
		if pos != player_start:
			enemies.append(pos)
			grid[pos] = Tile.FLOOR  # Keep as floor, spawn enemy separately
	print("Spawned ", enemy_count, " enemies")

func _spawn_items(floor: int):
	var item_count = 1 + floor / 2
	for i in range(item_count):
		var pos = _random_floor_position()
		if pos != player_start and pos not in enemies:
			items.append(pos)
	print("Spawned ", item_count, " items")

func is_walkable(pos: Vector2i) -> bool:
	var tile = grid.get(pos, Tile.WALL)
	return tile == Tile.FLOOR or tile == Tile.STAIRS

func get_tile(pos: Vector2i) -> Tile:
	return grid.get(pos, Tile.WALL)
