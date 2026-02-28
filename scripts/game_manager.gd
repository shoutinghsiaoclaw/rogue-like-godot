extends Node2D

class_name GameManager

var player: Player
var dungeon: DungeonGenerator
var current_floor: int = 1
var max_floors: int = 5
var game_state: String = "PLAYING"

const TILE_SIZE: int = 32

func _ready():
	print("=== Simple Rogue-like ===")
	print("Floor ", current_floor, "/", max_floors)
	print("WASD to move, SPACE to attack")
	print("Survive ", max_floors, " floors to win!")
	_start_floor()

func _start_floor():
	game_state = "PLAYING"
	
	# Create dungeon
	dungeon = DungeonGenerator.new()
	dungeon.name = "Dungeon"
	add_child(dungeon)
	dungeon.generate(current_floor)
	
	# Draw dungeon tiles
	_draw_dungeon()
	
	# Create player
	player = Player.new()
	player.name = "Player"
	player.add_to_group("player")
	add_child(player)
	player.grid_position = dungeon.player_start
	player.global_position = Vector2(dungeon.player_start * TILE_SIZE)
	
	# Spawn enemies
	_spawn_enemies()
	
	# Spawn items
	_spawn_items()
	
	# Draw stairs indicator
	_draw_stairs()
	
	_update_ui()
	print("Floor ", current_floor, " started!")

func _draw_dungeon():
	for pos in dungeon.grid:
		var tile_type = dungeon.grid[pos]
		var world_pos = Vector2(pos * TILE_SIZE) + Vector2(TILE_SIZE/2, TILE_SIZE/2)
		
		match tile_type:
			DungeonGenerator.Tile.WALL:
				var wall = ColorRect.new()
				wall.color = Color(0.3, 0.3, 0.35)
				wall.size = Vector2(TILE_SIZE, TILE_SIZE)
				wall.position = Vector2(pos * TILE_SIZE)
				wall.z_index = -1
				add_child(wall)
			DungeonGenerator.Tile.FLOOR:
				var floor = ColorRect.new()
				floor.color = Color(0.15, 0.15, 0.18)
				floor.size = Vector2(TILE_SIZE - 1, TILE_SIZE - 1)
				floor.position = Vector2(pos * TILE_SIZE) + Vector2(0.5, 0.5)
				floor.z_index = -2
				add_child(floor)

func _draw_stairs():
	for pos in dungeon.grid:
		if dungeon.grid[pos] == DungeonGenerator.Tile.STAIRS:
			var stairs = ColorRect.new()
			stairs.color = Color(1, 0.8, 0)
			stairs.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4)
			stairs.position = Vector2(pos * TILE_SIZE) + Vector2(2, 2)
			stairs.z_index = -1
			add_child(stairs)
			break

func _spawn_enemies():
	for pos in dungeon.enemies:
		var enemy = Enemy.new()
		var floor_modifier = current_floor - 1
		var enemy_type = Enemy.EnemyType.SLIME if randf() > 0.3 else Enemy.EnemyType.SKELETON
		enemy.setup(enemy_type, floor_modifier)
		enemy.name = "Enemy"
		enemy.add_to_group("enemy")
		enemy.grid_position = pos
		enemy.global_position = Vector2(pos * TILE_SIZE)
		add_child(enemy)

func _spawn_items():
	for pos in dungeon.items:
		var item = Area2D.new()
		item.name = "Item"
		item.global_position = Vector2(pos * TILE_SIZE) + Vector2(TILE_SIZE/2, TILE_SIZE/2)
		
		# Visual
		var sprite = ColorRect.new()
		sprite.color = Color(1, 0.3, 0.5)  # Pink/red for health potion
		sprite.size = Vector2(16, 16)
		sprite.position = Vector2(-8, -8)
		item.add_child(sprite)
		
		# Collision
		var coll = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 12
		coll.shape = shape
		item.add_child(coll)
		
		item.add_to_group("item")
		add_child(item)

func _process(delta):
	if game_state != "PLAYING":
		return
	
	# Check for item pickup
	for item in get_tree().get_nodes_in_group("item"):
		if player.grid_position == item.grid_position:
			player.heal(30)
			print("Picked up health potion! +30 HP")
			item.queue_free()
	
	# Check for stairs
	if dungeon.get_tile(player.grid_position) == DungeonGenerator.Tile.STAIRS:
		_next_floor()
	
	# Simple collision with enemies - player takes damage when touching
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy:
			if player.grid_position == enemy.grid_position:
				# Push enemy away randomly
				var push_dir = Vector2i(randi_range(-1, 1), randi_range(-1, 1))
				enemy.grid_position += push_dir
				enemy.global_position = Vector2(enemy.grid_position * TILE_SIZE)
				
				# Player takes damage
				player.take_damage(enemy.attack)
	
	_update_ui()

func _update_ui():
	# Update health display
	if player:
		var hp_label = get_node_or_null("UI/HP")
		if hp_label:
			hp_label.text = "HP: %d/%d" % [player.hp, player.max_hp]
		
		var floor_label = get_node_or_null("UI/Floor")
		if floor_label:
			floor_label.text = "Floor: %d/%d" % [current_floor, max_floors]
		
		var instructions = get_node_or_null("UI/Instructions")
		if instructions:
			instructions.text = "WASD: Move | SPACE: Attack"

func _next_floor():
	if current_floor >= max_floors:
		_win_game()
		return
	
	current_floor += 1
	print("=== Going to floor ", current_floor, " ===")
	
	# Clear current floor
	for child in get_children():
		if child != player:
			child.queue_free()
	
	# Wait a bit then start new floor
	await get_tree().create_timer(0.5).timeout
	_start_floor()

func _win_game():
	game_state = "WON"
	print("=== YOU WIN! ===")
	print("Congratulations! You survived all ", max_floors, " floors!")
	
	# Show win message
	var label = Label.new()
	label.name = "WinScreen"
	label.text = "YOU WIN!\nAll %d floors cleared!" % max_floors
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
