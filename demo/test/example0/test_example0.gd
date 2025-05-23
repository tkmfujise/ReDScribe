extends GutTest

var Example0 = preload("res://src/example0_basic/example0.tscn")
var scene = null


func before_each():
	scene = Example0.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)
