extends Node2D
var distance = 70
onready var camera = get_node('Camera2D')
var units = []

func square(units, m, n):
	var co = []
	var uf = []
	for x in range(0, m): 
		var tmp = []
		for y in range(0, n):
			tmp.append(Vector2(distance * x, distance * y))
			uf.append(Vector2(x,y))
		co.append(tmp)
	return [co, uf]

func wedge(units):
	var i = 0
	var co = []  
	for unit in units:
		for k in range(i + 1):
			var f = Vector2(((-0.5 * i) + k) * distance, i * distance) 
			co.append(f)
		i += 1
	return [co,0]
		
func fill_box(units):
	var k = sqrt(units.size())
	if  (k - floor(k)) != 0:
		k = int(k) + 1
	else:	
		k = int(k)
	return square(units, k, k)

func phalanx(units):
	var t = int(units.size() / 3)
	var k = units.size() % 3
	if  k != 0:
		k = int(t + 1)
	else:
		k = int(t)
	return square(units, k, 3)

func carre(units):
	var co = []
	var uf = []
	var t = int(units.size() / 8)
	var k = units.size() % 8 
	if k != 0:
		k = int(t + 1)
	else:
		k = int(t)
	var x_max = k + 4
	var y_max = k + 2
	for x in range(0, x_max): 
		var tmp = [] 
		for y in range(0, y_max):
			if (not(x in [0, 1, x_max - 2, x_max - 1] and (y == 0 or y == y_max - 1)) 
			and not(x >= 2 and x <= x_max - 3 and y <= y_max - 3 and y >= 2)):
				co.append(Vector2(distance * x, distance * y))
	return [co, 0]
	
func PlaceUnits(units, form = 'phalanx'):
	var result
	if form == 'phalanx':
		result = phalanx(units)
	if form == 'box':
		result = fill_box(units)
	if form == 'wedge':
		result = wedge(units)
	if form == 'carre':
		result = carre(units)
		
	var co = result[0]
	var uf = result[1]
	var pos = 0

	for unit in units:
		var matrix_pos
		if form in ['phalanx', 'box']:
			matrix_pos = co[ uf[pos].x ][ uf[pos].y ]  
		else:
			matrix_pos = co[pos]
	#var global_pos = camera.get_global_mouse_pos() 
		unit.set_pos(Vector2(500,200) + matrix_pos) #+ global_pos) #mp.rotated(angle)
		pos += 1



func _ready():
	for child in get_children():
		if child.get_name().match('Unit*') == true:
			units.append(child)

func _on_phalanx_pressed():
	PlaceUnits(units,'phalanx')

func _on_box_pressed():
	PlaceUnits(units,'box')

func _on_wedge_pressed():
	PlaceUnits(units,'wedge')

func _on_carre_pressed():
	PlaceUnits(units,'carre')
