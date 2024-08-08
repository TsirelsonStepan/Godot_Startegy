extends HBoxContainer

@onready var paths = $"../../../MapPlane/PlaneViewport/Paths"
@onready var armies = $"../../../MapPlane/PlaneViewport/Armies"

@onready var buttons = [$MovementButton, $RotationButton, $FormationButton]

var current_state = "Movement"

func _ready():
	buttons[0].disabled = true

func _on_move_button_toggled(toggled_on):
	if (toggled_on):
		current_state = "Movement"
		_button_toggle(1, 2, 0)

func _on_rotate_button_toggled(toggled_on):
	if (toggled_on):
		current_state = "Rotation"
		_button_toggle(0, 2, 1)

func _on_formation_button_toggled(toggled_on):
	if (toggled_on):
		current_state = "Formation"
		_button_toggle(1, 0, 2)

func _button_toggle(index_1, index_2, index_3):
	buttons[index_1].button_pressed = false
	buttons[index_1].disabled = false
	buttons[index_2].button_pressed = false
	buttons[index_2].disabled = false
	buttons[index_3].disabled = true

func _on_popup_menu_index_pressed(index):
	var formation = %Formations.formation_shapes[%Paths.current_army_to_change_formation.state].keys()[index]
	%Paths.current_army_to_change_formation.formation = formation
	%Paths.current_army_to_change_formation._form_shape()
