<img src="icon/icon_with_title.png" alt="logo">

# ReDScribe
Let’s re-describe your code as your own friendly domain-specific language.


#### Features:
* **Execution**: You can execute mruby code (a lightweight Ruby) in Godot and emit signals from mruby to Godot.
* **Editing**: You can write and edit Ruby files in the Godot Editor.
* **REPL**: You can try out Ruby interactively in Godot.


## Usage
```gdscript
extends Node

@onready var res := ReDScribe.new()

func _ready() -> void:
    res.method_missing.connect(_method_missing)
    res.channel.connect(_subscribe)
    res.perform("""

        Alice says: "Hello Ruby!"


        puts [
            'Welcome to Wonderland!',           ' ❤️ ',
            "Ruby version is v#{RUBY_VERSION}", ' ✨️ ',
            "powered by #{RUBY_ENGINE}",        ' 💎 ',
          ].join


        Godot.emit_signal :spawn, { name: 'Alice', job: 'wizard', level: 1 }


    """)

func _method_missing(method_name: String, args: Array) -> void:
    print_debug('[method_missing] ', method_name, ': ', args)

func _subscribe(key: StringName, payload: Variant) -> void:
    print_debug('[subscribe] ', key, ': ', payload)


# -- Output --
#
#   [method_missing] Alice: [{ &"says": "Hello Ruby!" }]
#
#   Welcome to Wonderland! ❤️ Ruby version is v3.4 ✨️ powered by mruby 💎 
#
#   [subscribe] spawn: { &"name": "Alice", &"job": "wizard", &"level": 1 }
#
```

## Architecture
<img src="doc/architecture.png" alt="architecture">


## Definitions

* *Properties*
  * String **boot_file**
  * String **exception**
* *Methods*
  * void **set_boot_file**(path: String)
  * void **perform**(dsl: String)
* *Signals*
  * **channel**(key: StringName, payload: Variant)
  * **method_missing**(method_name: String, args: Array)


## Built-in mruby methods

| mruby                             | description                          |
|-----------------------------------|--------------------------------------|
| `require 'path/to/file'`          | loads `res://path/to/file.rb` file.  |
| `puts 'something'`                | prints `something` in Godot console. |
| Object#method_missing             | emits `method_missing` signal.<br> `(method_name: String, args: Array)` |
| `Godot.emit_signal(key, payload)` | emits `channel` signal.<br> `(key: StringName, payload: Variant)`       |
| `Godot::VERSION`                  | Godot version                        |


## Type conversions

| mruby      |   | GDScript                    |
|------------|---|-----------------------------|
| true       | ⇒ | true                        |
| false      | ⇒ | false                       |
| nil        | ⇒ | null                        |
| Float      | ⇒ | float                       |
| Integer    | ⇒ | int                         |
| Symbol     | ⇒ | StringName                  |
| String     | ⇒ | String                      |
| Hash       | ⇒ | Dictionary                  |
| Array      | ⇒ | Array                       |
| Range      | ⇒ | Array                       |
| Time       | ⇒ | Dictionary                  |
| (others)   | ⇒ | String<br>(#inspect called) |

see: [demo/test/gdextension/test_variant.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/gdextension/test_variant.gd)


## Installation
1. Download the zip from the release.
2. Extract the zip and place the `(Your godot project root)/addons/redscribe` directory.
3. Open the project settings and enable `ReDScribe`.


## Screenshots

### Editor
<img src="doc/screenshots/ReDScribe_EditorArea_screenshot.png" alt="EditorArea screenshot">

### REPL
<img src="doc/screenshots/ReDScribe_REPL_screenshot.png" alt="REPL screenshot">

> [!CAUTION]
> In the REPL, local variables are undefined in the next input.	


## addons/redscribe/mrblib

I have created some libraries.
If you'd like to use them, add `require 'addons/redscribe/mrblib/xxx'` at the top of your script.

### actor
```ruby
require 'addons/redscribe/mrblib/actor'

actor 'Counter' do
  @number = 0
  --> { @number += 1 }
end
# `tick` => [ Counter ] signal emitted: { &"number": 0, &"name": "Counter" }
# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
```
see more: [demo/test/mrblib/test_actor.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_actor.gd)


### math
```ruby
require 'addons/redscribe/mrblib/math'

sin(π) # => 0.0
√(2)   # => 1.41421356237309
```
see more: [demo/test/mrblib/test_math.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_math.gd)

### resource
```ruby
require 'addons/redscribe/mrblib/resource'
resource :stage

stage 'First' do
  number 1
  music  'first_stage.mp3'
end
# => [ stage ] signal emitted: { &"music": "first_stage.mp3", &"number": 1, &"name": "First" }
```
see more: [demo/test/mrblib/test_resource.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_resource.gd)


### shell
```ruby
require 'addons/redscribe/mrblib/shell'

cd 'addons' do
  sh 'ls -lA'
end
# Execute the shell command `ls -lA` in the addons directory.
```
see more: [demo/test/mrblib/test_shell.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_shell.gd)


## Examples

### 1. Live coding
Create a scene as below.
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
[![Live coding](http://img.youtube.com/vi/FUZ-38F44i4/0.jpg)](https://www.youtube.com/watch?v=FUZ-38F44i4)


### 2. Resource generator


### 3. Co-routine (like Agent-based modeling)

I have created a DSL( [demo/addons/redscribe/mrblib/actor.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/actor.rb) ) using [Fiber](https://docs.ruby-lang.org/en/3.4/Fiber.html).

`-->{ do_something }` is a unit of execution.
`notify :message` broadcasts the message to all actors.
Call `tick` from a GDScript, then each actor will execute the next step in the cycle and emit a signal containing all instance variables (e.g., `@speed`) as a Dictionary.


Create a *boot.rb* file.
```ruby
require 'addons/redscribe/mrblib/actor'

actor 'Weather' do
  @current = :sunny
  --> {
    @current = (rand < 0.3) ? :raining : :sunny
    notify @current
  }
  2.times{ -->{ keep } }
end

actor 'Rabbit' do
  @position = 0
  @speed    = 150
  --> { run unless @wait }
  :sunny   --> { @wait = false }
  :raining --> { @wait = true }

  def run
    @position += @speed * rand
  end
end

actor 'Turtle' do
  @position = 0
  @speed    = 1
  --> { run }
  :cheer --> { @speed += 1 }

  def run
    @position += @speed
  end
end
```

Then, create a GDScript file and set the `boot_file` property of the `pod` instance in the `ReDScribe` class to *boot.rb*.
```gdscript
extends Control

signal game_over(actor_name: String)
@export var pod : ReDScribe

func _ready() -> void:
    pod.channel.connect(_observe)

func _observe(key: StringName, attributes: Dictionary) -> void:
    match key:
        'Rabbit': %Rabbit.update(attributes)
        'Turtle': %Turtle.update(attributes)
        'Weather':
            if attributes['current'] == &'raining':
                %Weather.label = '⛈️'
            else:
                %Weather.label = '☀️'
        _: return

func _on_timer_timeout() -> void:
    pod.perform('tick')

func _on_cheer_button_pressed() -> void:
    pod.perform('notify :cheer')

func _on_goal_area_entered(area: Area2D) -> void:
    var actor = area.get_parent()
    match actor.name:
        'Rabbit', 'Turtle': game_over.emit(actor.name)

func _on_game_over(actor_name: String) -> void:
    %Timer.stop()
    %Message.text = "The winner is %s!" % actor_name
```
[![Live coding](http://img.youtube.com/vi/zzF-uahzZ10/0.jpg)](https://www.youtube.com/watch?v=zzF-uahzZ10)



## Roadmap

### v0.1.0
* [x] method_missing signal
* [x] channel signal
* [x] Godot module
* [x] puts
* [x] boot.rb
* [x] require
* [x] Editor
* [x] REPL
* [x] compile
  * [x] debug/release
  * [x] windows
  * [x] mac
* [ ] Document
  * [x] doc/*.adoc
  * [ ] README
  * [x] Godot help
* [ ] Demo
  * [x] Example0: Basic
  * [x] Example1: Live Coding
  * [ ] Example2: Resource generator
  * [x] Example3: Co-routine


### v0.2.0 or later
* [ ] Document
  * [ ] Wiki
* [ ] Editor
  * [ ] Support multiple files open
  * [ ] Snippet
    * [ ] require
  * [ ] User definable theme
  * [ ] User definable syntax
* [ ] REPL
  * [ ] boot_file enabled
* [ ] fix bugs
  * [ ] `.rb` files cannot be displayed on the first launch.
* [ ] src/*.cpp
  * [ ] remove global variables
* [ ] compile
  * [ ] use github workflow
  * [ ] target
    * [x] windows.x86_64
    * [ ] windows.x86_32
    * [x] macos
    * [ ] linux.x86_64
    * [ ] linux.arm64
    * [ ] linux.rv64
    * [ ] android.x86_64
    * [ ] android.arm64
    * [ ] ios

