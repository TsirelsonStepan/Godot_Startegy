extends Node2D

@onready var raycast = $"../../../RayCast3D"
@onready var camera = $"../../../Camera3D"
@onready var map = $"../Map"
@onready var viewport_raycast = $"../RayCast2D"

@onready var action_buttons = $"../../../SubViewportContainer/SubViewport/HBoxContainer"
@onready var popup_menu = $"../../../SubViewportContainer/SubViewport/PopupMenu"

const MAX_RAY_LENGTH = 100
var armies_paths = {}
var armies_directions = {}
var current_path_points = {}
var arrow_length:float = 50.0
var current_army_to_change_formation
var click_block = false

func _process(_delta):
	if (Input.is_action_just_pressed("left_click") && !click_block):
		Input.action_release("left_click")
		var result = _get_collider_on_mouse()
		if (result != null && "Army" in result.get_parent().name):
			result = result.get_parent()
			_on_army_collider_triggered(result)

func _on_army_collider_triggered(army):
	click_block = true
	if armies_paths.has(str(army.name)) && action_buttons.current_state != "Formation":
		$"../Armies".stop_movement.append(army.name)
	if armies_directions.has(str(army.name)) && action_buttons.current_state != "Formation":
		$"../Armies".stop_rotation.append(army.name)
	await get_tree().process_frame
	
	if (action_buttons.current_state == "Movement"):
		armies_paths[army.name] = Line2D.new()
		add_child(armies_paths[army.name])
		armies_paths[army.name].name = army.name
		armies_paths[army.name].add_point(army.position)
		armies_paths[army.name].add_point(_get_mouse_point_on_map())
		var result = await _draw_path(army.name)
		if result:
			current_path_points[army.name] = 0
			$"../Armies"._move_army(army, armies_paths[army.name].points)
	elif (action_buttons.current_state == "Rotation"):
		armies_directions[army.name] = Line2D.new()
		add_child(armies_directions[army.name])
		armies_directions[army.name].name = army.name
		armies_directions[army.name].add_point(army.position)
		armies_directions[army.name].add_point(army.position + _get_mouse_point_on_map().normalized() * arrow_length)
		var result = await _draw_direction(army.name)
		if result:
			var direction = armies_directions[army.name].points[1] - armies_directions[army.name].points[0]
			$"../Armies"._rotate_army(army, direction.normalized() * arrow_length)
	elif (action_buttons.current_state == "Formation"):
		popup_menu.position = $"../../../SubViewportContainer".get_global_mouse_position()
		var formations = $"../Armies/Formations".formation_shapes[army.state]
		popup_menu.clear()
		for i in formations:
			popup_menu.add_item(i)
		popup_menu.show()
		current_army_to_change_formation = army
	click_block = false

func _draw_path(army_name):
	var path_length = armies_paths[army_name].points.size()
	while (!Input.is_action_pressed("left_click")):
		armies_paths[army_name].set_point_position(path_length - 1, _get_mouse_point_on_map())
		await get_tree().process_frame
		if (Input.is_action_just_pressed("cancel")):
			armies_paths[army_name].remove_point(path_length - 1)
			return false
	if (_get_collider_on_mouse() != null):
		Input.action_release("left_click")
		await _draw_path(army_name)
	if (Input.is_action_pressed("shift")):
		Input.action_release("left_click")
		armies_paths[army_name].add_point(_get_mouse_point_on_map())
		await _draw_path(army_name)
	return true

func _draw_direction(army_name):
	while (!Input.is_action_pressed("left_click")):
		var point = (_get_mouse_point_on_map() - armies_directions[army_name].points[0]).normalized() * arrow_length
		point += armies_directions[army_name].points[0]
		armies_directions[army_name].set_point_position(1, point)
		await get_tree().process_frame
		if (Input.is_action_just_pressed("cancel")):
			armies_directions[army_name].queue_free()
			armies_directions.erase(army_name)
			return false
	return true

func _get_mouse_point_on_map():
	var mousePos = camera.get_viewport().get_mouse_position()
	raycast.position = camera.position
	raycast.target_position = camera.project_ray_normal(mousePos) * MAX_RAY_LENGTH
	raycast.force_raycast_update()
	var result = raycast.get_collision_point()
	return Vector2((result.x * 100.0 + map.position.x), (result.z * 100.0 + map.position.y))

func _update_line_on_move(army, n, is_overshoot):
	n -= current_path_points[str(army.name)]
	armies_paths[army.name].set_point_position(n, army.position)
	if (is_overshoot):
		armies_paths[army.name].remove_point(n)
		current_path_points[str(army.name)] += 1

func _get_collider_on_mouse():
	viewport_raycast.position = _get_mouse_point_on_map()
	viewport_raycast.force_raycast_update()
	var result = viewport_raycast.get_collider()
	return result
