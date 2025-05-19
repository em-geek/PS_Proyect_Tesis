extends CharacterBody2D

const speed = 200
var current_dir = "none"
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var take_damage = true
var attack_ip = false

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
const KNOCKBACK_DURATION = 0.2
const KNOCKBACK_FORCE = 300
var last_enemy_hit: Node2D = null
var taking_damage = false
var dead = false



func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	if dead:
		return # No hacer nada si está muerto

	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
	else:
		if not taking_damage:
			player_movement(delta)
		else:
			velocity = Vector2.ZERO

	move_and_slide()

	# ATAQUE SIEMPRE DISPONIBLE (mientras esté vivo)
	if not dead:
		attack()
		enemy_attack()

	if health <= 0 and not dead:
		player_alive = false
		health = 0
		dead = true
		dead_sequence()

		 
func player_movement(delta):
	if attack_ip or taking_damage:
		# No moverse ni cambiar animaciones mientras ataca o recibe daño
		return

	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		direction.x = -1
	if Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		direction.y = 1
	if Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		direction.y = -1

	if direction == Vector2.ZERO:
		play_anim(0)

	velocity = direction.normalized() * speed

	
func play_anim(movement):
	var anim = $AnimatedSprite2D
	
	# Si hay movimiento diagonal, prioriza la última dirección ingresada
	if velocity.x != 0 and velocity.y != 0:
		if Input.is_action_pressed("ui_right"):
			current_dir = "right"
		elif Input.is_action_pressed("ui_left"):
			current_dir = "left"
		elif Input.is_action_pressed("ui_down"):
			current_dir = "down"
		elif Input.is_action_pressed("ui_up"):
			current_dir = "up"

	# Definir animaciones según la dirección final
	match current_dir:
		"right":
			anim.flip_h = false
			if movement == 1:
				anim.play("side_walk") 
			else:
				if attack_ip == false:
					anim.play("side_idle")
		"left":
			anim.flip_h = true
			if movement == 1:
				anim.play("side_walk") 
			else:
				if attack_ip == false:
					anim.play("side_idle")
		"down":
			anim.flip_h = false
			if movement == 1:
				anim.play("front_walk") 
			else:
				if attack_ip == false:
					anim.play("front_idle")
		"up":
			anim.flip_h = false
			if movement == 1:
				anim.play("back_walk") 
			else:
				if attack_ip == false:
					anim.play("back_idle")


func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true
		last_enemy_hit = body

		
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown and take_damage:
		take_damage = false
		print("cooldown")
		$take_damage_player.start()
		health -= 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

		# Knockback
		if last_enemy_hit:
			var direction = (global_position - last_enemy_hit.global_position).normalized()
			knockback_velocity = direction * KNOCKBACK_FORCE
			knockback_timer = KNOCKBACK_DURATION


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false
		last_enemy_hit = null


func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
	
func attack():
	if attack_ip or taking_damage or dead:
		return

	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_atack")
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_atack")
		if dir == "down":
			$AnimatedSprite2D.play("front_atack")
		if dir == "up":
			$AnimatedSprite2D.play("back_atack")
		$deal_attack_timer.start()

			
func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
			

func _on_take_damage_player_timeout() -> void:
	take_damage = true
	print("Puedes recibir daño otra vez")

func dead_sequence():
	$AnimatedSprite2D.play("dead")
	velocity = Vector2.ZERO
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.stop() # <- Detener cualquier animación después de morir
	self.queue_free()

func play_damage_animation(direction: Vector2):
	taking_damage = true
	var anim = $AnimatedSprite2D
	
	if abs(direction.x) > abs(direction.y):
		anim.play("side_damage")
		anim.flip_h = direction.x < 0
	elif direction.y > 0:
		anim.play("back_damage")
	else:
		anim.play("front_damage")

	await anim.animation_finished
	taking_damage = false
