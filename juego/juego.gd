extends Node2D

var tol := 80.0  # tolerancia para combinar objetos
var arrastrando: Sprite2D = null
var paso_actual := 0
var pasos := []

func _ready():
	# Visibilidad inicial
	$aguacate.visible = true
	$aguacate_entero_sin_cascara.visible = false
	$aguacate_partido_con_pepa.visible = false
	$aguacate_sin_pepa.visible = false
	$aguacate_tajadas.visible = false
	$tostada_con_aguacate.visible = false

	# Orden de capas (z_index)
	$tabla.z_index = 0
	$aguacate.z_index = 1
	$aguacate_entero_sin_cascara.z_index = 1
	$aguacate_partido_con_pepa.z_index = 1
	$aguacate_sin_pepa.z_index = 1
	$aguacate_tajadas.z_index = 1
	$cuchillo.z_index = 2
	$tostada_en_plato.z_index = 0
	$tostada_con_aguacate.z_index = 3

	# Pasos actualizados con el paso extra para colocar el aguacate en la tabla sin transformar
	pasos = [
		[$aguacate, $tabla, $aguacate],  # solo colocar aguacate en la tabla
		[$aguacate, $cuchillo, $aguacate_entero_sin_cascara],  # pelar aguacate con cuchillo
		[$aguacate_entero_sin_cascara, $cuchillo, $aguacate_partido_con_pepa],
		[$aguacate_partido_con_pepa, $cuchillo, $aguacate_sin_pepa],
		[$aguacate_sin_pepa, $cuchillo, $aguacate_tajadas],
		[$aguacate_tajadas, $tostada_en_plato, $tostada_con_aguacate]
	]

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pick(event.position)
		else:
			_drop(event.position)
	elif event is InputEventMouseMotion and arrastrando:
		arrastrando.global_position = event.position

func _pick(mouse_pos: Vector2):
	arrastrando = null
	for n in get_children():
		if n is Sprite2D and n.visible:
			var local: Vector2 = n.to_local(mouse_pos)
			var tex: Texture2D = n.texture
			if tex and Rect2(-tex.get_size() / 2, tex.get_size()).has_point(local):
				arrastrando = n
				break

func _drop(_mouse_pos: Vector2):
	if not arrastrando or paso_actual >= pasos.size():
		arrastrando = null
		return

	var origen: Sprite2D = pasos[paso_actual][0]
	var herramienta: Sprite2D = pasos[paso_actual][1]
	var resultado: Sprite2D = pasos[paso_actual][2]

	if origen == null or herramienta == null or resultado == null:
		print("❌ Error: paso mal definido.")
		arrastrando = null
		return

	var ok := false

	# Caso 1: arrastro ingrediente a herramienta
	if arrastrando == origen and origen.global_position.distance_to(herramienta.global_position) < tol:
		ok = true

	# Caso 2: arrastro herramienta a ingrediente
	elif arrastrando == herramienta and herramienta.global_position.distance_to(origen.global_position) < tol and origen.visible:
		ok = true

	if ok:
		# Si solo es colocar el aguacate, no ocultar el origen
		if origen == resultado:
			resultado.global_position = herramienta.global_position
			# no cambiar visibilidad, el aguacate sigue visible
		else:
			origen.visible = false
			resultado.global_position = herramienta.global_position
			resultado.visible = true
			# Ocultar tostada base si es último paso
			if origen == $aguacate_tajadas and herramienta == $tostada_en_plato:
				$tostada_en_plato.visible = false

		arrastrando = null
		paso_actual += 1
	else:
		arrastrando = null
