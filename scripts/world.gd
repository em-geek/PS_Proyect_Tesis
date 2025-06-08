extends Node2D

func _ready():
	if global.game_first_loading == true:
		$Player.position.x = global.player_start_posx
		$Player.position.y = global.player_start_posy
	else:
		$Player.position.x = global.player_exit_cliffside_posx
		$Player.position.x = global.player_exit_cliffside_posx

func _process(delta):
	change_scene()

func _on_anhedonia_transition_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_anhedonia_transition_point_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		if global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/anhedonia.tscn")
			global.game_first_loading = false
			global.finish_changescenes()
