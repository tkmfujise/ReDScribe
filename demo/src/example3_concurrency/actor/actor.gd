@tool
extends Node2D

@export var label : String : set = set_label


func update(dict: Dictionary) -> void:
	if dict['position']:
		var dx = dict['position'] - position.x
		position.x += dx
		set_speech(dx)


func set_label(_label: String) -> void:
	label = _label
	if not is_node_ready(): await ready
	%Label.text = _label


func set_speech(dx: int) -> void:
	if dx:
		%Speed.text = '+%s' % dx
		%Speech.show()
	else:
		%Speech.hide()
