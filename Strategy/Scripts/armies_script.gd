extends Node2D

var speed_of_movement = 1.0
var speed_of_rotation = 1.0

var stop_movement = []
var stop_rotation = []

func _move_army(army, points):
	army.state = "Movement"
	for i in range(1, points.size()):
		if (army.name in stop_movement): break
		var reached_this_point = false
		while (!reached_this_point):
			if (army.name in stop_movement): break
			var direction = (points[i] - army.position).normalized() * speed_of_movement * %TimeControl.time_speed
			var is_overshoot_x = sign(points[i].x - army.position.x) != sign(points[i].x - (army.position.x + direction.x))
			var is_overshoot_y = sign(points[i].y - army.position.y) != sign(points[i].y - (army.position.y + direction.y))
			if (is_overshoot_x || is_overshoot_y):
				army.position = points[i]
				$"../Paths"._update_line_on_move(army, i - 1, true)
				reached_this_point = true
				break
			else:
				army.position += direction
				$"../Paths"._update_line_on_move(army, i - 1, false)
			await get_tree().process_frame
	$"../Paths".armies_paths[str(army.name)].queue_free()
	$"../Paths".armies_paths.erase(str(army.name))
	stop_movement.erase(army.name)
	army.state = "Idle"

var rotation_progress = 0.0
func _rotate_army(army, direction):
	army.state = "Rotation"
	while (rotation_progress < 1.0):
		if (army.name in stop_rotation): break
		var goal_rotation = atan2(direction.y, direction.x) + PI/2.0
		army.global_rotation = lerp_angle(army.global_rotation, goal_rotation, rotation_progress)
		rotation_progress += speed_of_rotation / 50.0 * %TimeControl.time_speed
		await get_tree().process_frame
	rotation_progress = 0.0
	$"../Paths".armies_directions[str(army.name)].queue_free()
	$"../Paths".armies_directions.erase(str(army.name))
	stop_rotation.erase(army.name)
	army.state = "Idle"
