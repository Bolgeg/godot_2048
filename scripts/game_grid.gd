extends Control

signal lost
signal won

var grid_size:=Vector2i(4,4)

var target_number:=2048

var already_won:=false

var undo_uses_left:=3

var grid_squares:=[]
var grid_squares_to_move:=[]

var grid_squares_history:=[]

func _ready() -> void:
	grid_size=Globals.grid_size
	target_number=Globals.target_number
	populate_grid_container()
	initialize_grid_squares()
	populate_square_container()

func _process(_delta: float) -> void:
	update_square_container()

func populate_grid_container():
	var grid_container:GridContainer=%GridContainer
	for child in grid_container.get_children():
		child.queue_free()
		grid_container.remove_child(child)
	
	grid_container.columns=grid_size.x
	
	var grid_cell_scene=preload("res://scenes/grid_cell.tscn")
	for i in range(grid_size.x*grid_size.y):
		grid_container.add_child(grid_cell_scene.instantiate())

func initialize_grid_squares():
	for y in range(grid_size.y):
		grid_squares.append([])
		grid_squares_to_move.append([])
		for x in range(grid_size.x):
			grid_squares.back().append(0)
			grid_squares_to_move.back().append(Vector2i(x,y))
	add_random_square()
	add_random_square()

func populate_square_container():
	var square_container=%SquareContainer
	for child in square_container.get_children():
		child.queue_free()
		square_container.remove_child(child)
	
	var square_scene=preload("res://scenes/square_scene.tscn")
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var square=square_scene.instantiate()
			square.visible=false
			square_container.add_child(square)

func update_square_container():
	var square_container=%SquareContainer
	var grid_container:GridContainer=%GridContainer
	var timer:Timer=%MovementTimer
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var child_index=y*grid_size.x+x
			var square=square_container.get_child(child_index)
			var cell=grid_container.get_child(child_index)
			if grid_squares[y][x]!=0:
				square.visible=true
				if timer.is_stopped():
					square.global_position=cell.global_position
				else:
					var t=timer.time_left/timer.wait_time
					var to_move:Vector2i=grid_squares_to_move[y][x]
					var child_index_b=to_move.y*grid_size.x+to_move.x
					var cell_b=grid_container.get_child(child_index_b)
					square.global_position=lerp(cell_b.global_position,cell.global_position,t)
				square.size=cell.size
				square.update(grid_squares[y][x])
			else:
				square.visible=false

func get_free_cells()->Array:
	var cells:=[]
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid_squares[y][x]==0:
				cells.append(Vector2i(x,y))
	return cells

func add_random_square():
	var cells:=get_free_cells()
	if not cells.is_empty():
		var index=randi_range(0,cells.size()-1)
		var cell=cells[index]
		var number=4 if randf()<0.1 else 2
		grid_squares[cell.y][cell.x]=number

func get_line_movement_join(line:Array,origins:Array,index:int)->bool:
	if line[index]!=0:
		if line[index]==line[index+1]:
			origins[index].append_array(origins[index+1])
			for i in range(index+1,line.size()-1):
				origins[i]=origins[i+1].duplicate(true)
				line[i]=line[i+1]
			origins[-1].clear()
			line[-1]=0
		else:
			var index_b:=index+1
			while index_b<line.size():
				if line[index_b]==line[index]:
					break
				elif line[index_b]!=0:
					return true
				index_b+=1
			if index_b>=line.size():
				return true
			
			for i in range(index+1,line.size()-1):
				origins[i]=origins[i+1].duplicate(true)
				line[i]=line[i+1]
			origins[-1].clear()
			line[-1]=0
			return false
	else:
		var full_zeros:=true
		for i in range(index,line.size()):
			if line[i]!=0:
				full_zeros=false
				break
		if full_zeros:
			return true
		
		for i in range(index,line.size()-1):
			origins[i]=origins[i+1].duplicate(true)
			line[i]=line[i+1]
		origins[-1].clear()
		line[-1]=0
		return false
	return true

func get_line_movement(original_line:Array,direction:int)->Array:
	var line=original_line.duplicate(true)
	if direction==1:
		line.reverse()
	
	var origins:=[]
	for i in original_line.size():
		origins.append([i])
	
	var index:=0
	while index<original_line.size()-1:
		if get_line_movement_join(line,origins,index):
			index+=1
	
	var to_move:=[]
	for i in original_line.size():
		to_move.append(0)
	for i in original_line.size():
		for j in origins[i]:
			to_move[j]=i-j
	if direction==1:
		to_move.reverse()
		for i in original_line.size():
			to_move[i]=-to_move[i]
	return to_move

func array_is_full_zeros(array:Array)->bool:
	for i in array:
		if i!=0:
			return false
	return true

func move_row(row_index:int,direction:int)->bool:
	var line:=[]
	for i in range(grid_size.x):
		line.append(grid_squares[row_index][i])
	
	var to_move=get_line_movement(line,direction)
	
	for i in range(grid_size.x):
		grid_squares_to_move[row_index][i]=Vector2i(i+to_move[i],row_index)
	
	return not array_is_full_zeros(to_move)

func move_column(column_index:int,direction:int)->bool:
	var line:=[]
	for i in range(grid_size.y):
		line.append(grid_squares[i][column_index])
	
	var to_move=get_line_movement(line,direction)
	
	for i in range(grid_size.y):
		grid_squares_to_move[i][column_index]=Vector2i(column_index,i+to_move[i])
	
	return not array_is_full_zeros(to_move)

func movement_end():
	var new_grid_squares:=[]
	for y in range(grid_size.y):
		new_grid_squares.append([])
		for x in range(grid_size.x):
			new_grid_squares.back().append(0)
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var to_move=grid_squares_to_move[y][x]
			new_grid_squares[to_move.y][to_move.x]+=grid_squares[y][x]
			grid_squares_to_move[y][x]=Vector2i(x,y)
	grid_squares=new_grid_squares.duplicate(true)
	
	add_random_square()
	check_if_won_or_lost()

func _on_movement_timer_timeout() -> void:
	movement_end()

func can_move()->bool:
	if not get_free_cells().is_empty():
		return true
	for y in range(grid_size.y):
		for x in range(grid_size.x-1):
			if grid_squares[y][x]==grid_squares[y][x+1]:
				return true
	for x in range(grid_size.x):
		for y in range(grid_size.y-1):
			if grid_squares[y][x]==grid_squares[y+1][x]:
				return true
	return false

func target_reached()->bool:
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid_squares[y][x]>=target_number:
				return true
	return false

func check_if_won_or_lost():
	if not can_move():
		lost.emit()
	elif target_reached() and not already_won:
		won.emit()
		already_won=true

func stop_movement():
	var timer:Timer=%MovementTimer
	if not timer.is_stopped():
		timer.stop()
		movement_end()

func make_move(direction:Vector2i):
	stop_movement()
	
	var changed:=false
	if direction.x!=0:
		for i in range(grid_size.y):
			if move_row(i,direction.x):
				changed=true
	else:
		for i in range(grid_size.x):
			if move_column(i,direction.y):
				changed=true
	
	if changed:
		grid_squares_history.append(grid_squares.duplicate(true))
		%MovementTimer.start()

func get_score()->int:
	var maximum:=0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid_squares[y][x]>maximum:
				maximum=grid_squares[y][x]
	return maximum

func get_undo_uses_left()->int:
	return undo_uses_left

func undo():
	if undo_uses_left>0 and not grid_squares_history.is_empty():
		stop_movement()
		grid_squares=grid_squares_history[-1].duplicate(true)
		grid_squares_history.remove_at(grid_squares_history.size()-1)
		undo_uses_left-=1
