@tool
extends VBoxContainer

var session : ReDScribe = null

const RELOAD_COMMAND = 'reload!'
const REPL_CHANNEL = 'repl'


var last_result = null : set = set_last_result
var input_histories : PackedStringArray
var history_back_idx := 0


func _ready() -> void:
	#init_session() # not working
	pass


func grab_focus() -> void:
	%Input.grab_focus()


func init_session() -> void:
	if session: session = null
	session = ReDScribe.new()
	session.method_missing.connect(_method_missing)
	session.channel.connect(_subscribe)


func perform() -> void:
	var code = str(%Input.text).strip_edges()
	if not code: return
	call_deferred('delete_input')
	if not session: init_session()
	match code:
		RELOAD_COMMAND: reload_repl()
		_: execute(code)


func execute(code: String) -> void:
	input_histories.push_back(code)
	output(code)
	session.perform("Godot.emit_signal :%s,(\n%s\n)" % [REPL_CHANNEL, code])
	if session.exception:
		output_color("Error: %s" % session.exception, 'red')



func reload_repl() -> void:
	output_color("Session reloading...", 'forestgreen')
	init_session()
	output_color("Session reloaded!", 'forestgreen', true)


func set_last_result(val) -> void:
	last_result = val
	output("=> " + format_output_val(val))


func format_output_val(val) -> String:
	match typeof(val):
		TYPE_STRING: return '"%s"' % val
		TYPE_ARRAY:
			return '[' + \
				", \n".join(val.map(func(e): return str(e))) + \
				']'
		_: return str(val)


func output(str: String, clear: bool = false) -> void:
	output_color(str, '', clear)


func output_color(str: String, color: String, clear: bool = false) -> void:
	if clear: %Result.text = ''
	%Result.text += bb_color(str, color) + "\n"


func bb_color(str: String, color: String) -> String:
	return "[color=%s]%s[/color]" % [color, str]


func history_back() -> void:
	set_input_from_history(1)
	call_deferred('move_caret_last')


func history_forward() -> void:
	set_input_from_history(-1)
	call_deferred('move_caret_last')


func set_input_from_history(direction: int) -> void:
	history_back_idx += direction
	var count = input_histories.size()
	if history_back_idx < 1:
		history_back_idx = 0
		%Input.text = ''
	elif count < history_back_idx:
		history_back_idx = count + 1
		%Input.text = ''
	else:
		%Input.text = input_histories.get(count - history_back_idx)


func move_caret_last() -> void:
	var l_idx = %Input.get_line_count()
	var c_idx = %Input.get_line(l_idx - 1).length()
	%Input.set_caret_line(l_idx)
	%Input.set_caret_column(c_idx)


func delete_input() -> void:
	history_back_idx = 0
	%Input.text = ''


func delete_following_input() -> void:
	var idx = %Input.get_caret_line()
	%Input.remove_text(
		idx,
		%Input.get_caret_column(),
		idx,
		%Input.get_line(idx).length())



func _method_missing(method_name: String, args: Array) -> void:
	output_color(
		('[ %s ] method_missing: ' % method_name) + str(args),
		'red')


func _subscribe(key: StringName, payload: Variant) -> void:
	match key:
		REPL_CHANNEL: last_result = payload
		_: output_color(
			("[ %s ] signal emitted: " % key) + format_output_val(payload),
			'#0044FF') # Vivid Blue


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
					if %Input.get_line_count() == 1:
						history_back()
				KEY_DOWN:
					if %Input.get_line_count() == 1:
						history_forward()
