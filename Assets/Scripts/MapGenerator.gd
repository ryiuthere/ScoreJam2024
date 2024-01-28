extends TileMap

var CONNECTION_RANDOMIZER_WEIGHT := [ 0.5, 0.5, 0.5, 0.5, 0.5, 0.35, 0.35, 0.5, 0.5, 0.5, 0.5, 0.5]

var tileset_width := 35
var origin_initial_coords := Vector2i(-300, -tileset_width)
var map_initial_coords := Vector2i(18, -2 * tileset_width + 1)
var tileset_count = {}

func _ready() -> void:
	calc_tileset_count()
	randomize_tileset()

func randomize_tileset() -> void:
	var tileset = get_randomized_tileset()
	for i in range(3):
		for j in range(3):
			var variant = randi() % tileset_count[tileset[i][j]]
			draw_tile(Vector2i(i,j), tileset[i][j], variant)
	for i in range(-20, 165):
		for j in range(map_initial_coords.y, map_initial_coords.y + 3 * tileset_width):
			var type_string = ""
			var target_position = Vector2i(i,j)
			var tile_data = get_cell_tile_data(0, target_position)
			if tile_data:
				for y in range(-1,2):
					for x in range(-1,2):
						var position_neighbor = Vector2i(i + x, j + y)
						var tile_id_neighbor = get_cell_tile_data(0, position_neighbor)
						if tile_id_neighbor:
							type_string += "1"
						else:
							type_string += "0"
				set_cell(0, target_position, get_cell_source_id(0, target_position), get_atlas(type_string))

func calc_tileset_count() -> void:
	for i in range(16):
		var tileset_exists = true
		var count = 0
		while tileset_exists:
			var tile_id = get_cell_tile_data(0, origin_initial_coords - Vector2i(i * tileset_width, count * tileset_width))
			if (tile_id):
				count += 1
			else:
				tileset_exists = false
				tileset_count[map_to_type(i)] = count

func map_to_type(tileset_num: int) -> String:
	match tileset_num:
		0:
			return "1111"
		1:
			return "1110"
		2:
			return "0111"
		3:
			return "1011"
		4:
			return "1101"
		5:
			return "1100"
		6:
			return "1010"
		7:
			return "1001"
		8:
			return "0110"
		9:
			return "0101"
		10:
			return "0011"
		11:
			return "1000"
		12:
			return "0100"
		13:
			return "0010"
		14:
			return "0001"
		15:
			return "0000"
		_:
			return "1111"

func get_atlas(type: String) -> Vector2i:
	match type:
		"011111111":
			return Vector2i(0,3)
		"110111111":
			return Vector2i(2,3)
		"111111011":
			return Vector2i(0,5)
		"111111110":
			return Vector2i(2,5)
	match type[1] + type[5] + type[7] + type[3]:
		"0110":
			return Vector2i(0,0)
		"0111":
			return Vector2i(1,0)
		"0011":
			return Vector2i(2,0)
		"1110":
			return Vector2i(0,1)
		"1111":
			return Vector2i(1,1)
		"1011":
			return Vector2i(2,1)
		"1100":
			return Vector2i(0,2)
		"1101":
			return Vector2i(1,2)
		"1001":
			return Vector2i(2,2)
		_:
			return Vector2i(1,1)

func draw_tile(location: Vector2i, type: String, variant: int) -> void:
	var tile_location = get_tileset_location(type, variant)
	var target_location = map_initial_coords + location * tileset_width 
	for i in range(tileset_width):
		for j in range(tileset_width):
			var target_tile_origin = tile_location + Vector2i(i,j)
			var tile_id = get_cell_tile_data(0, target_tile_origin)
			if (tile_id):
				var source_id = get_cell_source_id(0, target_tile_origin);
				var atlas_position = get_cell_atlas_coords(0, target_tile_origin)
				set_cell(0, target_location + Vector2i(i,j), source_id, atlas_position)
			else:
				set_cell(0, target_location + Vector2i(i,j), -1)

func get_tileset_location(type: String, variant: int) -> Vector2i:
	match type:
		"1111":
			return origin_initial_coords - Vector2i(0, variant * tileset_width)
		"1110":
			return origin_initial_coords - Vector2i(tileset_width, variant * tileset_width)
		"0111":
			return origin_initial_coords - Vector2i(tileset_width * 2, variant * tileset_width)
		"1011":
			return origin_initial_coords - Vector2i(tileset_width * 3, variant * tileset_width)
		"1101":
			return origin_initial_coords - Vector2i(tileset_width * 4, variant * tileset_width)
		"1100":
			return origin_initial_coords - Vector2i(tileset_width * 5, variant * tileset_width)
		"1010":
			return origin_initial_coords - Vector2i(tileset_width * 6, variant * tileset_width)
		"1001":
			return origin_initial_coords - Vector2i(tileset_width * 7, variant * tileset_width)
		"0110":
			return origin_initial_coords - Vector2i(tileset_width * 8, variant * tileset_width)
		"0101":
			return origin_initial_coords - Vector2i(tileset_width * 9, variant * tileset_width)
		"0011":
			return origin_initial_coords - Vector2i(tileset_width * 10, variant * tileset_width)
		"1000":
			return origin_initial_coords - Vector2i(tileset_width * 11, variant * tileset_width)
		"0100":
			return origin_initial_coords - Vector2i(tileset_width * 12, variant * tileset_width)
		"0010":
			return origin_initial_coords - Vector2i(tileset_width * 13, variant * tileset_width)
		"0001":
			return origin_initial_coords - Vector2i(tileset_width * 14, variant * tileset_width)
		"0000":
			return origin_initial_coords - Vector2i(tileset_width * 15, variant * tileset_width)
		_:
			return origin_initial_coords

func get_randomized_tileset() -> Array:
	var connections : Array
	var tiles := [["", "", ""],["", "", ""],["", "", ""]]
	var valid_map = false
	while (!valid_map):
		connections = []
		for i in range(12):
			connections.append("1" if randf_range(0,1) < CONNECTION_RANDOMIZER_WEIGHT[i] else "0")
		tiles[0][0] = "0%s%s0" % [connections[0], connections[2]]
		tiles[0][1] = "%s%s%s1" % [connections[2],connections[5],connections[7]]
		tiles[0][2] = "%s%s00" % [connections[7], connections[10]]
		tiles[1][0] = "0%s%s%s" % [connections[1],connections[3],connections[0]]
		tiles[1][1] = "%s%s%s%s" % [connections[3],connections[6],connections[8],connections[5]]
		tiles[1][2] = "%s%s0%s" % [connections[8],connections[11],connections[10]]
		tiles[2][0] = "00%s%s" % [connections[4], connections[1]]
		tiles[2][1] = "%s1%s%s" % [connections[4],connections[9],connections[6]]
		tiles[2][2] = "%s00%s" % [connections[9], connections[11]]
		valid_map = path_exists(tiles)
	return tiles

func path_exists(tiles: Array) -> bool:
	var initial_position = MapPosition.new()
	initial_position.connections = tiles[0][1]
	initial_position.position = Vector2i(0,1)
	return path_finder(tiles, [initial_position], [[false, false, false],[false, false, false],[false, false, false]])
	
func path_finder(tiles: Array, to_search: Array, searched: Array) -> bool:
	if (to_search.size() == 0):
		return false
	if (to_search[0].position == Vector2i(2,1)):
		return true
	else:
		var node = to_search.pop_front()
		searched[node.position.x][node.position.y] = true
		to_search += node.get_connected_nodes(tiles, searched)
		to_search.sort_custom(sort_map_positions)
		return path_finder(tiles, to_search, searched)

func sort_map_positions(a: MapPosition, b: MapPosition) -> bool:
	return a.heuristic() < b.heuristic()

func debug_print_map(connections: Array) -> void:
	print("Map:")
	print("o %s o %s o" % ["-" if connections[0] == "1" else " ","-" if connections[1] == "1" else " "])
	print("%s   %s   %s" % ["|" if connections[2] == "1" else " ", "|" if connections[3] == "1" else " ", "|" if connections[4] == "1" else " "])
	print("o %s o %s o" % ["-" if connections[5] == "1" else " ", "-" if connections[6] == "1" else " "])
	print("%s   %s   %s" % ["|" if connections[7] == "1" else " ", "|" if connections[8] == "1"else " ", "|" if connections[9] == "1" else " "])
	print("o %s o %s o" % ["-" if connections[10] == "1" else " ", "-" if connections[11] == "1" else " "])

class MapPosition:
	var connections: String
	var position: Vector2i
	func heuristic() -> int:
		return abs(2 - position.x) + abs(1 - position.y)
	func get_connected_nodes(tiles: Array, searched: Array) -> Array:
		var connected_nodes = []
		var next_position = position + Vector2i.UP
		if connections[0] == "1" and check_bounds(next_position) and !searched[next_position.x][next_position.y]:
			connected_nodes.append(create_child(tiles, position + Vector2i.UP))
		next_position = position + Vector2i.RIGHT
		if connections[1] == "1" and check_bounds(next_position) and !searched[next_position.x][next_position.y]:
			connected_nodes.append(create_child(tiles, position + Vector2i.RIGHT))
		next_position = position + Vector2i.DOWN
		if connections[2] == "1" and check_bounds(next_position) and !searched[next_position.x][next_position.y]:
			connected_nodes.append(create_child(tiles, position + Vector2i.DOWN))
		next_position = position + Vector2i.LEFT
		if connections[3] == "1" and check_bounds(next_position) and !searched[next_position.x][next_position.y]:
			connected_nodes.append(create_child(tiles, position + Vector2i.LEFT))
		return connected_nodes
	func create_child(tiles: Array, target_position: Vector2i) -> MapPosition:
		var child = MapPosition.new()
		child.connections = tiles[target_position.x][target_position.y]
		child.position = target_position
		return child
		
	func check_bounds(target_position: Vector2i) -> bool:
		return target_position.x >= 0 and target_position.x < 3 and target_position.y >= 0 and target_position.y < 3
