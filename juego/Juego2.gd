extends Node2D

# -----------------------------------
# 🥛 Fase 1 y 2: Leche y agua en vaso
# -----------------------------------
@onready var vaso_vacio = $vaso_vacio
@onready var vaso_con_leche = $vaso_con_leche
@onready var vaso_con_agua = $vaso_con_agua

@onready var leche_con_tapa = $leche_con_tapa
@onready var leche_sin_tapa = $leche_sin_tapa
@onready var agua_con_tapa = $agua_con_tapa
@onready var agua_sin_tapa = $agua_sin_tapa

# -----------------------------------
# 🍳 Fase 3 y 4: Cocinar avena
# -----------------------------------
@onready var Estufa = $Estufa
@onready var olla_vacia = $olla_vacia
@onready var olla_con_agua = $olla_con_agua
@onready var olla_con_leche = $olla_con_leche
@onready var avena = $avena
@onready var cuchara_madera = $cuchara_madera
@onready var olla_con_avena = $olla_con_avena
@onready var avena_con_cuchara = $avena_con_cuchara

# -----------------------------------
# 🍯 Fase 5 y 6: Miel, sal, canela y plato
# -----------------------------------
@onready var miel_de_maple = $miel_de_maple
@onready var sal = $sal
@onready var cuchara = $cuchara
@onready var cuchara_miel = $cuchara_miel
@onready var cuchara_sal = $cuchara_sal
@onready var canela = $canela
@onready var plato_vacio = $plato_vacio
@onready var plato_con_avena = $plato_con_avena

# -----------------------------------
# 🍌 Fase 7 y 8: Decorar con frutas
# -----------------------------------
@onready var tabla = $tabla
@onready var banano_con_cascara = $banano_con_cascara
@onready var banano_sin_cascara = $banano_sin_cascara
@onready var banano_picado = $banano_picado
@onready var cuchillo = $cuchillo                # tu cuchillo "normal"
@onready var cuchillo_arriba = $cuchillo_arriba  # cuchillo que sigue al cursor
@onready var arandanos = $arandanos
@onready var almendras = $almendras
@onready var avena_final = $avena_final

# -----------------------------------
# Variables de control
# -----------------------------------
var dragging_node: Node2D = null
var fase = 1

var leche_agregada = false
var agua_agregada = false
var avena_agregada = false
var cuchara_agregada = false

var miel_agregada = false
var sal_agregada = false
var canela_agregada = false
var banano_agregado = false

var cuchara_pos_inicial = Vector2()

# Fase 7/8 control
var banano_clicks = 0
var cuchillo_sigue_cursor = false
var ingredientes_agregados = 0

# -----------------------------------
# 🎈 Estado interno para globos (evita re-disparos)
# -----------------------------------
var _globo_triggered = {}         # diccionario: num -> bool
var _coroutines_running = {}      # num -> bool para evitar lanzar la misma corutina varias veces

# -----------------------------------
# 🔹 CONFIGURACIÓN INICIAL
# -----------------------------------
func _ready():
	# init globo flags
	for i in range(1, 20):
		_globo_triggered[i] = false
		_coroutines_running[i] = false

	# Ocultar globos si existen
	for i in range(1, 20):
		var g = get_node_or_null("globo" + str(i))
		if g:
			g.visible = false

	# visibilidades iniciales
	vaso_vacio.visible = true
	vaso_con_leche.visible = false
	vaso_con_agua.visible = false

	leche_con_tapa.visible = true
	leche_sin_tapa.visible = false
	agua_con_tapa.visible = false
	agua_sin_tapa.visible = false

	Estufa.visible = false
	olla_vacia.visible = false
	olla_con_agua.visible = false
	olla_con_leche.visible = false
	avena.visible = false
	cuchara_madera.visible = false
	olla_con_avena.visible = false
	avena_con_cuchara.visible = false

	miel_de_maple.visible = false
	sal.visible = false
	cuchara.visible = false
	cuchara_miel.visible = false
	cuchara_sal.visible = false
	canela.visible = false
	plato_vacio.visible = false
	plato_con_avena.visible = false

	# Fase 7/8 nodos ocultos inicialmente
	tabla.visible = false
	banano_con_cascara.visible = false
	banano_sin_cascara.visible = false
	banano_picado.visible = false
	cuchillo.visible = false
	cuchillo_arriba.visible = false
	arandanos.visible = false
	almendras.visible = false
	avena_final.visible = false

	# conexiones
	leche_sin_tapa.get_node("AreaBotellaLeche").connect("area_entered", Callable(self, "_on_botella_area_entered"))
	agua_sin_tapa.get_node("AreaBotellaAgua").connect("area_entered", Callable(self, "_on_botella_area_entered"))
	vaso_con_leche.get_node("AreaVasoLeche").connect("area_entered", Callable(self, "_on_vaso_area_entered"))
	vaso_con_agua.get_node("AreaVasoAgua").connect("area_entered", Callable(self, "_on_vaso_area_entered"))

	avena.get_node("AreaAvena").connect("area_entered", Callable(self, "_on_avena_area_entered"))
	cuchara_madera.get_node("AreaCucharaMadera").connect("area_entered", Callable(self, "_on_cuchara_area_entered"))

	miel_de_maple.get_node("AreaMiel").connect("area_entered", Callable(self, "_on_miel_area_entered"))
	sal.get_node("AreaSal").connect("area_entered", Callable(self, "_on_sal_area_entered"))
	cuchara.get_node("AreaCuchara").connect("area_entered", Callable(self, "_on_cuchara_ingrediente_entered"))
	cuchara_miel.get_node("AreaCucharaMiel").connect("area_entered", Callable(self, "_on_cuchara_miel_area_entered"))
	cuchara_sal.get_node("AreaCucharaSal").connect("area_entered", Callable(self, "_on_cuchara_sal_area_entered"))
	canela.get_node("AreaCanela").connect("area_entered", Callable(self, "_on_canela_area_entered"))

	avena_con_cuchara.get_node("AreaAvenaCuchara").connect("area_entered", Callable(self, "_on_avena_area_entered_final"))

	# guardar posiciones iniciales para restaurarlas luego
	if has_node("cuchara"):
		cuchara_pos_inicial = cuchara.position
	if banano_sin_cascara:
		banano_sin_cascara.set_meta("pos_inicial", banano_sin_cascara.position)
	if avena_final:
		avena_final.set_meta("pos_inicial", avena_final.position)

	# mostrar globo1 al inicio por 8s y luego globo2
	# lanzamos la corutina que mostrará globo1 -> globo2
	# usamos call_deferred para evitar await dentro de ready bloqueando layout.
	call_deferred("_start_initial_globos")

func _start_initial_globos() -> void:
	# arranca la secuencia inicial de globos
	if not _coroutines_running[1]:
		_coroutines_running[1] = true
		_start_coroutine_show_temporal(1, 8, 2)


# -----------------------------------
# 🎈 FUNCIONES DE GLOBOS
# -----------------------------------
func mostrar_globo_unico(num: int) -> void:
	# oculta todos y muestra sólo el indicado
	for i in range(1, 20):
		var g = get_node_or_null("globo" + str(i))
		if g:
			g.visible = false
	var target = get_node_or_null("globo" + str(num))
	if target:
		target.visible = true
		_globo_triggered[num] = true

# helper que lanza la corutina (no-blocking)
func _start_coroutine_show_temporal(num: int, segundos: float, siguiente: int = -1) -> void:
	# marca que la corutina está activa y la lanza (call_deferred para no bloquear)
	_coroutines_running[num] = true
	call_deferred("_coroutine_show_temporal", num, segundos, siguiente)

# corutina que muestra un globo por X segundos y luego opcionalmente otro
func _coroutine_show_temporal(num: int, segundos: float, siguiente: int = -1) -> void:
	mostrar_globo_unico(num)
	# await aquí sólo en esta función (está bien)
	await get_tree().create_timer(segundos).timeout
	# ocultar sólo si NO es globo7 ni globo17 (porque deben mantenerse)
	if num not in [7, 17]:
		var g = get_node_or_null("globo" + str(num))
		if g:
			g.visible = false

	# marcar que corutina terminó
	_coroutines_running[num] = false
	# si se pidió mostrar otro globo siguiente, hacerlo
	if siguiente >= 1 and not _globo_triggered.get(siguiente, false):
		_coroutines_running[siguiente] = true
		_coroutine_show_temporal(siguiente, 8, -1)  # ahora globo2 dura 8 s


# -----------------------------------
# 🟢 Procesamiento cada frame (revisa condiciones para los globos)
# -----------------------------------
func _process(delta: float) -> void:
	_procesar_globos()

func _procesar_globos() -> void:
	# Esta función debe ser ligera: sólo dispara corutinas / mostrar_globo_unico,
	# no contiene awaits para evitar bloqueos en el _process.

	# G1 y G2 arrancan en _ready / _start_initial_globos

	# Globo3: aparece al destapar la leche (se muestra una vez)
	if not _globo_triggered[3] and not leche_con_tapa.visible and leche_sin_tapa.visible:
		mostrar_globo_unico(3)

	# Globo4: cuando aparece botella de agua con tapa y vaso vacío (y leche ya destapada)
	if not _globo_triggered[4] and agua_con_tapa.visible and vaso_vacio.visible and not leche_con_tapa.visible:
		mostrar_globo_unico(4)

	# Globo5: cuando se destapa el agua
	if not _globo_triggered[5] and not agua_con_tapa.visible and agua_sin_tapa.visible:
		mostrar_globo_unico(5)

	# Globo6: cuando aparecen estufa, olla vacia y vasos (se mantiene 5s y luego globo7)
	if not _globo_triggered[6] and Estufa.visible and olla_vacia.visible and vaso_con_agua.visible and vaso_con_leche.visible:
		# lanzar corutina 6 (5s) -> 7
		if not _coroutines_running[6]:
			_coroutines_running[6] = true
			_start_coroutine_show_temporal(6, 5, 7)
			_globo_triggered[6] = true

	# Globo7: será mostrado por la corutina de 6 -> 7 (o si queremos forzarlo)
	# (no hacemos otra cosa aquí)

	# Globo8: cuando aparece avena
	if not _globo_triggered[8] and avena.visible:
		mostrar_globo_unico(8)

	# Globo9: aparece cuando aparece la olla_con_avena (fase 4)
	if not _globo_triggered[9] and olla_con_avena.visible:
		mostrar_globo_unico(9)


	# Globo10: cuando salen sal, miel, canela y cuchara
	if not _globo_triggered[10] and miel_de_maple.visible and sal.visible and canela.visible and cuchara.visible:
		mostrar_globo_unico(10)

	# Globo11: cuando aparece cuchara_miel
	if not _globo_triggered[11] and cuchara_miel.visible:
		mostrar_globo_unico(11)

	# Globo12: cuando desaparece cuchara_miel
	if not _globo_triggered[12] and not cuchara_miel.visible and miel_agregada:
		mostrar_globo_unico(12)

	# Globo13: cuando aparece cuchara_sal
	if not _globo_triggered[13] and cuchara_sal.visible:
		mostrar_globo_unico(13)

	# Globo14: cuando desaparece cuchara_sal
	if not _globo_triggered[14] and not cuchara_sal.visible and sal_agregada:
		mostrar_globo_unico(14)

	# Globo15: cuando aparece plato vacío
	if not _globo_triggered[15] and plato_vacio.visible:
		mostrar_globo_unico(15)

	# Globo16: aparece cuando tabla, banano con cáscara y cuchillo están visibles
	if not _globo_triggered[16] and tabla.visible and banano_con_cascara.visible and cuchillo.visible:
		if not _coroutines_running[16]:
			_coroutines_running[16] = true
			_start_coroutine_show_temporal(16, 7, 17)
			_globo_triggered[16] = true

	# Globo17: se muestra después de globo16 por la corrutina
	# y se mantiene visible hasta que el banano se pique (aparezca banano_picado)
	# PERO no debe volver a aparecer luego
	if _globo_triggered[17]:
		var g17 = get_node_or_null("globo17")
		if g17 and g17.visible and banano_picado.visible:
			g17.visible = false
			# Marcar que ya se desactivó definitivamente
			_globo_triggered[17] = false



	# Globo18: cuando aparecen arandanos y almendras (ya listos para decorar)
	if not _globo_triggered[18] and arandanos.visible and almendras.visible:
		mostrar_globo_unico(18)

	# Globo19: cuando aparece la avena final
	if not _globo_triggered[19] and avena_final.visible:
		mostrar_globo_unico(19)
		
	# Mantener globo17 hasta que aparezca el banano picado
	if _globo_triggered[17] and not banano_picado.visible:
		var g17 = get_node_or_null("globo17")
		if g17:
			g17.visible = true
	elif banano_picado.visible and _globo_triggered[17]:
		var g17 = get_node_or_null("globo17")
		if g17:
			g17.visible = false
	# Si globo19 aparece, asegúrate de ocultar globo17
	if _globo_triggered[19]:
		var g17 = get_node_or_null("globo17")
		if g17:
			g17.visible = false



# -----------------------------------
# 🖱️ ARRASTRE Y CLICKS (UN SOLO _input)
# -----------------------------------
func _input(event):
	# ----------------
	# Click / inicio arrastre
	# ----------------
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Destapar leche (fase 1)
			if fase == 1 and leche_con_tapa.visible and leche_con_tapa.get_rect().has_point(leche_con_tapa.to_local(event.position)):
				leche_con_tapa.visible = false
				leche_sin_tapa.visible = true
				leche_sin_tapa.position = leche_con_tapa.position
				# Globo3 debe dispararse cuando se detecte el estado (en _procesar_globos)
				return
			# Destapar agua (fase 2)
			if fase == 2 and agua_con_tapa.visible and agua_con_tapa.get_rect().has_point(agua_con_tapa.to_local(event.position)):
				agua_con_tapa.visible = false
				agua_sin_tapa.visible = true
				agua_sin_tapa.position = agua_con_tapa.position
				return

			# Pelar banano con click (fase 7)
			if fase == 7 and banano_con_cascara.visible and banano_con_cascara.get_rect().has_point(banano_con_cascara.to_local(event.position)):
				banano_con_cascara.visible = false
				banano_sin_cascara.visible = true
				# restaurar posicion inicial del banano_sin_cascara
				if banano_sin_cascara.has_meta("pos_inicial"):
					banano_sin_cascara.position = banano_sin_cascara.get_meta("pos_inicial")
				return

			# Cortar banano (5 clicks) si cuchillo_arriba está activo
			if fase == 7 and banano_sin_cascara.visible and cuchillo_arriba.visible:
				if banano_sin_cascara.get_rect().has_point(banano_sin_cascara.to_local(event.position)):
					banano_clicks += 1
					if banano_clicks >= 5:
						banano_sin_cascara.visible = false
						banano_picado.visible = true
						cuchillo_arriba.visible = false
						cuchillo_sigue_cursor = false
						# luego esconder tabla y mostrar ingredientes y plato (con posición a la derecha)
						await get_tree().create_timer(2).timeout
						tabla.visible = false
						await get_tree().create_timer(2).timeout
						arandanos.visible = true
						almendras.visible = true
						plato_con_avena.visible = true
						# desplazar plato a la derecha para decorar (ajusta si quieres)
						plato_con_avena.position = Vector2(850, 400)
						fase = 8
					return

			# Si se hizo click sobre cualquier nodo visible lo ponemos para arrastrar
			for nodo in [leche_sin_tapa, agua_sin_tapa, vaso_con_leche, vaso_con_agua, avena, cuchara_madera, cuchara, cuchara_miel, cuchara_sal, avena_con_cuchara, canela, banano_con_cascara, banano_sin_cascara, banano_picado, cuchillo, cuchillo_arriba, arandanos, almendras]:
				if nodo and nodo.visible and nodo.get_rect().has_point(nodo.to_local(event.position)):
					# Si es cuchillo_arriba no se arrastra por click (sigue cursor)
					if nodo == cuchillo_arriba:
						dragging_node = null
					else:
						dragging_node = nodo
					break

		# ----------------
		# Soltar botón: revisar colisiones "release"
		# ----------------
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if dragging_node:
				# BANANO sobre TABLA (centrar si se suelta encima) - fase 7
				if dragging_node == banano_sin_cascara and fase == 7: 
					var banano_rect = Rect2( 
						banano_sin_cascara.global_position - (banano_sin_cascara.texture.get_size() / 2), 
						banano_sin_cascara.texture.get_size() 
					) 
					var tabla_rect = Rect2( 
						tabla.global_position - (tabla.texture.get_size() / 2), 
						tabla.texture.get_size() 
					)
				# CUCHILLO toca TABLA -> cambiar a cuchillo_arriba que seguirá el cursor
				if dragging_node == cuchillo and fase == 7:
					if cuchillo.get_rect().intersects(tabla.get_rect()):
						cuchillo.visible = false
						cuchillo_arriba.visible = true
						cuchillo_arriba.position = cuchillo.position
						cuchillo_sigue_cursor = true
				# Ingredientes sobre plato (fase 8)
				if fase == 8 and dragging_node in [arandanos, banano_picado, almendras]:
					if dragging_node.get_rect().intersects(plato_con_avena.get_rect()):
						if dragging_node.visible:
							# Ocultar el ingrediente
							dragging_node.visible = false
							# Si es el banano picado, marcar que fue agregado
							if dragging_node == banano_picado:
								banano_agregado = true
							# Contar ingrediente agregado
							ingredientes_agregados += 1
							# Cuando todos los ingredientes estén en el plato
							if ingredientes_agregados >= 3:
								await get_tree().create_timer(1.5).timeout
								plato_con_avena.visible = false
								avena_final.visible = true
								# Restaurar posición original de avena_final
								if avena_final.has_meta("pos_inicial"):
									avena_final.position = avena_final.get_meta("pos_inicial")

				# fin comprobaciones
			dragging_node = null

	# ----------------
	# Movimiento del mouse (dragging or cuchillo following)
	# ----------------
	elif event is InputEventMouseMotion:
		if dragging_node and not cuchillo_sigue_cursor:
			dragging_node.global_position = event.position
		elif cuchillo_sigue_cursor and cuchillo_arriba.visible:
			cuchillo_arriba.global_position = event.position

# -----------------------------------
# 🥛 Fases: funciones relacionadas con las Areas (sin cambios funcionales)
# -----------------------------------
func _on_botella_area_entered(area):
	# Mostrar globo 1/2 no aquí: globo1 ya se maneja en _ready.
	# Sólo procesa la acción del vaso
	if "Vaso" in area.name:
		if fase == 1 and area.name == "AreaVasoLeche":
			_llenar_vaso_leche()
		elif fase == 2 and area.name == "AreaVasoAgua":
			_llenar_vaso_agua()

func _llenar_vaso_leche() -> void:
	vaso_vacio.visible = false
	vaso_con_leche.visible = true
	await get_tree().create_timer(2).timeout
	leche_sin_tapa.visible = false
	vaso_con_leche.visible = false
	vaso_vacio.visible = true
	agua_con_tapa.visible = true
	fase = 2

func _llenar_vaso_agua() -> void:
	vaso_vacio.visible = false
	vaso_con_agua.visible = true
	await get_tree().create_timer(2).timeout
	agua_sin_tapa.visible = false
	vaso_con_agua.visible = false
	vaso_con_leche.visible = true
	vaso_con_leche.position = Vector2(200, 400)
	vaso_con_agua.visible = true
	vaso_con_agua.position = Vector2(600, 400)
	Estufa.visible = true
	olla_vacia.visible = true
	fase = 3

# -----------------------------------
# 🍳 Fases 3/4/5 helpers (sin cambios lógicos)
# -----------------------------------
func _on_vaso_area_entered(area):
	if fase == 3 and area.name == "AreaOlla":
		if dragging_node == vaso_con_leche and not leche_agregada:
			vaso_con_leche.visible = false
			olla_vacia.visible = false
			olla_con_leche.visible = true
			olla_con_leche.position = olla_vacia.position
			leche_agregada = true
		elif dragging_node == vaso_con_agua and not agua_agregada:
			vaso_con_agua.visible = false
			olla_con_leche.visible = false
			olla_con_agua.visible = true
			olla_con_agua.position = olla_vacia.position
			agua_agregada = true

		if leche_agregada and agua_agregada:
			fase = 4
			avena.visible = true
			cuchara_madera.visible = true

func _on_avena_area_entered(area):
	if fase == 4 and area.name == "AreaOlla":
		avena.visible = false
		olla_con_agua.visible = false
		olla_con_avena.visible = true
		olla_con_avena.position = olla_vacia.position
		avena_agregada = true

func _on_cuchara_area_entered(area):
	if fase == 4 and area.name == "AreaOlla" and avena_agregada and not cuchara_agregada:
		cuchara_madera.visible = false
		olla_con_avena.visible = false
		olla_vacia.visible = false
		olla_con_leche.visible = false
		olla_con_agua.visible = false
		avena_con_cuchara.visible = true
		avena_con_cuchara.position = olla_vacia.position
		cuchara_agregada = true
		await get_tree().create_timer(1).timeout
		_iniciar_fase5()

# -----------------------------------
# 🍯 Fase 5 helpers
# -----------------------------------
func _iniciar_fase5() -> void:
	fase = 5
	miel_de_maple.visible = true
	sal.visible = true
	cuchara.visible = true
	canela.visible = true

func _on_cuchara_ingrediente_entered(area):
	if fase == 5:
		if area.name == "AreaMiel" and cuchara.visible:
			cuchara.visible = false
			cuchara_miel.visible = true
			cuchara_miel.position = area.global_position
		elif area.name == "AreaSal" and cuchara.visible:
			cuchara.visible = false
			cuchara_sal.visible = true
			cuchara_sal.position = area.global_position

func _on_cuchara_miel_area_entered(area):
	if fase == 5 and area.name == "AreaAvenaCuchara":
		cuchara_miel.visible = false
		cuchara.visible = true
		cuchara.position = cuchara_pos_inicial
		miel_agregada = true

func _on_cuchara_sal_area_entered(area):
	if fase == 5 and area.name == "AreaAvenaCuchara":
		cuchara_sal.visible = false
		cuchara.visible = true
		cuchara.position = cuchara_pos_inicial
		sal_agregada = true

func _on_canela_area_entered(area):
	if fase == 5 and area.name == "AreaAvenaCuchara" and not canela_agregada:
		canela_agregada = true
		canela.visible = false
		await get_tree().create_timer(2).timeout
		miel_de_maple.visible = false
		cuchara.visible = false
		sal.visible = false
		plato_vacio.visible = true
		avena_con_cuchara.visible = true
		fase = 6

# -----------------------------------
# 🍽️ Fase 6
# -----------------------------------
func _on_avena_area_entered_final(area):
	if fase == 6 and area.name == "AreaPlato":
		avena_con_cuchara.visible = false
		plato_vacio.visible = false
		plato_con_avena.visible = true
		# posicion original por defecto, luego se moverá a la derecha en corte de banano
		plato_con_avena.position = plato_vacio.position
		await get_tree().create_timer(2).timeout
		plato_con_avena.visible = false
		Estufa.visible = false
		_iniciar_fase7()

# -----------------------------------
# 🍌 Fase 7: preparar frutas (NUEVO)
# -----------------------------------
func _iniciar_fase7() -> void:
	fase = 7
	tabla.visible = true
	banano_con_cascara.visible = true
	cuchillo.visible = true

	# dejar que usen posiciones del editor para banano_sin_cascara/cuchillo
	banano_sin_cascara.visible = false
	banano_picado.visible = false
	cuchillo_arriba.visible = false
	cuchillo_sigue_cursor = false
	arandanos.visible = false
	almendras.visible = false

	banano_clicks = 0
	ingredientes_agregados = 0

# --- fin del script ---
