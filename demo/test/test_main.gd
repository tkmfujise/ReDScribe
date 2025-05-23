extends GutTest

var Main = preload("res://main.tscn")
var scene = null


func before_each():
	scene = Main.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)
