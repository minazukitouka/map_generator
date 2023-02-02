extends Node2D

const Room := preload("res://scenes/room.gd")
const Map := preload("res://scenes/map.gd")

@export var width := 100
@export var height := 100

@onready var tile_map: TileMap = $TileMap
@onready var scroller := $Scroller

var map: Map

const CELL_SIZE = 2
const WALL = 0
const FLOOR = 1
const SMALL_ROOM_THRESHOLD = 20

func _ready() -> void:
	generate_map()

func generate_map():
	var start_time := Time.get_ticks_msec()
	map = Map.new(width, height, WALL, FLOOR)
	map.small_room_threshold = SMALL_ROOM_THRESHOLD
	map.generate()
	redraw_tilemap()
	var elapsed_time := Time.get_ticks_msec() - start_time
	print(elapsed_time, 'ms')

func redraw_tilemap() -> void:
	var cells : Array[Vector2i] = []
	tile_map.clear()
	for x in range(width):
		for y in range(height):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1))
			if randf() < 0.05:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 1))
			if map.get_cell(x, y) == FLOOR:
				cells.append(Vector2i(x, y))
	tile_map.set_cells_terrain_connect(0, cells, 0, 0)
	scroller.set_camera_limit(Rect2(0, 0, width * 16, height * 16))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_map()
		queue_redraw()
