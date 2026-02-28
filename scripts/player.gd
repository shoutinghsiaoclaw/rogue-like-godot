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

func _ready():
	# Create visual representation
	_create_sprite()
	grid_position = Vector2i(5, 5)  # Start at center of room

func _create_sprite():
	var sprite = Sprite2D.new()
	sprite.modulate = Color(0.2, 0.8, 0.2)  # Green player
	# Create simple rectangle texture
	var image = Image.create(TILE_SIZE - 4, TILE_SIZE - 4, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.8, 0.2))
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	add_child(sprite)

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_pressed("move_down"):
		direction.y = 1
	elif Input.is_action_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_pressed("move_right"):
		direction.x = 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		grid_position += Vector2i(direction.x, direction.y)
		move_and_slide()
		velocity = Vector2.ZERO

func take_damage(amount: int) -> int:
	var actual_damage = max(1, amount - defense)
	hp -= actual_damage
	print("Player took ", actual_damage, " damage! HP: ", hp, "/", max_hp)
	if hp <= 0:
		die()
	return actual_damage

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	print("Player healed! HP: ", hp, "/", max_hp)

func die():
	print("=== GAME OVER ===")
	print("You died on floor ", get_parent().current_floor)
	get_tree().paused = true
