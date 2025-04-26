@tool
extends EditorPlugin

const Editor = preload("res://addons/redscribe/src/editor/editor.tscn")
var editor

func _enter_tree() -> void:
	editor = Editor.instantiate()
	EditorInterface.get_editor_main_screen().add_child(editor)
	_make_visible(false)


func _exit_tree() -> void:
	if editor: editor.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if editor: editor.visible = visible


func _get_plugin_name() -> String:
	return "ReDScribe"


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/redscribe/assets/icons/editor_icon.svg")
