extends Resource

const Map := preload("res://scenes/map.gd")

var map: Map
var cells: Array[Vector2i] = []
var edges: Array[Vector2i] = []

func _init(map: Map) -> void:
	self.map = map

func is_empty() -> bool:
	return size() == 0

func size() -> int:
	return cells.size()

func find_edges() -> void:
	for cell in cells:
		if is_edge(cell):
			edges.append(cell)

func is_edge(cell: Vector2i) -> bool:
	# right
	if !map.is_in_map(cell.x + 1, cell.y) || map.get_cell(cell.x + 1, cell.y) == map.wall:
		return true
	# top
	if !map.is_in_map(cell.x, cell.y - 1) || map.get_cell(cell.x, cell.y - 1) == map.wall:
		return true
	# left
	if !map.is_in_map(cell.x - 1, cell.y) || map.get_cell(cell.x - 1, cell.y) == map.wall:
		return true
	# bottom
	if !map.is_in_map(cell.x, cell.y + 1) || map.get_cell(cell.x, cell.y + 1) == map.wall:
		return true
	return false
