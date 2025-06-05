extends Resource
class_name BaseResource


static func build(klass, attributes: Dictionary) -> Resource:
	var res = klass.new()
	res.update(attributes)
	return res


func assign(key: StringName, value: Variant) -> void:
	set(key, value)


func update(attributes: Dictionary) -> Resource:
	for prop in get_property_list():
		match prop.class_name:
			&'Image':
				if attributes[prop.name].has('path'):
					var image = Image.new()
					image.load(attributes[prop.name].path)
					set(prop.name, image)
			_: if attributes.has(prop.name):
				assign(prop.name, attributes[prop.name])
	return self
