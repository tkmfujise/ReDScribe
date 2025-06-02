@tool
extends Node2D

signal start
@export var label : String : set = set_label


func _ready() -> void:
	pass


func set_label(_label: String) -> void:
	label = _label
	if not is_node_ready(): await ready
	%Label.text = _label


func _on_button_pressed() -> void:
	start.emit()
