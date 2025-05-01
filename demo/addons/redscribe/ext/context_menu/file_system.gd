extends EditorContextMenuPlugin

const rb_icon = preload("res://addons/redscribe/assets/icons/editor_icon_gray.svg")
const gd_icon = preload("res://addons/redscribe/assets/icons/editor_icon_outline.svg")
const Dialog = preload("res://addons/redscribe/ext/context_menu/dialog.tscn")


func _popup_menu(paths: PackedStringArray) -> void:
	if paths.size() == 1:
		add_context_menu_item("DSL/boot *.rb", create_rb_file, rb_icon)
		add_context_menu_item("ReDScribe *.gd", create_gd_file, gd_icon)


func create_gd_file(paths: PackedStringArray) -> void:
	if paths.size() != 1: return
	create_file(paths[0], 'gd')


func create_rb_file(paths: PackedStringArray) -> void:
	if paths.size() != 1: return
	create_file(paths[0], 'rb')


func create_file(path: String, template: String) -> void:
	var dialog = Dialog.instantiate()
	dialog.setup(path, template)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.show()
