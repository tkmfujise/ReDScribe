extends GutTest

var REPL = preload("res://addons/redscribe/src/repl/repl.tscn")
var scene = null


func before_each():
	scene = REPL.instantiate()
	add_child(scene)


func test_ready():
	assert_not_null(scene)
