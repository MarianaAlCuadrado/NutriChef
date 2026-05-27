extends Node2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Detecta si el clic fue dentro del área del sprite
		if $boton_play.get_rect().has_point($boton_play.to_local(event.position)):
			get_tree().change_scene_to_file("res://pantalla_opciones.tscn")

func _on_area_boton_ia_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Detecta si el evento es un clic del ratón (botón izquierdo)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var url = "https://cdn.botpress.cloud/webchat/v3.6/shareable.html?configUrl=https://files.bpcontent.cloud/2026/03/15/18/20260315183130-7XBVXAWS.json"
		OS.shell_open(url)


func _on_area_boton_ia_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
