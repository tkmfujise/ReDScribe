extends Control

const Generator = preload("res://src/example2_resource_generator/generator.gd")
@onready var generator := Generator.new()


func _ready() -> void:
	%DSL.text = FileAccess.open("res://src/example2_resource_generator/resource.rb", FileAccess.READ).get_as_text()


func _on_button_pressed() -> void:
	generator.perform_file("res://src/example2_resource_generator/resource.rb")
	#var res = generator.load_resource()
	%Generated.text = generator.read_file()
