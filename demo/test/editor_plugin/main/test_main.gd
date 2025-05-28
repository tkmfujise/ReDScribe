extends GutTest

var Main = preload("res://addons/redscribe/src/main/main.tscn")
var scene = null


func before_each():
	scene = Main.instantiate()
	add_child(scene)


func test_ready():
	assert_not_null(scene)
