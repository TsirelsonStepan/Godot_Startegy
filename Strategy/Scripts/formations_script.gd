extends Node

var formation_shapes = {
	"Attack" : {},
	"Defence" : {},
	"Movement" : {},
	"Rotation" : {},
	"Idle" : {}
}

func _ready():
	for i in get_children():
		for j in i.get_children():
			formation_shapes[i.name][j.name] = j.polygon

	#for i in $"../".get_children():
		#if ("Army" in i.name):
			#i._form_shape()
