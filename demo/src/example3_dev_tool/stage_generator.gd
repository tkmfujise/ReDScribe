extends ReDScribe
class_name StageGenerator


func _init() -> void:
	boot_file = "res://src/example3_dev_tool/boot.rb"
	channel.connect(_subscribe)


func _subscribe(key: StringName, payload: Variant) -> void:
	print_debug(key, payload)
