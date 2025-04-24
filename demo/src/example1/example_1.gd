extends Control

@onready var res := ReDScribe.new()

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.channel.connect(_subscribe)
	res.perform("""
		Godot.emit_signal :foo, 'test'
	""")

func _subscribe(key: String, payload: Variant) -> void:
	print_debug(key, ': ', payload)

func _method_missing(method_name: String, args: Array) -> void:
	print_debug(method_name, ': ', args)
