extends Control

@export var resource : SimpleDSL


func _ready() -> void:
	resource.dsl = "foo"
	resource.execute_dsl()
	print(resource.dsl_error)
