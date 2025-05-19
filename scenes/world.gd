extends Node2D

@onready var camera = $Camera2D
@onready var tilemap = $TileMap
@onready var player = $Player

func _ready():
	# Obtener el área del mapa
	var used_rect = tilemap.get_used_rect()
	var cell_size = Vector2(tilemap.tile_set.tile_size)

	# Convertir a coordenadas globales
	var top_left = tilemap.map_to_local(used_rect.position)
	var bottom_right = tilemap.map_to_local(used_rect.end) + cell_size

	var global_top_left = tilemap.to_global(top_left)
	var global_bottom_right = tilemap.to_global(bottom_right)

	# Aplicar límites globales a la cámara
	camera.limit_left = global_top_left.x
	camera.limit_top = global_top_left.y
	camera.limit_right = global_bottom_right.x
	camera.limit_bottom = global_bottom_right.y

func _process(delta):
	camera.global_position = player.global_position
