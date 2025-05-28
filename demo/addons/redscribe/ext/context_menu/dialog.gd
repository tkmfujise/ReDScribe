@tool
extends Window

const SCRIPT_TEMPLATES_DIR = 'res://addons/redscribe/script_templates/'
const TEMPLATE = {
	'rb': {
		'idx': 0,
		'placeholder': 'boot.rb',
		'script': 'boot.rb'
	},
	'gd': {
		'idx': 1,
		'placeholder': 'new_resource.gd',
		'script': 'resource.gd'
	},
}
var placeholder : String
var current_key : String
var path : String


func setup(_path: String, template_key: String) -> void:
	path = _path
	select_template(template_key)


func _ready() -> void:
	grab_filename()


func select_template(key: String) -> void:
	current_key  = key
	var template = TEMPLATE[key]
	placeholder  = template['placeholder']
	%Template.select(template['idx'])
	%Path.text = path + placeholder
	%Description.text = script_template(key)


func grab_filename() -> void:
	var path_length = %Path.text.length() - placeholder.length()
	%Path.grab_focus()
	%Path.set_caret_column(path_length)
	%Path.select(path_length, path_length + placeholder_name_length())


func placeholder_name_length() -> int:
	return placeholder.length() - placeholder.get_extension().length() - 1


func script_template(key: String) -> String:
	var filename = TEMPLATE[key]['script']
	var path = SCRIPT_TEMPLATES_DIR + filename + '.template'
	var f = FileAccess.open(path, FileAccess.READ)
	var script = f.get_as_text()
	f.close()
	return script


func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		hide()


func _on_template_item_selected(index: int) -> void:
	var idx = TEMPLATE.values().find_custom(
		func(v): return v['idx'] == index)
	select_template(TEMPLATE.keys()[idx])
	grab_filename()


func _on_confirmed() -> void:
	var f = FileAccess.open(%Path.text, FileAccess.WRITE)
	var content = script_template(current_key)
	f.store_string(content)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
	hide()


func _on_path_text_changed(new_text: String) -> void:
	var txt = new_text.get_basename().get_file().to_pascal_case()


func _on_path_text_submitted(_paths: String) -> void:
	_on_confirmed()


func _on_resource_name_text_submitted(new_text: String) -> void:
	_on_confirmed()
