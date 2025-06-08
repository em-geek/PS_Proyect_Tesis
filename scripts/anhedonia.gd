extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_scenes()


func _on_anhedonia_exitpoint_body_entered(body):
	if body.has_method("player"):
		global.transition_scene = true


func _on_anhedonia_exitpoint_body_shape_exited(body):
	if body.has_method("player"):
		global.transition_scene = false
		
func change_scenes():
	if global.transition_scene == true:
		global.current_scene = "anhedonia"
		if global.current_scene == "anhedonia":
			get_tree().change_scene_to_file("res://scenes/world.tscn")
			global.finish_changescenes()
			global.current_scene = "world"
		
