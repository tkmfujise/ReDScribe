extends GutTest

var Example1 = preload("res://src/example1_live_coding/example1.tscn")
var scene = null


func before_each():
	scene = Example1.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)
