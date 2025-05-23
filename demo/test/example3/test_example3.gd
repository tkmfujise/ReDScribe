extends GutTest

var Example3 = preload("res://src/example3_co-routine/example3.tscn")
var scene = null


func before_each():
	scene = Example3.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)
