extends BaseResource
#class_name Chapter

const Stage = preload("res://src/example2_resource_generator/resources/stage.gd")

@export var name : String
@export var number : int
@export var music : String
@export var image : Image
@export var stages : Array[Stage]


func assign(key: StringName, value: Variant) -> void:
	match key:
		'stages':
			for v in value:
				stages.push_back(build(Stage, v))
		_: super(key, value)
