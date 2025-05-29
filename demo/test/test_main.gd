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


func test_on_button_0_pressed():
	scene._on_button_0_pressed()


func test_on_button_1_pressed():
	scene._on_button_1_pressed()


func test_on_button_2_pressed():
	scene._on_button_2_pressed()


func test_on_button_3_pressed():
	scene._on_button_3_pressed()
