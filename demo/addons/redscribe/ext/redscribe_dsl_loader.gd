@tool
extends ResourceFormatLoader
class_name ReDScribeDSLLoader

const ReDScribeDSL = preload("./redscribe_dsl.gd")
var extension = 'rb'

# FIXME ERROR: Cannot get class 'ReDScribeDSL'.


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray([extension])


func _get_resource_type(path: String) -> String:
	var ext = path.get_extension().to_lower()
	if ext == extension:
		return "ReDScribeDSL"
	return ""


func _handles_type(typename: StringName) -> bool:
	return typename == "ReDScribeDSL"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var res  = ReDScribeDSL.new()
	EditorInterface.set_main_screen_editor("ReDScribe")
	var main = EditorInterface.get_editor_main_screen() \
		.get_children().filter(func(c):
			return c.name.begins_with('ReDScribeMain'))
	if main: main[0].load_file(path)
	return res
