@tool
extends ResourceFormatLoader
class_name ReDScribeEntryLoader

var extension = 'rb'


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray([extension])


func _get_resource_type(path: String) -> String:
	var ext = path.get_extension().to_lower()
	if ext == extension:
		return "ReDScribeEntry"
	return ""


func _handles_type(typename: StringName) -> bool:
	return typename == &"ReDScribeEntry"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var res = ReDScribeEntry.new()
	return res
