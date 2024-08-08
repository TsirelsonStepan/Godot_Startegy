extends Node

var time_speed = 1.0
var previous_time

func _process(_delta):
	if (Input.is_action_just_pressed("time_stop") && time_speed > 0):
		previous_time = time_speed
		time_speed = 0.0
	elif (Input.is_action_just_pressed("time_stop")): time_speed = previous_time
