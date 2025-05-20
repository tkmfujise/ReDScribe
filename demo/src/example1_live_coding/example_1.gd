extends Control

@onready var dsl := ReDScribe.new()


func _ready() -> void:
	dsl.method_missing.connect(_method_missing)
	%ReDScribeEditor.grab_focus()
	perform()


func perform() -> void:
	%RichTextLabel.text = ''
	dsl.perform(%ReDScribeEditor.text)


func add_circle() -> void:
	%RichTextLabel.text += '◯'


func add_square() -> void:
	%RichTextLabel.text += '■'


func _method_missing(method_name: String, _args: Array) -> void:
	match method_name:
		'circle': add_circle()
		'square': add_square()
		_: return


func _on_re_d_scribe_editor_text_changed() -> void:
	perform()
