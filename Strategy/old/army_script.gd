extends Node2D

@onready var shape = $Polygon2D
@onready var collider = $Polygon2D/Area2D/CollisionPolygon2D
@onready var line = $ArmyPathLine
@onready var actions_popup = $ActionsPopup
@onready var formations_popup = $ActionsPopup/FormationsPopup

@export var speed_of_formation:float
@export var randomnes_of_formation:float
@export var current_formation:Resource

func _process(delta):
	_update_area()

func _update_area():
	var c_area = _calculate_polygon_area(shape.polygon)
	var area = current_formation.size
	scale = Vector2(area / c_area, area / c_area)

func _form_shape(form):
	var target_points = $"../Formations".formation_shapes[current_formation.type][current_formation.name]
	var quit = true
	while (quit):
		quit = false
		var current_points = Array(shape.polygon)
		for i in range(current_points.size()):
			if ((target_points[i] - current_points[i]).length() > 0.1):
				current_points[i] += (target_points[i] - current_points[i]).normalized() / 100.0 * speed_of_formation
				if ((target_points[i] - current_points[i]).length() > 1): quit = true
		
		shape.set_polygon(PackedVector2Array(current_points))
		collider.set_polygon(shape.polygon)
		
		await get_tree().process_frame

func _on_army_area_entered(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if (!_locked_in_action):
			actions_popup.position = event.position
			actions_popup.show()

var _locked_in_action = false
var current_action
const ACTIONS = ["Attack", "Defence", "Movement"]
func _on_actions_id_pressed(id):
	formations_popup.clear()
	current_action = id
	if (id >= 0 && id <= 2):
		for i in $"../Formations".formation_shapes[ACTIONS[id]]: formations_popup.add_item(i)
		formations_popup.position = actions_popup.position + Vector2i(133, 0)
		formations_popup.show()
	elif (id == 3):
		actions_popup.hide()
		_army_maneuver(false)

func _on_formations_id_pressed(id):
	actions_popup.hide()
	
	if (current_action == 2):
		_locked_in_action = true
		_army_maneuver(true)

func _army_maneuver(is_movement):
	await _draw_direction_line()
	
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		_locked_in_action = true
		var mouse_pointer = get_global_mouse_position()
		var rotation_goal = (fmod((mouse_pointer - position).angle() + PI/2, PI*2))
		if (abs(rotation_goal - shape.rotation) > PI): rotation_goal -= 2*PI
		
		_rotate_army(rotation_goal)
		if (is_movement): _move_army(mouse_pointer)

		_locked_in_action = false
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		line.visible = false
		actions_popup.show()

func _draw_direction_line():
	line.visible = true
	while (!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		line.set_point_position(0, Vector2(0, 0))
		line.set_point_position(1, (get_global_mouse_position() - position) / scale)
		await get_tree().process_frame
	line.visible = false

func _rotate_army(rotation_goal):
	while (abs(rotation_goal - shape.rotation) > 0.01):
		shape.rotation += (rotation_goal - shape.rotation) / 5.0
		await get_tree().process_frame
func _move_army(movement_goal):
	while ((position - movement_goal).length() > 1):
		position += (movement_goal - position).normalized()
		await get_tree().process_frame	

func _calculate_polygon_area(polygon):
	var product1 = 0
	var product2 = 0
	for i in range(polygon.size() - 1):
		product1 += polygon[i].x * polygon[i + 1].y
		product2 += polygon[i + 1].x * polygon[i].y
	product1 -= product2
	return product1 / 2.0
