extends CanvasLayer

func _ready():
	# HP Display
	var hp_label = Label.new()
	hp_label.name = "HP"
	hp_label.text = "HP: 100/100"
	hp_label.position = Vector2(20, 20)
	hp_label.add_theme_font_size_override("font_size", 28)
	add_child(hp_label)
	
	# Floor Display
	var floor_label = Label.new()
	floor_label.name = "Floor"
	floor_label.text = "Floor: 1/5"
	floor_label.position = Vector2(20, 55)
	floor_label.add_theme_font_size_override("font_size", 28)
	add_child(floor_label)
	
	# Instructions
	var instructions = Label.new()
	instructions.name = "Instructions"
	instructions.text = "WASD: Move | SPACE: Attack"
	instructions.position = Vector2(20, 90)
	instructions.add_theme_font_size_override("font_size", 18)
	instructions.modulate = Color(0.7, 0.7, 0.7)
	add_child(instructions)
