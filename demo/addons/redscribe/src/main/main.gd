@tool
extends VBoxContainer

@export var filemenu_shortcuts : Array[Shortcut]
@export var EditorArea : PackedScene
@export var REPL : PackedScene
enum FileMenuShortcut { NEW, OPEN, SAVE }


func _ready() -> void:
	_bind_filemenu_shortcuts()
	%VersionLabel.text = version()
	%BodyContainer.add_child(REPL.instantiate())


func load_file(path: String) -> void:
	%EditorArea.load_file(path)


func version() -> String:
	var config = ConfigFile.new()
	var err = config.load("res://addons/redscribe/plugin.cfg")
	if err == OK:
		return 'v' + config.get_value('plugin', 'version')
	else: return ''


func _bind_filemenu_shortcuts() -> void:
	var popup = %FileMenu.get_popup()
	popup.id_pressed.connect(_file_menu_selected)
	for i in filemenu_shortcuts.size():
		popup.set_item_shortcut(i, filemenu_shortcuts[i])


func _file_menu_selected(id: int) -> void:
	match id:
		FileMenuShortcut.NEW:  %EditorArea.new_file()
		FileMenuShortcut.OPEN:
			EditorInterface.popup_quick_open(
				_on_quick_open_selected,
				[&"ReDScribeEntry"])
		FileMenuShortcut.SAVE: %EditorArea.save_file()


func _on_quick_open_selected(path: String) -> void:
	if path: EditorInterface.edit_resource(load(path))
