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
	for prop in res.get_property_list():
		match prop.class_name:
			&'Image':
				var image = Image.new()
				image.load(attributes[prop.name].path)
				res.set(prop.name, image)
			_: if attributes.has(prop.name):
				res.set(prop.name, attributes[prop.name])
	return res


func _handle(key: StringName, payload: Variant) -> void:
	match key:
		&'chapter':
			var chapter = build(Chapter, payload)
			ResourceSaver.save(chapter, RESOURCE_DIST)
			print_debug(chapter)
		_: print_debug('[ %s ] signal emitted: %s' % [key, payload])
