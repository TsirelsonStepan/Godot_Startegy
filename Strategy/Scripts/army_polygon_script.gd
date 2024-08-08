extends Node2D

@onready var shape = $Polygon2D
@onready var collider = $"BodyCollider/CollisionPolygon2D"

@export var state = "Idle"
@export var formation:String
@export var size:int

const SPEED_OF_FORMATION = 10.0

func _update_area():
	var c_area = _calculate_polygon_area(shape.polygon)
	shape.scale = Vector2(size / c_area, size / c_area)
	$BodyCollider.scale = shape.scale
	$Polygon2D/Sprites.scale = Vector2(c_area / size, c_area / size)

func _form_shape():
	var target_points = %Formations.formation_shapes[state][formation]
	var quit = true
	while (quit):
		quit = false
		var current_points = Array(shape.polygon)
		for i in range(current_points.size()):
			if ((target_points[i] - current_points[i]).length() > 0.1):
				current_points[i] += (target_points[i] - current_points[i]).normalized() / 100.0 * SPEED_OF_FORMATION * %TimeControl.time_speed
				if ((target_points[i] - current_points[i]).length() > 0.1): quit = true
		shape.set_polygon(PackedVector2Array(current_points))
		collider.set_polygon(shape.polygon)
		_update_area()
		await get_tree().process_frame

func _calculate_polygon_area(polygon):
	var product1 = 0
	var product2 = 0
	for i in range(polygon.size() - 1):
		product1 += polygon[i].x * polygon[i + 1].y
		product2 += polygon[i + 1].x * polygon[i].y
	product1 -= product2
	return product1 / 2.0
