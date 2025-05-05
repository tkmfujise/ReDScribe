extends Control

@export var res : ReDScribe

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.channel.connect(_subscribe)
	res.perform("""
		# require 'src/example1/lib/boot'
		puts "Godot のバージョンは #{Godot::VERSION} です"
		Alice speak: 'Hello Ruby!'
		player 'Alice' do
		  level 1
		  job   :magician
		end
	""")

func _subscribe(key: StringName, payload: Variant) -> void:
	print_debug('[subscribe] ', key, ': ', payload)

func _method_missing(method_name: String, args: Array) -> void:
	print_debug('[method_missing] ', method_name, ': ', args)
