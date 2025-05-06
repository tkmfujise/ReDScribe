@tool
extends EditorScript

var res := StageGenerator.new()


func _run() -> void:
	var scene = get_scene()
	res.perform('run')
	if res.exception: printerr(res.exception)
