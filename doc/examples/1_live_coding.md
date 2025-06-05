# 1. Live coding

[![Live coding](http://img.youtube.com/vi/FUZ-38F44i4/0.jpg)](https://www.youtube.com/watch?v=FUZ-38F44i4)

Create a scene as below. [ReDScribeEditor](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/src/editor/editor.gd) is a Node implementation for editing Ruby files in Godot.
```
Control
  └ HBoxContainer
      ├ ReDScribeEditor
      └ RichTextLabel
```
Then attach a GDScript.
```gdscript
extends Control

@onready var dsl := ReDScribe.new()

func _ready() -> void:
    dsl.method_missing.connect(_method_missing)
    %ReDScribeEditor.grab_focus()
    perform()

func perform() -> void:
    %RichTextLabel.text = ''
    dsl.perform(%ReDScribeEditor.text)

func add_circle() -> void:
    %RichTextLabel.text += '◯'

func add_square() -> void:
    %RichTextLabel.text += '■'

func _method_missing(method_name: String, args: Array) -> void:
    match method_name:
        'circle': add_circle()
        'square': add_square()
        _: return

func _on_re_d_scribe_editor_text_changed() -> void:
    perform()
```


