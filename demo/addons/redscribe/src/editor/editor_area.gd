@tool
extends VBoxContainer

const PLACEHOLDER_FILENAME = 'Untitled'
var current_file : String : set = set_current_file
var file_dirty : bool = false : set = set_file_dirty


func _ready() -> void:
	update_labels()


func grab_focus() -> void:
	%Editor.grab_focus()


func new_file() -> void:
	current_file = ''
	%Editor.text = ''
	file_dirty = false


func load_file(path: String) -> void:
	current_file = path
	var f = FileAccess.open(path, FileAccess.READ)
	%Editor.text = f.get_as_text()
	f.close()
	file_dirty = false


func save_file() -> void:
	if current_file: save_current_file()
	else: %SaveFileDialog.show()


func save_current_file() -> void:
	if not current_file: return
	var f = FileAccess.open(current_file, FileAccess.WRITE)
	f.store_string(%Editor.text)
	f.close()
	file_dirty = false
	EditorInterface.get_resource_filesystem().scan()


func set_current_file(path: String) -> void:
	current_file = path
	update_labels()


func set_file_dirty(val: bool) -> void:
	file_dirty = val
	update_labels()


func update_labels() -> void:
	%FilePath.text = get_filename()
	if file_dirty: %FilePath.text += ' *'


func get_filename() -> String:
	if current_file:
		return current_file
	else:
		return PLACEHOLDER_FILENAME


func _on_editor_text_changed() -> void:
	if not file_dirty: file_dirty = true


func _on_save_file_dialog_file_selected(path: String) -> void:
	current_file = path
	save_current_file()
