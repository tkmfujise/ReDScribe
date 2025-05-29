extends Control


func _on_button_0_pressed() -> void:
	show_popup("res://src/example0_basic/example0.tscn")


func _on_button_1_pressed() -> void:
	show_popup("res://src/example1_live_coding/example1.tscn")


func _on_button_2_pressed() -> void:
	show_popup("res://src/example2_resource_generator/example2.tscn")


func _on_button_3_pressed() -> void:
	show_popup("res://src/example3_concurrency/example3.tscn")


func show_popup(tscn_file: String) -> void:
	var child = load(tscn_file).instantiate()
	child.size_flags_horizontal = SIZE_EXPAND_FILL
	%PopupBody.add_child(child)
	%ExampleLabel.text = tscn_file
	%Popup.show()


func _on_popup_popup_hide() -> void:
	for child in %PopupBody.get_children():
		child.queue_free()


func _on_back_button_pressed() -> void:
	%Popup.hide()
