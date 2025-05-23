extends GutTest

var Example2 = preload("res://src/example2_resource_generator/example2.tscn")
var scene = null


func before_each():
	scene = Example2.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)
