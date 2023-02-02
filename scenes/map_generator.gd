extends Node2D

const Room := preload("res://scenes/room.gd")
const Map := preload("res://scenes/map.gd")

@export var width := 100
@export var height := 100

var map: Map

const CELL_SIZE = 6
const WALL = 0
const FLOOR = 1
const SMALL_ROOM_THRESHOLD = 20

func _ready() -> void:
	seed(1)
	generate_map()

func generate_map():
	map = Map.new(width, height, WALL, FLOOR)
	map.small_room_threshold = SMALL_ROOM_THRESHOLD
	map.generate()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_map()
		queue_redraw()

func _draw() -> void:
	for x in range(width):
		for y in range(height):
			if map.get_cell(x, y) == WALL:
				draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), Color.SADDLE_BROWN)
			else:
				draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), Color.WHITE)

	for room in map.rooms:
		for cell in room.cells:
			var color = Color.LIGHT_GRAY
			draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)
