extends Control

@export var res : ReDScribe

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.channel.connect(_subscribe)
	res.perform("""

		Alice says: "Hello Ruby! ❤️"

		puts "Welcome to the world of Ruby v#{RUBY_VERSION}, powered by #{RUBY_ENGINE} 💎"

		Godot.emit_signal :spawn, { name: 'Alice', job: 'wizard', level: 1 }

	""")
	show_gdscript()


func _subscribe(key: StringName, payload: Variant) -> void:
	log_text('[subscribe] '+ key +': '+ str(payload))


func _method_missing(method_name: String, args: Array) -> void:
	log_text('[method_missing] '+ method_name +': '+ str(args))


func log_text(text: String) -> void:
	%Result.text += text + "\n"
	print_debug(text)


func show_gdscript() -> void:
	%Code.text = get('script').get_source_code()
