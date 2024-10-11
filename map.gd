extends Sprite2D

signal hex_touched(pos, hex, key)

#const MAPH : String = "res://assets/map-h.png"
#const MAPV : String = "res://assets/map-v.png"
const BLOCK : String = "res://assets/block.png"
const BLACK : String = "res://assets/black.png"
const MOVE : String = "res://assets/move.png"
const SHORT : String = "res://assets/short.png"
const RED : String = "res://assets/red.png"
const GREEN : String = "res://assets/green.png"
const TREE : String = "res://assets/tree.png"
const CITY : String = "res://assets/city.png"
const MOUNT : String = "res://assets/mountain.png"

var drag : Sprite2D

var board : HexMap
var prev : Vector2
var hexes : Dictionary
var hex_rotation : int
var p0 : Vector2
var p1 : Vector2
var los : Array
var move : Array
var short : Array
var influence : Array
var unit : Unit
var show_los : bool
var show_move : bool
var show_influence : bool

var children : Array
var players : Array = ['player']
var player_cities : Array
var player_territory: Array
var units_positions: Array
var units: Dictionary
var color_hexes: Dictionary

func get_free_hexes(position: Vector2) -> Vector2:
	var i = position[0]
	var j = position[1]
	var vecs: Array = [
		Vector2(i-1, j-1),
		Vector2(i+1, j+1),
		Vector2(i+1, j),
		Vector2(i, j+1),
		Vector2(i-1, j),
		Vector2(i, j-1),
	]
	for vec in vecs:
		if vec not in units_positions:
			return vec
	return Vector2(-1,-1)
	
func spawn_unit(position: Vector2) -> void:
	var unit_texture = "res://assets/tank.png"
	var unit_position = get_free_hexes(position)
	if unit_position != Vector2(-1,-1):
		add_entity(unit_position, unit_texture)
		print("add")
	
func add_entity(position: Vector2, texture: String):
	children.append(Sprite2D.new())
	children[-1].texture = load(texture)
	add_child(children[-1])
	children[-1].position = board.center_of(position)
	units_positions.append(position)
	units[position] = children[-1]
	
func conquer_territory() -> void:
	for position in units_positions:
		color_hexes[position].texture = load("res://assets/green.png")
	
	#$Tank.position = board.center_of(p0)
	#var sprite = Sprite2D.new()
	#sprite.texture = load("res://assets/city.png")
	#add_child(sprite)
	#sprite.position = board.center_of(p1)

func _ready():
	drag = null
	unit = Unit.new()
	rotate_map()

func reset() -> void:
	los.clear()
	move.clear()
	short.clear()
	influence.clear()
	hexes.clear()
	hexes[-1] = Hex.new()	# off map
	p0 = Vector2(0, 0)
	
	#$Tank.position = board.center_of(p0)
	#var sprite = Sprite2D.new()
	#sprite.texture = load("res://assets/city.png")
	#add_child(sprite)
	#sprite.position = board.center_of(p1)
	
	#for i in range(2,3):
	
	#
	#var n = 5
	#var vecs: Array = [
		#Vector2(n-1, n-1),
		#Vector2(n, n),
		#Vector2(n+1, n+1),
		#Vector2(n+1, n),
		#Vector2(n, n+1),
		#Vector2(n-1, n),
		#Vector2(n, n-1),
#
	#]
	#p1 = Vector2(5, 5)
	#for vec in vecs:
		#children.append(Sprite2D.new())
		#children[-1].texture = load("res://assets/city.png")
		#add_child(children[-1])
		#children[-1].position = board.center_of(vec)
		#
		
	#p1 = Vector2(3, 3)
	#children.append(Sprite2D.new())
	#children[-1].texture = load("res://assets/city.png")
	#add_child(children[-1])
	#children[-1].position = board.center_of(p1)
	
	#$Target.position = board.center_of(p1)
	p1 = Vector2(3, 3)
	children.append(Sprite2D.new())
	children[-1].texture = load("res://assets/city.png")
	add_child(children[-1])
	children[-1].position = board.center_of(p1)
	player_cities.append(p1)
	color_hexes[p1].texture = load("res://assets/green.png")
	
	print(hexes)
	for hex in $Hexes.get_children():
		$Hexes.remove_child(hex)
		hex.queue_free()
	compute()

func rotate_map() -> void:
	#texture = load(MAPH if is_instance_valid(board) and board.v else MAPV)
	configure()
	reset()

func set_mode(l : bool, m : bool, i : bool) -> void:
	show_los = l
	show_move = m
	show_influence = i
	compute()

func configure() -> void:
	var v : bool = (is_instance_valid(board) and board.v)
	var v0 : Vector2 = Vector2(50, 100)
	if centered:
		var ts :  Vector2 = Vector2(100, 100)
		#var ts : Vector2 = texture.get_size()
		if v:
			v0.x -= ts.y / 2
			v0.y -= ts.x / 2
		else:
			v0 -= ts / 2
	#if v:
		#hex_rotation = 30
		#board = HexMap.new(10, 4, 100, v0, false, get_tile)
	#else:
	hex_rotation = 0
	board = HexMap.new(40, 15, 100, v0, true, get_tile)
	var all_tiles = board.get_all_tiles()
	for vec in all_tiles:
		color_hexes[vec] = Sprite2D.new()
		color_hexes[vec].texture = load("res://assets/black.png")
		color_hexes[vec].position = board.center_of(vec)
		add_child(color_hexes[vec])


func texture_size() -> Vector2:
	return Vector2(100, 100)
	#return texture.get_size()

func center() -> Vector2:
	return Vector2(0, 0) if centered else Vector2(100, 100) / 2 
	#return Vector2(0, 0) if centered else texture.get_size() / 2

func on_mouse_move() -> void:
	if drag != null:
		drag.position = get_local_mouse_position()

#func on_click(pressed : bool) -> bool:
	#var pos : Vector2 = get_local_mouse_position()
	#var coords : Vector2 = board.to_map(pos)
	#if pressed:
		#notify(pos, coords)
		#prev = coords
		#if board.to_map($Tank.position) == coords:
			#drag = $Tank
		#elif board.to_map($Target.position) == coords:
			#drag = $Target
		#else:
			#return true
	#else:
		#if drag:
			#if board.is_on_map(coords):
				#drag.position = board.center_of(coords)
				#if drag == $Tank: p0 = coords
				#else: p1 = coords
				#notify(pos, coords)
				#compute()
			#else:
				#drag.position = board.center_of(prev)
			#drag = null
		#else:
			#if coords == prev and board.is_on_map(coords):
				#change_tile(coords, pos)
	#return false

func change_tile(coords : Vector2, pos : Vector2) -> void:
	var hex : Hex = board.get_tile(coords)
	hex.change()
	notify(pos, coords)
	compute()

func get_tile(coords : Vector2, k : int) -> Tile:
	if hexes.has(k): return hexes[k]
	var hex : Hex = Hex.new()
	hex.roads = get_road(k)
	hex.rotation_degrees = hex_rotation
	hex.configure(board.center_of(coords), coords, [RED, GREEN, BLACK, CITY, TREE, MOUNT, BLOCK, MOVE, SHORT])
	hexes[k] = hex
	$Hexes.add_child(hex)
	return hex

func get_road(k : int) -> int:
	if not board.v: return 0
	var v : int = 0
	#v += (HexMap.Orientation.E if k in [19,20,21,23,24,42,43,44,45,46,47] else 0)
	#v += (HexMap.Orientation.W if k in [19,20,21,22,24,25,43,44,45,46,47] else 0)
	#v += (HexMap.Orientation.SE if k in [22,32,42,52,62] else 0)
	#v += (HexMap.Orientation.NW if k in [32,42,52,62] else 0)
	#v += (HexMap.Orientation.NE if k in [7,16,25,32] else 0)
	#v += (HexMap.Orientation.SW if k in [7,16,23] else 0)
	return v

func notify(pos : Vector2, coords : Vector2) -> void:
	emit_signal("hex_touched", pos, board.get_tile(coords), (board.key(coords) if board.is_on_map(coords) else -1))

func compute() -> void:
	#$Los.visible = false
	for hex in los: hex.show_los(false)
	if show_los:
		$Los.visible = true
		var ct : Vector2 = board.line_of_sight(p0, p1, los)
		$Los.setup($Tank.position, $Target.position, ct)
		for hex in los: hex.show_los(true)
	for hex in move: hex.show_move(false)
	for hex in short: hex.show_short(false)
	if show_move:
		# warning-ignore:return_value_discarded
		#board.possible_moves(unit, board.get_tile(p0), move)
		# warning-ignore:return_value_discarded
		#board.shortest_path(unit, board.get_tile(p0), board.get_tile(p1), short)
		for hex in move: hex.show_move(true)
		for i in range(1, short.size() -1): short[i].show_short(true)
	for hex in influence: hex.show_influence(false)
	if show_influence:
		# warning-ignore:return_value_discarded
		#board.range_of_influence(unit, board.get_tile(p0), 0, influence)
		for hex in influence: hex.show_influence(true)


func _on_timer_timeout() -> void:
	for city_position in player_cities:
		print(city_position)
		spawn_unit(city_position)
	print("_on_timer_timeout")
	conquer_territory()
		
