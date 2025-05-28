extends GutTest

var Dialog = preload("res://addons/redscribe/src/file_dialog/file_dialog.tscn")
var scene = null


func before_each():
	scene = Dialog.instantiate()
	add_child(scene)


func test_ready():
	assert_not_null(scene)
