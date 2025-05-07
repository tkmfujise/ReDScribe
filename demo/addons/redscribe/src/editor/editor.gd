@tool
extends VBoxContainer

@export var shortcut : Shortcut
var current_file : String : set = set_current_file

enum Hotkey { SAVE }


func _ready() -> void:
	print_debug(shortcut.events)


func load_file(path: String) -> void:
	current_file = path
	var f = FileAccess.open(path, FileAccess.READ)
	%Editor.text = f.get_as_text()
	f.close()



func set_current_file(path: String) -> void:
	current_file   = path
	%FilePath.text = path
