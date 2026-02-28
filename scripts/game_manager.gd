extends Node2D

class_name GameManager

var player: Player
var dungeon: DungeonGenerator
var current_floor: int = 1
var max_floors: int = 5
var game_state: String = "PLAYING"  # PLAYING, WON, LOST

func _ready():
	print("=== Simple Rogue-like ===")
	print("Floor ", current_floor, "/", max_floors)
	print("WASD to move, survive ", max_floors, " floors!")
	_start_floor()

func _start_floor():
	dungeon = DungeonGenerator.new()
	dungeon.name = "Dungeon"
	add_child(dungeon)
	dungeon.generate(current_floor)
	
	# Create player
	player = Player.new()
	player.name = "Player"
	player.add_to_group("player")
	add_child(player)
	player.grid_position = dungeon.player_start
	player.global_position = Vector2(dungeon.player_start * 32)
	
	# Spawn enemies
	_spawn_enemies()
	
	# Spawn items
	_spawn_items()
	
	print("Floor ", current_floor, " started!")

func _spawn_enemies():
	for pos in dungeon.enemies:
		var enemy = Enemy.new()
		var floor_modifier = current_floor - 1
		var enemy_type = Enemy.EnemyType.SLIME if randf() > 0.3 else Enemy.EnemyType.SKELETON
		enemy.setup(enemy_type, floor_modifier)
		enemy.name = "Enemy"
		enemy.grid_position = pos
		enemy.global_position = Vector2(pos * 32)
		add_child(enemy)

func _spawn_items():
	for pos in dungeon.items:
		# Simple item: health potion
		var item = Node2D.new()
		item.name = "Item"
		item.global_position = Vector2(pos * 32 + Vector2(16, 16))
		add_child(item)

func _process(delta):
	if game_state != "PLAYING":
		return
	
	# Check for stairs
	if dungeon.get_tile(player.grid_position) == DungeonGenerator.Tile.STAIRS:
		_next_floor()
	
	# Simple collision with enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy:
			if player.grid_position == enemy.grid_position:
				var damage = enemy.attack
				player.take_damage(damage)
				# Push enemy away
				enemy.grid_position += Vector2i(randi_range(-1, 1), randi_range(-1, 1))

func _next_floor():
	if current_floor >= max_floors:
		_win_game()
		return
	
	current_floor += 1
	print("=== Going to floor ", current_floor, " ===")
	
	# Clear current floor
	for child in get_children():
		if child != player and child != dungeon:
			child.queue_free()
	
	# Generate new floor
	dungeon.generate(current_floor)
	player.grid_position = dungeon.player_start
	player.global_position = Vector2(dungeon.player_start * 32)
	_spawn_enemies()
	_spawn_items()

func _win_game():
	game_state = "WON"
	print("=== YOU WIN! ===")
	print("Congratulations! You survived all ", max_floor, " floors!")
	get_tree().paused = true
