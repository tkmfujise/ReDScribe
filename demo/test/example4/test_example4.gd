extends GutTest

var Example4 = preload("res://src/example4_coroutine/example4.tscn")
var scene = null


func before_each():
	scene = Example4.instantiate()
	add_child(scene)


func after_each():
	if scene: scene.free()


func test_ready():
	assert_not_null(scene)


func test__value_for_rb():
	assert_eq(scene._value_for_rb(&'key'), ':key')
	assert_eq(scene._value_for_rb('str'), '"str"')
	assert_eq(scene._value_for_rb(true), true)
	assert_eq(scene._value_for_rb(false), false)
	assert_eq(scene._value_for_rb(null), 'nil')
