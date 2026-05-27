extends Node2D

# -----------------------------------
# 🔪 Nodos principales
# -----------------------------------
@onready var cuchillo = $cuchillo
@onready var platos_vacio = $platos_vacio

@onready var papa = $papa
@onready var zanahoria = $zanahoria
@onready var apio = $apio
@onready var ajo = $ajo
@onready var cebolla = $cebolla
@onready var arvejas = $arvejas

@onready var papa_picada = $papa_picada
@onready var zanahoria_picada = $zanahoria_picada
@onready var cebolla_picada = $cebolla_picada
@onready var ajo_molido = $ajo_molido
@onready var arveja_sin_cascara = $arveja_sin_cascara

@onready var papa_en_plato = $papa_en_plato
@onready var ajo_en_plato = $ajo_en_plato
@onready var cebolla_en_plato = $cebolla_en_plato
@onready var arveja_en_plato = $arveja_en_plato

# -----------------------------------
# Variables de control
# -----------------------------------
var cuchillo_sigue_cursor = false
var fase = 1
var clicks_actuales = 0
const CLICKS_REQUERIDOS = 5

var ingrediente_actual: Node2D = null
var picado_actual: Node2D = null
var plato_actual: Node2D = null

var dragging_node: Node2D = null
var esperando = false

# -----------------------------------
# 🔹 CONFIGURACIÓN INICIAL
# -----------------------------------
func _ready():
	$receta_almuerzo.visible = false
	$boton_x_almuerzo.visible = false

	cuchillo.visible = false
	platos_vacio.visible = false

	papa.visible = false
	zanahoria.visible = false
	apio.visible = false
	ajo.visible = false
	cebolla.visible = false
	arvejas.visible = false

	papa_picada.visible = false
	zanahoria_picada.visible = false
	cebolla_picada.visible = false
	ajo_molido.visible = false
	arveja_sin_cascara.visible = false

	papa_en_plato.visible = false
	ajo_en_plato.visible = false
	cebolla_en_plato.visible = false
	arveja_en_plato.visible = false

	# Conectar señales de área: picado entra al plato vacío
	papa_picada.get_node("AreaPapaPicada").connect("area_entered", Callable(self, "_on_picado_entro_al_plato"))
	ajo_molido.get_node("AreaAjoMolido").connect("area_entered", Callable(self, "_on_picado_entro_al_plato"))
	cebolla_picada.get_node("AreaCebollaPicada").connect("area_entered", Callable(self, "_on_picado_entro_al_plato"))
	arveja_sin_cascara.get_node("AreaArvejaSinCascara").connect("area_entered", Callable(self, "_on_picado_entro_al_plato"))

	call_deferred("_iniciar_fase", 1)


# -----------------------------------
# 🎬 Iniciar fase
# -----------------------------------
func _iniciar_fase(num: int) -> void:
	fase = num
	clicks_actuales = 0
	esperando = false
	dragging_node = null
	_ocultar_todo_verduras()

	match num:
		1:
			ingrediente_actual = papa
			picado_actual = papa_picada
			plato_actual = papa_en_plato
		2:
			ingrediente_actual = zanahoria
			picado_actual = zanahoria_picada
			plato_actual = null
		3:
			ingrediente_actual = ajo
			picado_actual = ajo_molido
			plato_actual = ajo_en_plato
		4:
			ingrediente_actual = cebolla
			picado_actual = cebolla_picada
			plato_actual = cebolla_en_plato
		5:
			ingrediente_actual = arvejas
			picado_actual = arveja_sin_cascara
			plato_actual = arveja_en_plato
		6:
			_iniciar_fase_final()
			return

	ingrediente_actual.visible = true
	cuchillo_sigue_cursor = true
	cuchillo.visible = true


func _ocultar_todo_verduras() -> void:
	for n in [papa, zanahoria, apio, ajo, cebolla, arvejas,
			papa_picada, zanahoria_picada, ajo_molido, cebolla_picada, arveja_sin_cascara,
			papa_en_plato, ajo_en_plato, cebolla_en_plato, arveja_en_plato,
			platos_vacio]:
		if n:
			n.visible = false


# -----------------------------------
# 🖱️ INPUT
# -----------------------------------
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		# Botón receta
		if $boton_receta_almuerzo.get_rect().has_point($boton_receta_almuerzo.to_local(event.position)):
			$receta_almuerzo.visible = true
			$boton_x_almuerzo.visible = true
			return

		if $boton_x_almuerzo.visible and $boton_x_almuerzo.get_rect().has_point($boton_x_almuerzo.to_local(event.position)):
			$receta_almuerzo.visible = false
			$boton_x_almuerzo.visible = false
			return

		# Clicks para picar con cuchillo
		if cuchillo_sigue_cursor and ingrediente_actual and ingrediente_actual.visible and not esperando:
			if ingrediente_actual.get_rect().has_point(ingrediente_actual.to_local(event.position)):
				clicks_actuales += 1
				if clicks_actuales >= CLICKS_REQUERIDOS:
					_picar_ingrediente()
				return

		# Inicio de arrastre del picado
		if not cuchillo_sigue_cursor and not esperando:
			if picado_actual and picado_actual.visible:
				if picado_actual.get_rect().has_point(picado_actual.to_local(event.position)):
					dragging_node = picado_actual

	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_node = null

	elif event is InputEventMouseMotion:
		if cuchillo_sigue_cursor:
			cuchillo.global_position = event.position
		if dragging_node:
			dragging_node.global_position = event.position


# -----------------------------------
# 🔪 Picar (5 clicks)
# -----------------------------------
func _picar_ingrediente() -> void:
	esperando = true
	cuchillo_sigue_cursor = false
	cuchillo.visible = false
	ingrediente_actual.visible = false
	picado_actual.visible = true
	clicks_actuales = 0

	if plato_actual:
		# ✅ El plato vacío aparece en la misma posición que el plato con verdura
		platos_vacio.position = plato_actual.position
		platos_vacio.visible = true
		esperando = false  # permitir arrastre
	else:
		# Zanahoria: sin plato, espera y avanza
		await get_tree().create_timer(2.0).timeout
		picado_actual.visible = false
		_avanzar_fase()


# -----------------------------------
# ✅ Señal: picado entró al área del plato vacío
# -----------------------------------
func _on_picado_entro_al_plato(area: Area2D) -> void:
	if area.name != "AreaPlatoVacio":
		return
	if esperando:
		return
	if not picado_actual or not picado_actual.visible:
		return
	if not plato_actual:
		return

	esperando = true
	dragging_node = null
	picado_actual.visible = false
	platos_vacio.visible = false
	plato_actual.visible = true

	await get_tree().create_timer(2.0).timeout
	plato_actual.visible = false
	_avanzar_fase()


# -----------------------------------
# ➡️ Avanzar fase
# -----------------------------------
func _avanzar_fase() -> void:
	if fase < 6:
		_iniciar_fase(fase + 1)


# -----------------------------------
# 🥗 Fase final: apio + todos los resultados
# -----------------------------------
func _iniciar_fase_final() -> void:
	cuchillo.visible = false
	cuchillo_sigue_cursor = false
	_ocultar_todo_verduras()

	apio.visible = true
	papa_en_plato.visible = true
	ajo_en_plato.visible = true
	cebolla_en_plato.visible = true
	arveja_en_plato.visible = true
	zanahoria_picada.visible = true


# -----------------------------------
# Señales del editor (no borrar)
# -----------------------------------
func _on_area_papa_area_entered(area: Area2D) -> void:
	pass
func _on_area_zanahoria_area_entered(area: Area2D) -> void:
	pass
func _on_area_apio_area_entered(area: Area2D) -> void:
	pass
func _on_area_ajo_area_entered(area: Area2D) -> void:
	pass
func _on_area_cebolla_area_entered(area: Area2D) -> void:
	pass
func _on_area_arvejas_area_entered(area: Area2D) -> void:
	pass
func _on_area_papa_plato_area_entered(area: Area2D) -> void:
	pass
func _on_area_ajo_plato_area_entered(area: Area2D) -> void:
	pass
func _on_area_cebolla_plato_area_entered(area: Area2D) -> void:
	pass
func _on_area_ajo_molido_area_entered(area: Area2D) -> void:
	pass
func _on_area_cebolla_picada_area_entered(area: Area2D) -> void:
	pass
func _on_area_zanahoria_picada_area_entered(area: Area2D) -> void:
	pass
func _on_area_papa_picada_area_entered(area: Area2D) -> void:
	pass
func _on_area_arveja_sin_cascara_area_entered(area: Area2D) -> void:
	pass
func _on_area_arveja_plato_area_entered(area: Area2D) -> void:
	pass
func _on_area_cuchillo_area_entered(area: Area2D) -> void:
	pass
func _on_area_plato_vacio_area_entered(area: Area2D) -> void:
	pass
