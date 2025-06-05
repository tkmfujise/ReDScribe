extends ReDScribe


const Chapter = preload("res://src/example2_resource_generator/resources/chapter.gd")
const RESOURCE_DIST = "res://src/example2_resource_generator/data/chapter.tres"


func _init() -> void:
	channel.connect(_handle)


func perform_file(path: String) -> void:
	perform(FileAccess.open(path, FileAccess.READ).get_as_text())


func load_resource() -> Resource:
	return ResourceLoader.load(RESOURCE_DIST)


func read_file() -> String:
	return FileAccess.open(RESOURCE_DIST, FileAccess.READ).get_as_text()


func build(klass, attributes: Dictionary) -> Resource:
	var res = klass.new()
	res.update(attributes)
	return res


func _handle(key: StringName, payload: Variant) -> void:
	match key:
		&'chapter':
			var chapter = build(Chapter, payload)
			ResourceSaver.save(chapter, RESOURCE_DIST)
		_: print_debug('[ %s ] signal emitted: %s' % [key, payload])
