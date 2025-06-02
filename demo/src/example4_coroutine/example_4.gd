extends Control

@export var controller : ReDScribe


func _ready() -> void:
	controller.channel.connect(_response)
	setup_reply_choices()


func start(_name: String) -> void:
	controller.perform('start "%s"' % _name)


func resume(value: Variant = null) -> void:
	controller.perform('continue %s' % value)


func show_messge(speaker_name: String, body: String) -> void:
	hide_reply_choices()
	%Message.text = "( %s )\n%s" % [speaker_name, body]


func setup_reply_choices(dict: Dictionary = {}) -> void:
	hide_reply_choices()
	for key in dict: add_choice(dict[key], key)


func add_choice(label: String, value: Variant) -> void:
	var btn = %TemplateButton.duplicate()
	btn.show()
	btn.text = label
	btn.pressed.connect(resume.bind(_value_for_rb(value)))
	%Reply.add_child(btn)


func hide_reply_choices() -> void:
	for child in %Reply.get_children(): child.queue_free()


# = Value for Ruby
# 	&'key'   => ':key'
# 	'string' => '"string"'
# 	_	     => value
func _value_for_rb(value: Variant) -> Variant:
	match typeof(value):
		TYPE_STRING_NAME: return ':%s' % value
		TYPE_STRING:      return '"%s"' % value
		TYPE_NIL:         return 'nil'
		_: return value


func _response(key: StringName, value: Variant) -> void:
	match key:
		&'says': show_messge(value[0], value[1])
		&'asks':
			show_messge(value[0], value[1])
			setup_reply_choices(value[2])
		_: print_debug('[%s] response: %s' % [key, value])


func _on_speaker_start(_name: String) -> void:
	start(_name)
