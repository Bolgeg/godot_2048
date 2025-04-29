extends Node2D

var game_stopped:=false

func _ready() -> void:
	%GameOverMessage.visible=false
	%YouWinMessage.visible=false

func _input(_event: InputEvent) -> void:
	var grid=%GameGrid
	if not game_stopped:
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
	update_game_over_message_color()
	update_you_win_message_color()

func _on_undo_button_pressed() -> void:
	if not game_stopped:
		%GameGrid.undo()

func _on_game_grid_lost() -> void:
	game_stopped=true
	show_game_over_message()

func _on_game_grid_won() -> void:
	game_stopped=true
	show_you_win_message()

func show_game_over_message():
	%MessageTimer.start()
	%GameOverMessage.visible=true
	update_game_over_message_color()

func show_you_win_message():
	%MessageTimer.start()
	%YouWinMessage.visible=true
	update_you_win_message_color()

func update_game_over_message_color():
	if %GameOverMessage.visible:
		var t=1-%MessageTimer.time_left/%MessageTimer.wait_time
		%GameOverPanel.get_theme_stylebox("panel").bg_color=Color8(0,0,0,lerp(0,128,t))

func update_you_win_message_color():
	if %YouWinMessage.visible:
		var t=1-%MessageTimer.time_left/%MessageTimer.wait_time
		%YouWinPanel.get_theme_stylebox("panel").bg_color=Color8(255,255,0,lerp(0,128,t))

func _on_keep_going_button_pressed() -> void:
	keep_going()

func keep_going():
	%YouWinMessage.visible=false
	game_stopped=false

func _on_try_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
