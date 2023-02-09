extends Node

const Room := preload("res://scripts/room.gd")
const Map := preload("res://scripts/map.gd")

@export var width := 100
@export var height := 100

@export var water_plain: PackedScene
@export var floor_cell: PackedScene

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
	generate_terrain()
	var elapsed_time := Time.get_ticks_msec() - start_time
	print(elapsed_time, 'ms')

func generate_terrain() -> void:
	var water = water_plain.instantiate()
	water.mesh.size = Vector2i(width, height) * 2
	water.mesh.subdivide_depth = width
	water.mesh.subdivide_width = height
	water.position = Vector3(width / 2, 0, height / 2)
	add_child(water)

	for x in range(width):
		for y in range(height):
			if map.get_cell(x, y) == FLOOR:
				var cell = floor_cell.instantiate()
				cell.position = Vector3(x, 0.5, y)
				add_child(cell)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_map()
