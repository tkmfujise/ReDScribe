extends Control

@onready var res := ReDScribe.new()

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.perform("""
		def bar; end
		bar # これは method_missing にはならない。
		3.times { foo } # これは method_missing で gdscript 側で捕捉
	""")

func _method_missing(method_name: String) -> void:
	print_debug(method_name)
