extends Node2D

func _ready():
	var video = $VideoStreamPlayer
	video.stream = load("res://nutrichef3.webm")
	if video.stream:
		video.play()
	else:
		print("⚠️ No se pudo cargar el video")
