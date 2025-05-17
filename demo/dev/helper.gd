@tool
extends EditorScript
class_name Helper


func current() -> Node:
	return get_scene()


func main() -> Node:
	return EditorInterface.get_editor_main_screen().get_children() \
		.filter(func(c): return c.name == 'ReDScribeMain')[0]


func editor_area() -> Node:
	return main().editor_area


func editor() -> Node:
	return main().editor_area.find_child('Editor')


func repl() -> Node:
	return main().repl
