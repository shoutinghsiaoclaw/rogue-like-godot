extends CharacterBody2D

class_name Enemy

enum EnemyType { SLIME, SKELETON }

var enemy_type: EnemyType = EnemyType.SLIME
var hp: int = 20
var attack: int = 5
var defense: int = 2
var speed: int = 50
var grid_position: Vector2i
var damage_on_death: int = 0

const TILE_SIZE: int = 32

func _ready():
	_create_sprite()

func setup(type: EnemyType, floor: int):
	enemy_type = type
	match type:
		EnemyType.SLIME:
			hp = 15 + (floor * 5)
			attack = 5 + floor
			defense = 1
			speed = 40
			modulate = Color(0.2, 0.6, 0.8)  # Blue
		EnemyType.SKELETON:
			hp = 25 + (floor * 8)
			attack = 8 + floor
			defense = 3
			speed = 60
			modulate = Color(0.9, 0.9, 0.9)  # White/Bone

func _create_sprite():
	var sprite = Sprite2D.new()
	var image = Image.create(TILE_SIZE - 4, TILE_SIZE - 4, false, Image.FORMAT_RGBA8)
	
	match enemy_type:
		EnemyType.SLIME:
			image.fill(Color(0.2, 0.6, 0.8))
		EnemyType.SKELETON:
			image.fill(Color(0.9, 0.9, 0.9))
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	add_child(sprite)

func _physics_process(delta):
	# Simple AI: move toward player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		if direction.length() > 1:
			velocity = direction * speed
			grid_position = Vector2i(global_position / TILE_SIZE)
			move_and_slide()
			velocity = Vector2.ZERO

func take_damage(amount: int) -> int:
	var actual_damage = max(1, amount - defense)
	hp -= actual_damage
	print("Enemy took ", actual_damage, " damage! HP: ", hp)
	if hp <= 0:
		die()
	return actual_damage

func die():
	print("Enemy defeated!")
	queue_free()
