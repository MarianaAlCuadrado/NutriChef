extends Node2D

func _ready():
	# Conectamos las señales de los botones
	$boton_avena.pressed.connect(_on_boton_avena_pressed)

# 🥣 Al presionar el botón de avena
func _on_boton_avena_pressed():
	get_tree().change_scene_to_file("res://Juego2.tscn")
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if $boton_caldo.get_rect().has_point($boton_caldo.to_local(event.position)):
			get_tree().change_scene_to_file("res://juego3.tscn")
