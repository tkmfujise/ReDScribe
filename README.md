<img src="icon/icon_with_title.png" alt="logo">

# ReDScribe
Re-describe your code friendly as a domain-specific language with mruby on Godot.


## Usage
```gdscript
extends Node

@onready var res := ReDScribe.new()

func _ready() -> void:
    res.method_missing.connect(_method_missing)
    res.perform("""
        foo  1, 2.3, true, false, nil, 'bar', :piyo
        bar  piyo: 1, 'bar' => 2 
        piyo [1, 2.3, :bar]
    """)

func _method_missing(method_name: String, args: Array) -> void:
    print_debug(method_name, ': ', args)
    # outputs:
    #   foo: [1, 2.3, true, false, <null>, "bar", "piyo"]
    #   bar: [{ "piyo": 1, "bar": 2 }]
    #   piyo: [[1, 2.3, "bar"]]
```

## Roadmap

### v0.1.0
* [x] method_missing signal
* [x] channel signal
* [x] Godot module
* [x] puts
* [ ] boot.rb
* [ ] require

### v0.2.0
* [ ] REPL
* [ ] cross-compiling




