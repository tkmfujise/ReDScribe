@tool
extends EditorScript
class_name Helper


func current() -> Node:
	return get_scene()


func main() -> Node:
	return EditorInterface.get_editor_main_screen().get_children() \
		.filter(func(c): return c.name == 'ReDScribeMain')[0]


func editor_area() -> Node:
	return main().find_child('EditorArea')


func editor() -> Node:
	return editor_area().find_child('Editor')


func repl() -> Node:
	var arr = main().find_child('BodyContainer').get_children() \
		.filter(func(c): return c.name == 'REPL')
	if arr: return arr[0]
	else: return null
