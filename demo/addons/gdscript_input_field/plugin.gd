@tool
extends EditorPlugin
## Adds a GDScript input field to the EditorLog.

static var GDSIS: GDScript

var _field: CodeEdit
var _session: RefCounted
var _history: PackedStringArray
var _history_index: int


## Traverses the editor's interface tree in search of the EditorLog.
func _find_editor_log(start: Node = null) -> Node:
	if not start:
		start = get_editor_interface().get_base_control()
	var result: Node = null
	if start.get_class() == 'EditorLog':
		result = start
	else:
		for child in start.get_children():
			result = _find_editor_log(child)
			if result:
				break
	return result


## Our desired parent should be the second child of the EditorLog.
func _find_parent_for_field() -> VBoxContainer:
	var editor_log := _find_editor_log()
	if editor_log:
		return editor_log.get_child(1) as VBoxContainer
	else:
		return null


## Executes and clears the field.
func _submit() -> void:
	var code := _field.text
	if not code.is_empty():
		_history.append(code)
		print("> %s" % code)
		var result := _session.eval(code) as Variant
		print("=> %s" % var_to_str(result))
	_history_index = _history.size()
	_history_recall()


func _history_back() -> void:
	if _history_index > 0:
		_history_index -= 1
		_history_recall()


func _history_forward() -> void:
	if _history_index < _history.size():
		_history_index += 1
		_history_recall()


func _history_recall() -> void:
	if _history_index < _history.size():
		_field.text = _history[_history_index]
	else:
		_field.clear()
	_field.clear_undo_history()
	_field.deselect()
	if _field.text.is_empty():
		_field.set_caret_line(0)
		_field.set_caret_column(0)
	else:
		_field.set_caret_line(_field.get_line_count())
		_field.set_caret_column(
			_field.get_line(_field.get_line_count() - 1).length()
		)


func _on_field_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed:
			match k.keycode:
				KEY_ENTER, KEY_KP_ENTER:
					if k.shift_pressed:
						_field.start_action(TextEdit.ACTION_TYPING)
						_field.insert_text_at_caret("\n")
					else:
						_submit()
						_field.accept_event()
				KEY_UP, KEY_KP_8:
					if _field.get_line_count() <= 1 or k.ctrl_pressed:
						_history_back()
						_field.accept_event()
				KEY_DOWN, KEY_KP_2:
					if _field.get_line_count() <= 1 or k.ctrl_pressed:
						_history_forward()
						_field.accept_event()


func _enter_tree() -> void:
	# Create and connect input field.
	_field = CodeEdit.new()
	_field.gui_input.connect(_on_field_gui_input)
	_field.caret_blink = true
	_field.scroll_fit_content_height = true
	_field.placeholder_text = "Evaluate GDScript"
	# Create other vars.
	_session = load(
		"res://addons/gdscript_input_field/gdscript_interactive_session.gd"
	).new()
	_session.inject("_editor_interface", get_editor_interface())
	_history = PackedStringArray([])
	_history_index = 0
	# Add input field to tree.
	var parent := _find_parent_for_field()
	if parent:
		parent.add_child(_field)
	else:
		push_error("Couldn't find the EditorLog's first VBoxContainer")
		_field.gui_input.disconnect(_on_field_gui_input)
		_field.queue_free()
		_field = null
		queue_free()


func _exit_tree() -> void:
	if _field:
		_field.gui_input.disconnect(_on_field_gui_input)
		_field.queue_free()
