@tool
extends VBoxContainer

@onready var session := ReDScribe.new()

const RELOAD_COMMAND = 'reload!'

var last_result = null : set = set_last_result
var input_histories : PackedStringArray
var history_back_idx := 0


func _ready() -> void:
	session.channel.connect(_subscribe)


func perform() -> void:
	var code = str(%Input.text).strip_edges()
	if not code: return
	delete_input()
	match code:
		RELOAD_COMMAND: reload_repl()
		_: execute(code)


func execute(code: String) -> void:
	input_histories.push_back(code)
	output(code)
	session.perform("Godot.emit_signal :input, (%s)" % code)
	if session.exception:
		output("Error: %s" % session.exception)



func reload_repl() -> void:
	output("Session reloading...")
	session = ReDScribe.new()
	output("Session reloaded!", true)


func set_last_result(val) -> void:
	last_result = val
	var output_val
	if val is String:
		output_val = '"%s"' % val
	else:
		output_val = str(val)
	output("=> " + output_val)


func output(str: String, clear: bool = false) -> void:
	if clear: %Result.text = ''
	%Result.text += str + "\n"


func history_back() -> void:
	history_back_idx += 1
	%Input.text = input_histories.get(
		input_histories.size() - history_back_idx)


func delete_input() -> void:
	history_back_idx = 0
	%Input.text = ''


func delete_following_input() -> void:
	%Input.text = '' # TODO


func _subscribe(key: StringName, payload: Variant) -> void:
	match key:
		'input': last_result = payload


func _on_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed:
			match k.keycode:
				KEY_ENTER:
					if k.ctrl_pressed: perform()
				KEY_U:
					if k.ctrl_pressed: delete_input()
				KEY_K:
					if k.ctrl_pressed: delete_following_input()
				KEY_L:
					if k.ctrl_pressed: output('', true)
				KEY_UP:
					pass # TODO consider multi line
					# history_back()
