extends CharacterBody2D

#Basicos
var speed = 40
var player_chase = false
var player = null
var health = 100
var player_inattack_zone = false
var can_take_damage = true

#Knockback
var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.2
const KNOCKBACK_FORCE = 300

#Movimiento
var jumping = false
var jump_direction = Vector2.ZERO
var jump_speed = 100.0
var jump_duration = 0.7
var jump_timer = 0.0
const JUMP_INTERVAL = 0.8

func _ready():
	$JumpTimer.wait_time = JUMP_INTERVAL
	$JumpTimer.start()


func _physics_process(delta):
	deal_with_damage()
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		jumping = false  # Cancelamos el salto
	else:
		if jumping:
			jump_timer -= delta
			velocity = jump_direction * jump_speed
			if jump_timer <= 0:
				velocity = Vector2.ZERO
				jumping = false
		else:
			velocity = Vector2.ZERO
	move_and_slide()

	# Animaciones
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("side_walk")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.play("side_idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	

func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage:
			can_take_damage = false
			$take_damage_cooldown.start()
			health -= 20
			print("slime health = ", health)

			# Knockback desde el jugador
			if player:
				var direction = (global_position - player.global_position).normalized()
				knockback_velocity = direction * KNOCKBACK_FORCE
				knockback_timer = KNOCKBACK_DURATION

			if health <= 0:
				self.queue_free()



func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func _on_jump_timer_timeout() -> void:
	if player and not jumping:
		jump_direction = (player.global_position - global_position).normalized()
		jumping = true
		jump_timer = jump_duration
