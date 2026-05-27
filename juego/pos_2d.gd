extends Area2D

# --- CONSTANTES DE ANIMACIÓN Y FLOTACIÓN ---
const ANIMATION_NAME = "idle" # Nombre de tu clip de animación.
const FALL_DELAY_TIME = 12.0    # Tiempo que espera ANTES de caer.
const FLOAT_SPEED = 2.8         # Velocidad de la onda de flotación.
const FLOAT_AMPLITUDE = 30.0    # Altura máxima de la flotación.
const FALL_SPEED = 200.0        # Velocidad de la caída (después del retardo).
const GROUND_Y = 15.0           # Coordenada Y donde aterriza y comienza a flotar (AJUSTA ESTO).


# --- Nodos ---
@onready var animationPlayer = $Sprite2D/AnimationPlayer
# Asumo que tienes un Sprite2D como hijo para la animación y el efecto visual
@onready var sprite = $Sprite2D 


# --- VARIABLES DE ESTADO ---
var initial_y: float             # La posición Y de referencia para la flotación.
var is_falling = false          # Estado: ¿Está cayendo en este momento?
var has_started_falling = false # Estado: ¿Ya terminó su fase inicial de caída?


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Inicia la animación inmediatamente.
	if animationPlayer:
		animationPlayer.play(ANIMATION_NAME)

	# 2. ESPERA: Pausa la función y espera el tiempo de retraso inicial.
	await get_tree().create_timer(FALL_DELAY_TIME).timeout

	# Verificar si el objeto sigue siendo válido después de la espera
	if not is_instance_valid(self):
		return

	# 3. Después del retraso, activa la caída.
	is_falling = true
	has_started_falling = true
	# Almacenamos la posición Y actual como base inicial (antes de caer)
	initial_y = global_position.y


# Called every frame. 'delta' es el tiempo transcurrido desde el último frame.
func _process(delta: float) -> void:
	if is_falling:
		# 1. LÓGICA DE CAÍDA (Mueve la posición Y hacia abajo)
		global_position.y += FALL_SPEED * delta

		# 2. Verificar el aterrizaje
		if global_position.y >= GROUND_Y:
			global_position.y = GROUND_Y 
			is_falling = false
			# La base para la flotación es la coordenada final
			initial_y = global_position.y 
	
	# La lógica de flotación solo se ejecuta si ya terminó de caer
	elif has_started_falling:
		# 3. LÓGICA DE FLOTACIÓN
		# Usa la función seno para crear una onda suave
		var offset_y = sin(Time.get_ticks_msec() / 1000.0 * FLOAT_SPEED) * FLOAT_AMPLITUDE
		
		# Aplica la flotación sobre la posición Y base (GROUND_Y)
		global_position.y = initial_y + offset_y


# Esta función DEBE estar conectada a la señal 'body_entered' del nodo Area2D en el editor.
func _on_body_entered(body: Node2D) -> void: 
	# Esta es la lógica para la recolección
	
	# 1. Elimina la poción
	queue_free()
	
	# 2. Cambia de escena al ser recolectada
	get_tree().change_scene_to_file("res://cocina2.tscn")
