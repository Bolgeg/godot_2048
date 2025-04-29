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

func _process(_delta: float) -> void:
	%ScoreLabel.text="Score: "+str(%GameGrid.get_score())
	%UndoUsesLeftLabel.text="Undo uses left: "+str(%GameGrid.get_undo_uses_left())


func _on_undo_button_pressed() -> void:
	%GameGrid.undo()
