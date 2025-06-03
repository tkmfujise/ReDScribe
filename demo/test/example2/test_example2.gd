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


func test___on_button_pressed():
	var before_text = scene.get_node('%Generated').text
	scene._on_button_pressed()
	assert_ne(scene.get_node('%Generated').text, before_text)
