extends GutTest

var EditorArea = preload("res://addons/redscribe/src/editor/editor_area.tscn")
var scene = null


func before_each():
	scene = EditorArea.instantiate()
	add_child(scene)


func test_ready():
	assert_not_null(scene)
