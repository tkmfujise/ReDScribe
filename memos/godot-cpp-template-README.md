<img src="icon/icon_with_title.png" alt="logo">

# ReDScribe
Re-describe your code better with ruby on Godot.


## Usage
```gdscript
extends Control

@onready var res := ReDScribe.new()

func _ready() -> void:
	res.method_missing.connect(_method_missing)
	res.perform("""
		foo  1, 2.3, true, false, nil, 'bar', :piyo
		bar	 piyo: 1, 'bar' => 2 
		piyo [1, 2.3, :bar]
	""")

func _method_missing(method_name: String, args: Array) -> void:
	print_debug(method_name, ': ', args)
  # outputs:
  #   foo: [1, 2.3, true, false, <null>, "bar", "piyo"]
  #   bar: [{ "piyo": 1, "bar": 2 }]
  #   piyo: [[1, 2.3, "bar"]]

```
