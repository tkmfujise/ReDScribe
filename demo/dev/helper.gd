@tool
extends EditorScript
class_name Helper


func current() -> Node:
	return get_scene()


func hello():
	return 'Hello gdscript!'
