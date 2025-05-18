@tool
extends VBoxContainer

@export var filemenu_shortcuts : Array[Shortcut]
@export var EditorArea : PackedScene
@export var REPL : PackedScene
enum FileMenu { NEW, OPEN, SAVE }
enum Tab { EDITOR_AREA, REPL }

var editor_area : Control
var repl : Control


func _ready() -> void:
	_bind_filemenu_shortcuts()
	%VersionLabel.text = version()
	editor_area = EditorArea.instantiate()
	repl = REPL.instantiate()
	repl.hide()
	%BodyContainer.add_child(editor_area)
	%BodyContainer.add_child(repl)


func load_file(path: String) -> void:
	editor_area.load_file(path)
	show_editor_area()


func show_editor_area() -> void:
	%TabBar.select_previous_available()


func show_repl() -> void:
	%TabBar.select_next_available()


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
		FileMenu.NEW:  editor_area.new_file()
		FileMenu.OPEN:
			EditorInterface.popup_quick_open(
				_on_quick_open_selected,
				[&"ReDScribeEntry"])
		FileMenu.SAVE: editor_area.save_file()


func _on_quick_open_selected(path: String) -> void:
	if path: EditorInterface.edit_resource(load(path))


func _on_tab_bar_tab_changed(tab: int) -> void:
	match tab:
		Tab.EDITOR_AREA:
			editor_area.show()
			repl.hide()
			editor_area.call_deferred('grab_focus')
		Tab.REPL:
			editor_area.hide()
			repl.show()
			repl.call_deferred('grab_focus')


func _input(event: InputEvent) -> void:
	if not visible: return
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed:
			match k.keycode:
				KEY_BRACKETLEFT:  # Ctrl+[
					if k.ctrl_pressed: show_editor_area()
				KEY_BRACKETRIGHT: # Ctrl+]
					if k.ctrl_pressed: show_repl()
