extends CanvasLayer

var hp_label: Label
var floor_label: Label

func _ready():
	# HP Display
	hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "HP: 100/100"
	hp_label.position = Vector2(10, 10)
	hp_label.add_theme_font_size_override("font_size", 24)
	add_child(hp_label)
	
	# Floor Display
	floor_label = Label.new()
	floor_label.name = "FloorLabel"
	floor_label.text = "Floor: 1/5"
	floor_label.position = Vector2(10, 40)
	floor_label.add_theme_font_size_override("font_size", 24)
	add_child(floor_label)

func _process(delta):
	var game = get_tree().get_first_node_in_group("player")
	if game:
		hp_label.text = "HP: " + str(game.hp) + "/" + str(game.max_hp)
		if game.hp <= 30:
			hp_label.modulate = Color.RED
		elif game.hp <= 60:
			hp_label.modulate = Color.YELLOW
		else:
			hp_label.modulate = Color.GREEN
		
		# Get floor from game manager
		var gm = get_tree().get_first_node_in_group("player").get_parent()
		if gm.has_method("_next_floor"):
			floor_label.text = "Floor: " + str(gm.current_floor) + "/" + str(gm.max_floors)
