@tool
extends EditorPlugin

const Main = preload("res://addons/redscribe/src/main/main.tscn")
const ContextMenuFileSystem = preload("res://addons/redscribe/ext/context_menu/file_system.gd")

var main : Control
var context_menu_filesystem : ContextMenuFileSystem

func _enter_tree() -> void:
	main = Main.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main)
	_add_actions()
	_make_visible(false)


func _exit_tree() -> void:
	if main: main.queue_free()
	_remove_actions()


func _has_main_screen() -> bool:
	return true


func _handles(object: Object) -> bool:
	return object is ReDScribeEntry


func _edit(object: Object) -> void:
	if object is ReDScribeEntry:
		main.load_file(object.resource_path)


func _make_visible(visible: bool) -> void:
	if main: main.visible = visible


func _get_plugin_name() -> String:
	return "ReDScribe"


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/redscribe/assets/icons/editor_icon.svg")


func _add_actions() -> void:
	context_menu_filesystem = ContextMenuFileSystem.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, context_menu_filesystem)


func _remove_actions() -> void:
	remove_context_menu_plugin(context_menu_filesystem)


# https://github.com/godotengine/godot-proposals/issues/2024
func _add_shortcuts() -> void:
	pass
