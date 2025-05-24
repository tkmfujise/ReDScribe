extends Control

@export var res : ReDScribe

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.channel.connect(_subscribe)
	res.perform("""
		Alice speak: 'Hello Ruby!'

		require 'addons/redscribe/mrblib/resource'
		resource :player

		player 'Alice' do
		  level 1
		  job   :magician
		end
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
	var f = FileAccess.open("res://src/example0_basic/example_0.gd", FileAccess.READ)
	%Code.text = f.get_as_text()
	f.close()
