extends Node2D

@onready var path = $"../PathLine/SubViewport/Line2D"
@onready var path_marker = $"../PathMarker"
@onready var camera_3d = $"../Camera3D"
@onready var raycast = $"../RayCast3D"
@onready var map = $"../Map"
const MAX_RAY_LENGTH = 100
const ARMY_SPEED = 0.1
var path_points = []
var points_passed = 0

func _on_area_3d_input_event(_camera, _event, _position, _normal, _shape_idx):
	if (Input.is_action_just_pressed("left_click") && path_points.size() == 0):
		Input.action_release("left_click")
		path_marker.visible = true
		path_points.append(position)
		path.add_point(_transform_world_to_map(path_points[0]))
		await _draw_path()
		
		points_passed = 0
		_move_army()

func _draw_path():
	while (!Input.is_action_pressed("left_click")):
		path_marker.position = _get_mouse_point_on_map()
		await get_tree().process_frame
		if (Input.is_action_just_pressed("cancel")):
			path_marker.visible = false
			return
	path_points.append(path_marker.position)
	path.add_point(_transform_world_to_map(path_marker.position))
	if (Input.is_action_pressed("shift")):
		Input.action_release("left_click")
		await _draw_path()
	path_marker.visible = false

func _get_mouse_point_on_map():
	var mousePos = get_viewport().get_mouse_position()
	raycast.position = camera_3d.position
	raycast.target_position = camera_3d.project_ray_normal(mousePos) * MAX_RAY_LENGTH
	raycast.force_raycast_update()
	return raycast.get_collision_point()

func _transform_world_to_map(point):
	point = Vector2(point.x + map.mesh.size.x / 2.0, point.z + map.mesh.size.y / 2.0) * 100.0
	return point

func _move_army():
	for i in range(1, path_points.size()):
		var reached_this_point = false
		while (!reached_this_point):
			var direction = (path_points[i] - position).normalized() * ARMY_SPEED
			var is_overshoot_x = sign(path_points[i].x - position.x) != sign(path_points[i].x - (position.x + direction.x))
			var is_overshoot_y = sign(path_points[i].y - position.y) != sign(path_points[i].y - (position.y + direction.y))
			if (is_overshoot_x || is_overshoot_y):
				position = path_points[i]
				reached_this_point = true
				break
			else:
				position += direction
				print(direction)
				look_at(Vector3(direction.x, position.y, direction.z))
			_update_line_while_moving(i - 1)
			await get_tree().process_frame
	path_points = []
	path.clear_points()

func _update_line_while_moving(n):
	n -= points_passed
	path.set_point_position(n, _transform_world_to_map(position))
	if ((n <= path.get_point_count() - 1) && (path.get_point_position(n) - path.get_point_position(n + 1)).length() < ARMY_SPEED * 100):
		path.remove_point(n)
		points_passed += 1
