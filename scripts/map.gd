extends Resource

const Room := preload("res://scripts/room.gd")

var width: int
var height: int
var wall: int
var floor: int
var small_room_threshold: int

var cells: PackedByteArray
var rooms: Array[Room] = []
var debug_cells: Array[Vector2i] = []

func _init(width: int, height: int, wall: int, floor: int):
	self.width = width
	self.height = height
	self.wall = wall
	self.floor = floor

func generate() -> void:
	cells = generate_empty_map(wall)
	generate_noise()
	for x in range(5):
		apply_cellular_automata()
	apply_cellular_automata(5)
	scan_rooms()
	fill_small_rooms_with_wall()
	connect_rooms()

func generate_empty_map(fill_with: int = 0):
	var cells = PackedByteArray()
	cells.resize(width * height)
	cells.fill(fill_with)
	return cells

func generate_noise() -> void:
	for x in range(width):
		for y in range(height):
			if randf() < 0.6:
				set_cell(x, y, wall)
			else:
				set_cell(x, y, floor)

func apply_cellular_automata(wall_threshold: int = 4) -> void:
	var new_cells = generate_empty_map(0)
	for x in range(width):
		for y in range(height):
			var walls_count := get_walls_count(x, y, wall)
			if walls_count > wall_threshold:
				new_cells[x + y * width] = wall
			else:
				new_cells[x + y * width] = floor
	cells = new_cells

func scan_rooms() -> void:
	rooms = []
	var scanned_map = generate_empty_map(0)
	for x in range(width):
		for y in range(height):
			if get_cell(x, y) == wall:
				scanned_map[x + y * width] = 1
			else:
				var room = scan_room(x, y, scanned_map)
				if !room.is_empty():
					rooms.append(room)

func fill_small_rooms_with_wall() -> void:
	for room in rooms:
		if room.cells.size() < small_room_threshold:
			for cell in room.cells:
				set_cell(cell.x, cell.y, wall)
	rooms = rooms.filter(func(room: Room): return room.size() >= small_room_threshold)

func set_cell(x: int, y: int, value: int) -> void:
	cells[x + y * width] = value

func get_cell(x: int, y: int) -> int:
	return cells[x + y * width]

func is_in_map(x: int, y: int) -> bool:
	return x >= 0 && x < width && y >= 0 && y < height

func connect_rooms() -> void:
	while rooms.size() > 1:
		rooms.sort_custom(func(a, b): return a.size() < b.size())
		for room in rooms:
			room.find_edges()
			var result = find_nearest_floor_for_room(room)
			var edge = result[0]
			var target = result[1]
			create_tunnel(edge, target)
		scan_rooms()

# private

func get_walls_count(x: int, y: int, wall: int) -> int:
	var walls_count = 0
	if x + 1 >= width || get_cell(x + 1, y) == wall: walls_count += 1 # right
	if y - 1 < 0 || get_cell(x, y - 1) == wall: walls_count += 1 # top
	if x - 1 < 0 || get_cell(x - 1, y) == wall: walls_count += 1 # left
	if y + 1 >= height || get_cell(x, y + 1) == wall: walls_count += 1 # bottom
	if x + 1 >= width || y - 1 < 0 || get_cell(x + 1, y - 1) == wall: walls_count += 1 # top-right
	if x - 1 < 0 || y - 1 < 0 || get_cell(x - 1, y - 1) == wall: walls_count += 1 # top-left
	if x - 1 < 0 || y + 1 >= height || get_cell(x - 1, y + 1) == wall: walls_count += 1 # bottom-left
	if x + 1 >= width || y + 1 >= height || get_cell(x + 1, y + 1) == wall: walls_count += 1 # bottom-right
	return walls_count

func scan_room(x: int, y: int, scanned_map) -> Room:
	var room := Room.new(self)
	var unscaned_cells : Array[Vector2i] = [Vector2i(x, y)]

	while unscaned_cells.size() > 0:
		var cell = unscaned_cells.pop_front()
		for unscaned_cell in scan_cell(cell.x, cell.y, scanned_map, room):
			unscaned_cells.push_back(unscaned_cell)
	return room

func scan_cell(x: int, y: int, scanned_map, room: Room) -> Array[Vector2i]:
	if !is_in_map(x, y):
		return []
	if get_cell(x, y) == wall || scanned_map[x + y * width] == 1:
		return []
	scanned_map[x + y * width] = 1
	room.cells.append(Vector2i(x, y))

	return [
		Vector2i(x + 1, y),
		Vector2i(x, y - 1),
		Vector2i(x - 1, y),
		Vector2i(x, y + 1)
	]

func get_square_points(size: int) -> Array[Vector2i]:
	var half_of_size = size / 2
	var result: Array[Vector2i] = []
	# top border
	for x in range(-half_of_size, half_of_size):
		result.append(Vector2i(x, -half_of_size))
	# right border
	for y in range(-half_of_size, half_of_size):
		result.append(Vector2i(half_of_size, y))
	# bottom border
	for x in range(half_of_size, -half_of_size, -1):
		result.append(Vector2i(x, half_of_size))
	# left border
	for y in range(half_of_size, -half_of_size, -1):
		result.append(Vector2i(-half_of_size, y))
	return result

func find_nearest_floor_for_room(room: Room) -> Array[Vector2i]:
	var size = 3
	while true:
		for edge in room.edges:
			for offset in get_square_points(size):
				var possible_floor = edge + offset
				if room.cells.has(possible_floor):
					continue
				if !is_in_map(possible_floor.x, possible_floor.y):
					continue
				if get_cell(possible_floor.x, possible_floor.y) == wall:
					continue
				return [edge, possible_floor]
		size += 2
	return [] # should not reach this

func create_tunnel(from: Vector2i, to: Vector2i) -> void:
	var tunnel_direction = to - from
	var tunnel
	if abs(tunnel_direction.x) > abs(tunnel_direction.y):
		tunnel = create_tunnel_from_x(from, to)
	else:
		tunnel = create_tunnel_from_y(from, to)
	for cell in tunnel:
		dig(cell.x, cell.y)
		dig(cell.x + 1, cell.y)
		dig(cell.x, cell.y - 1)
		dig(cell.x - 1, cell.y)
		dig(cell.x, cell.y + 1)
		debug_cells.append(cell)

func create_tunnel_from_x(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var tunnel: Array[Vector2i] = []
	if from.x > to.x:
		var temp := to
		to = from
		from = temp
	for x in range(from.x, to.x + 1):
		var y := roundi(remap(x, from.x, to.x, from.y, to.y))
		tunnel.append(Vector2i(x, y))
	return tunnel

func create_tunnel_from_y(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var tunnel: Array[Vector2i] = []
	if from.y > to.y:
		var temp := to
		to = from
		from = temp
	for y in range(from.y, to.y + 1):
		var x := roundi(remap(y, from.y, to.y, from.x, to.x))
		tunnel.append(Vector2i(x, y))
	return tunnel

func dig(x: int, y: int) -> void:
	if is_in_map(x, y):
		set_cell(x, y, floor)
