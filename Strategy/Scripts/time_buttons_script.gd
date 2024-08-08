extends HBoxContainer

@onready var speeds = [$Speed0, $Speed1, $Speed2]

func _ready():
	%TimeControl.time_speed = 0.0
	speeds[0].disabled = true

func _on_speed_0_pressed():
	_change_speed(0.0, 1, 2, 0)

func _on_speed_1_pressed():
	_change_speed(1.0, 0, 2, 1)

func _on_speed_2_pressed():
	_change_speed(2.0, 0, 1, 2)

func _change_speed(new_speed, index_1, index_2, index_3):
	%TimeControl.time_speed = new_speed
	speeds[index_1].button_pressed = false
	speeds[index_1].disabled = false
	speeds[index_2].button_pressed = false
	speeds[index_2].disabled = false
	speeds[index_3].disabled = true
