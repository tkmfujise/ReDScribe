@tool
extends Node2D

@export var label : String :
	set(s): label = s; %Label.text = s


func update(dict: Dictionary) -> void:
	if dict['position']:
		var dx = dict['position'] - position.x
		position.x += dx
		set_speech(dx)


func set_speech(dx: int) -> void:
	if dx:
		%Speed.text = '+%s' % dx
		%Speech.show()
	else:
		%Speech.hide()
