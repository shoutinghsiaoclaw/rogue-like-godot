extends CharacterBody2D

class_name Player

## Player Stats
var hp: int = 100
var max_hp: int = 100
var attack: int = 10
var defense: int = 5
var speed: int = 150

## Position tracking
var grid_position: Vector2i

const TILE_SIZE: int = 32

# Attack cooldown
var can_attack: bool = true
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0

func _ready():
	# Create visual representation
	_create_sprite()
	_create_health_bar()
	grid_position = Vector2i(5, 5)

func _create_sprite():
	var sprite = Sprite2D.new()
	sprite.modulate = Color(0.2, 0.8, 0.2)  # Green player
	var image = Image.create(TILE_SIZE - 4, TILE_SIZE - 4, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.8, 0.2))
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	add_child(sprite)

func _create_health_bar():
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2)
	bg.size = Vector2(TILE_SIZE, 4)
	bg.position = Vector2(-(TILE_SIZE-4)/2, -TILE_SIZE/2 - 8)
	add_child(bg)
	
	var fg = ColorRect.new()
	fg.name = "HealthBar"
	fg.color = Color(0.2, 0.8, 0.2)
	fg.size = Vector2(TILE_SIZE - 4, 4)
	fg.position = Vector2(-(TILE_SIZE-4)/2, -TILE_SIZE/2 - 8)
	add_child(fg)

func _physics_process(delta):
	# Handle attack cooldown
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_pressed("move_down"):
		direction.y = 1
	elif Input.is_action_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_pressed("move_right"):
		direction.x = 1
	
	# Attack with space
	if Input.is_action_pressed("ui_accept") and can_attack:
		_attack()
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		
		# Calculate new grid position
		var new_grid_pos = grid_position + Vector2i(direction.x, direction.y)
		
		# Check if walkable (will be checked by game manager)
		velocity = direction * speed
		move_and_slide()
		velocity = Vector2.ZERO
		
		# Update grid position after movement
		grid_position = Vector2i(global_position / TILE_SIZE)

func _attack():
	can_attack = false
	attack_timer = attack_cooldown
	
	# Visual feedback
	var sprite = get_child(0) as Sprite2D
	if sprite:
		var original_modulate = sprite.modulate
		sprite.modulate = Color(1, 1, 1)  # Flash white
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
	
	# Check for enemies in adjacent tiles
	var adjacent_positions = [
		grid_position + Vector2i(1, 0),
		grid_position + Vector2i(-1, 0),
		grid_position + Vector2i(0, 1),
		grid_position + Vector2i(0, -1)
	]
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy and enemy.grid_position in adjacent_positions:
			enemy.take_damage(attack)
			print("Player attacked enemy for ", attack, " damage!")

func update_health_bar():
	var bar = get_node_or_null("HealthBar")
	if bar:
		var percent = float(hp) / float(max_hp)
		bar.size.x = (TILE_SIZE - 4) * percent
		if percent > 0.6:
			bar.color = Color(0.2, 0.8, 0.2)
		elif percent > 0.3:
			bar.color = Color(1, 1, 0)
		else:
			bar.color = Color(1, 0, 0)

func take_damage(amount: int) -> int:
	var actual_damage = max(1, amount - defense)
	hp -= actual_damage
	update_health_bar()
	print("Player took ", actual_damage, " damage! HP: ", hp, "/", max_hp)
	if hp <= 0:
		die()
	return actual_damage

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	update_health_bar()
	print("Player healed! HP: ", hp, "/", max_hp)

func die():
	print("=== GAME OVER ===")
	print("You died on floor ", get_parent().current_floor)
	get_tree().paused = true
	
	# Show game over
	var label = Label.new()
	label.name = "GameOver"
	label.text = "GAME OVER\nFloor: " + str(get_parent().current_floor) + "\nPress R to restart"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	
	# Wait for restart
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
