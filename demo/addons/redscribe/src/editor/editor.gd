@tool
extends VBoxContainer

var current_file : String : set = set_current_file


func load_file(path: String) -> void:
	current_file = path
	var f = FileAccess.open(path, FileAccess.READ)
	%Editor.text = f.get_as_text()
	f.close()



func set_current_file(path: String) -> void:
	current_file   = path
	%FilePath.text = path
