extends Node2D
const COUNT_UNITS = 40
const SP_SIZE = 64
const UNIT_DISTANCE = 10
const PSEVDOFORM_UNIT_SIZE = Vector2(20, 20)
const PSEVDOFORM_COLOR = Color(0,1,0)

var units = []
var start_pos = Vector2()
var end_pos
var d 
var psevdoform
var type_form = 'phalanx'
onready var panel = get_node("CanvasLayer/Panel")

func square(units, m, n):
	var co = []
	var uf = []
	for x in range(0, abs(m)): 
		var tmp = []
		for y in range(0, abs(n)):
			if m < 0:
				tmp.append(Vector2((UNIT_DISTANCE + SP_SIZE) * -x, (UNIT_DISTANCE + SP_SIZE) * y))
			else:
				tmp.append(Vector2((UNIT_DISTANCE + SP_SIZE) * x, (UNIT_DISTANCE + SP_SIZE) * y))
			uf.append(Vector2(x,y))
		co.append(tmp)
	return [co, uf]
	
##############################################3		
		
func fill_box(units):
	var k = sqrt(units.size())
	if  (k - floor(k)) != 0:
		k = int(k) + 1
	else:	
		k = int(k)
	return square(units, k, k)

func phalanx(units, k = null):
	var n
	if k == null:
		n = 3
		var t = int(units.size() / n)
		k = units.size() % n
		if  k != 0:
			k = int(t + 1)
		else:
			k = int(t)
	else:
		n = abs(units.size() / k)
		if units.size() % k != 0:
			n = int(n) + 1
	return square(units, k, n)
	
func wedge(units):
	var i = 0
	var co = []  
	for unit in units:
		for k in range(i + 1):
			var f = Vector2(((-0.5 * i) + k) * (UNIT_DISTANCE + SP_SIZE), i * (UNIT_DISTANCE + SP_SIZE)) 
			co.append(f)
		i += 1
	return [co,0]
		
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
				co.append(Vector2((UNIT_DISTANCE + SP_SIZE) * x, (UNIT_DISTANCE + SP_SIZE) * y))
	return [co, 0]
	
##############################################
	
func PlaceUnits(units, form = 'phalanx', result=null):
	if result == null:
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
	var angle = null
	for unit in units:
		var matrix_pos
		if form in ['phalanx', 'box']:
			matrix_pos = co[uf[pos].x][uf[pos].y]  
		else:
			matrix_pos = co[pos]
			
		if angle == null:
			if type_form == 'phalanx':
				angle = 0
			else:
				angle = unit.get_pos().angle_to_point(get_global_mouse_pos()) 			
		unit.set_pos(start_pos + (matrix_pos).rotated(angle)) 
		pos += 1

func gen_units(n, tex):
	var units = []
	for i in range(n):
		var sp = Sprite.new()
		sp.set_name('Unit' + str(i + 1))
		sp.set_texture(tex)
		add_child(sp)
		units.append(sp)
	return units

func psevdoform_controller():
	if panel.get_pos().x + panel.get_size().x < get_viewport().get_mouse_pos().x:
		if Input.is_action_just_pressed('target'):
			start_pos = get_global_mouse_pos()
		if Input.is_action_pressed('target'):
			end_pos = get_global_mouse_pos()
			if type_form == 'phalanx':
				d = end_pos.x - start_pos.x
				var k = int( d / (SP_SIZE + UNIT_DISTANCE) )
				if k != 0:
					psevdoform = phalanx(units, k)
					update()
			else:
				if type_form == 'wedge':
					psevdoform = wedge(units)
					update()
				if type_form == 'box':
					psevdoform = fill_box(units)
					update()
				if type_form == 'carre':
					psevdoform = carre(units)
					update()
	
		if Input.is_action_just_released('target'):
			PlaceUnits(units, type_form, psevdoform)
			d = null
			psevdoform = null
			update()
			
	if panel.get_pos().x + panel.get_size().x >= get_viewport().get_mouse_pos().x:
		d = null
		psevdoform = null
		update()

func psevdoform_draw():
	var co = []
	var uf = []
	if psevdoform != null:
		var co = psevdoform[0]
		var uf = psevdoform[1]
		var pos = 0
		var angle = null
		for unit in units:
			var matrix_pos
			if type_form in ['phalanx', 'box']:
				matrix_pos = co[uf[pos].x][uf[pos].y]  
			else:
				matrix_pos = co[pos] 
			if angle == null:
				if type_form == 'phalanx':
					angle = 0
				else:
					angle = unit.get_pos().angle_to_point(get_global_mouse_pos()) 
			draw_rect(Rect2(start_pos + (matrix_pos).rotated(angle), PSEVDOFORM_UNIT_SIZE), PSEVDOFORM_COLOR) 
			pos += 1

func _ready():
	units = gen_units(COUNT_UNITS, load('unit.png'))
	set_process(true)

func _process(delta):
	psevdoform_controller()
		
func _draw():
	psevdoform_draw()

func _on_phalanx_pressed():
	type_form = 'phalanx'
	PlaceUnits(units, type_form)

func _on_box_pressed():
	type_form = 'box'
	PlaceUnits(units, type_form)

func _on_wedge_pressed():
	type_form = 'wedge'
	PlaceUnits(units, type_form)

func _on_carre_pressed():
	type_form = 'carre'
	PlaceUnits(units, type_form)
	
	