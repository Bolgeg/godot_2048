extends Node2D

func _input(_event: InputEvent) -> void:
	var grid=%GameGrid
	if Input.is_action_just_pressed("move_up"):
		grid.make_move(Vector2i(0,-1))
	elif Input.is_action_just_pressed("move_down"):
		grid.make_move(Vector2i(0,1))
	elif Input.is_action_just_pressed("move_left"):
		grid.make_move(Vector2i(-1,0))
	elif Input.is_action_just_pressed("move_right"):
		grid.make_move(Vector2i(1,0))
