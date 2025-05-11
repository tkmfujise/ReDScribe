extends Control


func _on_button_1_pressed() -> void:
	show_popup("res://src/example1_simple/example1.tscn")


func _on_button_2_pressed() -> void:
	show_popup("res://src/example2_live_coding/example2.tscn")


func _on_button_3_pressed() -> void:
	show_popup("res://src/example3_dev_tool/example3.tscn")


func show_popup(tscn_file: String) -> void:
	var child = load(tscn_file).instantiate()
	%Popup.add_child(child)
	%Popup.show()


func _on_popup_popup_hide() -> void:
	for child in %Popup.get_children():
		child.queue_free()
