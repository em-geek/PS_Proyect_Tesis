extends RigidBody2D

@onready var hitbox = $Hitbox
@onready var can_be_kicked = true
@onready var player = null
@export var goal_position: Vector2

var kicked := false
const KNOCKBACK_FORCE = 600


func _on_hitbox_entered(body):
	if body.name == "Player":
		player = body

func _on_hitbox_exited(body):
	if body == player:
		player = null

func _physics_process(delta):
	if not kicked and player and global.player_current_attack and can_be_kicked:
		kick_from_player()

func kick_from_player():
	kicked = true
	can_be_kicked = false
	var direction = (global_position - player.global_position).normalized()
	apply_impulse(Vector2.ZERO, direction * KNOCKBACK_FORCE)
	print("¡Pelota golpeada!")

	# Puedes iniciar aquí un Timer si deseas permitir otro golpe después de un rato
