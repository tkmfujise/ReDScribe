<img src="icon/icon_with_title.png" alt="logo">

# ReDScribe
Re-describe your code friendly as a domain-specific language with mruby on Godot.


> [!CAUTION]
> This project is currently in an experimental stage and may undergo significant changes.
> > まだ他人が使えるほど親切な状態にはなっていません。プラグインとして公開されるまで気長にお待ち下さい。


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
* [x] boot.rb
* [x] require
* [ ] create as a plugin
* [ ] REPL
* [ ] cross-compiling




