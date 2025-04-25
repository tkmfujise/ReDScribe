extends Control

@onready var res := ReDScribe.new()

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.channel.connect(_subscribe)
	res.perform("""
		puts 1, 2
	""")

func _subscribe(key: String, payload: Variant) -> void:
	print_debug('[subscribe] ', key, ': ', payload)

func _method_missing(method_name: String, args: Array) -> void:
	print_debug('[method_missing] ', method_name, ': ', args)
