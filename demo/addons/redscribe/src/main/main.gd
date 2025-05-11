@tool
extends VBoxContainer

@export var filemenu_shortcuts : Array[Shortcut]
enum FileMenuShortcut { NEW, OPEN, SAVE }


func _ready() -> void:
	_bind_filemenu_shortcuts()


func load_file(path: String) -> void:
	%EditorArea.load_file(path)


func _bind_filemenu_shortcuts() -> void:
	var popup = %FileMenu.get_popup()
	popup.id_pressed.connect(_file_menu_selected)
	for i in filemenu_shortcuts.size():
		popup.set_item_shortcut(i, filemenu_shortcuts[i])


func _file_menu_selected(id: int) -> void:
	match id:
		FileMenuShortcut.NEW:  %EditorArea.new_file()
		FileMenuShortcut.OPEN: pass
		FileMenuShortcut.SAVE: %EditorArea.save_current_file()
