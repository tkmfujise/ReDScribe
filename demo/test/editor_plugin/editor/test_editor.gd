extends GutTest

var Editor = preload("res://addons/redscribe/src/editor/editor.tscn")
var scene = null


func before_each():
	scene = Editor.instantiate()
	add_child(scene)


func test_ready():
	assert_not_null(scene)


func test_toggle_comment():
	scene.text = """
		# do_something do
		  bar # test
		end
	"""
	scene.set_caret_line(1)
	scene.toggle_comment()
	assert_eq(scene.text, """
		do_something do
		  bar # test
		end
	""")


func test_toggle_comment_with_selection():
	scene.text = """
		do_something do
		  bar # test
		end
	"""
	scene.select(1, 0, 3, 0)
	scene.toggle_comment()
	assert_eq(scene.text, """
		# do_something do
		  # bar # test
		# end
	""")
