extends Control

const GRID_SIZES:=[2,3,4,5,6,7,8]
const TARGET_NUMBERS:=[
	8,
	16,
	32,
	64,
	128,
	256,
	512,
	1024,
	2048,
	4096,
	8192,
	16384,
	32768,
	65536,
	131072,
	262144,
	524288,
	1048576
]

func _ready() -> void:
	var grid_size_button=%GridSizeOptionButton
	for grid_size in GRID_SIZES:
		grid_size_button.add_item(str(grid_size)+"x"+str(grid_size))
	grid_size_button.selected=GRID_SIZES.find(4)
	
	var target_number_button=%TargetNumberOptionButton
	for target_number in TARGET_NUMBERS:
		target_number_button.add_item(str(target_number))
	target_number_button.selected=TARGET_NUMBERS.find(2048)

func _on_play_button_pressed() -> void:
	var grid_size=GRID_SIZES[%GridSizeOptionButton.selected]
	Globals.grid_size=Vector2i(grid_size,grid_size)
	Globals.target_number=TARGET_NUMBERS[%TargetNumberOptionButton.selected]
	get_tree().change_scene_to_file("res://scenes/game.tscn")
