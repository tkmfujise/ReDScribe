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

        Alice says: "Hello Ruby! ❤️"

        puts "Welcome to the world of Ruby v#{RUBY_VERSION}, powered by #{RUBY_ENGINE} 💎"

        Godot.emit_signal :spawn, { name: 'Alice', job: 'wizard', level: 1 }

    """)

func _method_missing(method_name: String, args: Array) -> void:
    print_debug('[method_missing] ', method_name, ': ', args)

func _subscribe(key: StringName, payload: Variant) -> void:
    print_debug('[subscribe] ', key, ': ', payload)


# -- Output --
#
#   [method_missing] Alice: [{ &"says": "Hello Ruby! ❤️" }]
#
#   Welcome to the world of Ruby v3.4, powered by mruby 💎
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
| `puts 'something'`                | prints `something` to the Output panel in Godot. |
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
2. Extract the zip and place the `redscribe` directory into `(Your godot project root)/addons` directory.
3. Open the project settings and enable `ReDScribe`.


## Screenshots

### Editor
<img src="doc/screenshots/ReDScribe_EditorArea_screenshot.png" alt="EditorArea screenshot">

> [!NOTE]
> For `@` and `:`, syntax highlighting requires a following whitespace to work correctly.

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
  :reset --> { @number = 0 }
end

# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
# `tick` => [ Counter ] signal emitted: { &"number": 2, &"name": "Counter" }
#
# `notify :reset`
# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
#
# `tell 'Counter', :reset`
# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
#
# `ask 'Counter', :number` # => 1
```
see more:
* [demo/addons/redscribe/mrblib/actor.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/actor.rb)
* [demo/test/mrblib/test_actor.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_actor.gd)


### coroutine
```ruby
require 'addons/redscribe/mrblib/coroutine'

coroutine do
  loop do
    emit! :given, ___?
  end
end

# `start`         # When `___?` called, it stops until the next continue.
# `continue`      => [ given ] signal emitted: true
# `continue 123`  => [ given ] signal emitted: 123
```
```ruby
require 'addons/redscribe/mrblib/coroutine'

coroutine 'Foo' do
  emit! :foo, :started
  while ___?
    emit! :foo, :progress
  end
  emit! :foo, :finished
end

coroutine 'Bar' do
  emit! :bar, :started
  while ___?
    emit! :bar, :progress
  end
  emit! :bar, :finished
end

# `start :all`          # all coroutine start
#                       => [ foo ] signal emitted: &"started"
#                       => [ bar ] signal emitted: &"started"
# `resume 'Foo'`        => [ foo ] signal emitted: &"progress"
# `resume 'Bar', true`  => [ bar ] signal emitted: &"progress"
# `resume 'Foo', false` => [ foo ] signal emitted: &"finished"
# `resume 'Bar', false` => [ bar ] signal emitted: &"finished"
```
see more:
* [demo/addons/redscribe/mrblib/coroutine.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/coroutine.rb)
* [demo/test/mrblib/test_coroutine.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_coroutine.gd)


### math
```ruby
require 'addons/redscribe/mrblib/math'

sin(π) # => 0.0
√(2)   # => 1.41421356237309
```
see more:
* [demo/addons/redscribe/mrblib/math.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/math.rb)
* [demo/test/mrblib/test_math.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_math.gd)


### resource
```ruby
require 'addons/redscribe/mrblib/resource'
resource :stage do
  resource :image
  resources :chapter => :chapters
end

stage 'First' do
  number 1
  music  'first_stage.mp3'

  image do
    path 'first_stage.png'
  end

  chapter do
    name  'Chapter1'
    image 'path/to/chapter1.png'
  end

  chapter do
    name  'Chapter2'
    image 'path/to/chapter2.png'
  end
end

# => [ stage ] signal emitted:
# {
#   &"number": 1,
#   &"music": "first_stage.mp3",
#   &"name":  "First",
#   &"image": {
#     &"path": "first_stage.png",
#     &"name": "image_6308476176"
#   },
#   &"chapters": [
#     {
#       &"image": "path/to/chapter1.png",
#       &"name":  "Chapter1"
#     },
#     {
#       &"image": "path/to/chapter2.png",
#       &"name":  "Chapter2"
#     }
#   ]
# }
```
see more:
* [demo/addons/redscribe/mrblib/resource.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/resource.rb)
* [demo/test/mrblib/test_resource.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_resource.gd)


### shell
```ruby
require 'addons/redscribe/mrblib/shell'

cd 'addons' do
  sh 'ls -lA'
end
# Execute the shell command `ls -lA` in the addons directory.
```
see more:
* [demo/addons/redscribe/mrblib/shell.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/shell.rb)
* [demo/test/mrblib/test_shell.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_shell.gd)


## Examples

### 1. Live coding

[![Live coding](http://img.youtube.com/vi/FUZ-38F44i4/0.jpg)](https://www.youtube.com/watch?v=FUZ-38F44i4)

see more: [doc/examples/1_live_coding.md](https://github.com/tkmfujise/ReDScribe/blob/main/doc/examples/1_live_coding.md)



### 2. Resource generator

[![Concurrency](http://img.youtube.com/vi/NS4m7VBYJNk/0.jpg)](https://www.youtube.com/watch?v=NS4m7VBYJNk)

see more: [doc/examples/2_resource_generator.md](https://github.com/tkmfujise/ReDScribe/blob/main/doc/examples/2_resource_generator.md)


### 3. Concurrency (like Agent-based model)

[![Concurrency](http://img.youtube.com/vi/zzF-uahzZ10/0.jpg)](https://www.youtube.com/watch?v=zzF-uahzZ10)

see more: [doc/examples/3_concurrency.md](https://github.com/tkmfujise/ReDScribe/blob/main/doc/examples/3_concurrency.md)


### 4. Dialog controller (Coroutine)

[![Coroutine](http://img.youtube.com/vi/VKq8AaNgXIM/0.jpg)](https://www.youtube.com/watch?v=VKq8AaNgXIM)

see more: [doc/examples/4_coroutine.md](https://github.com/tkmfujise/ReDScribe/blob/main/doc/examples/4_coroutine.md)


## Development

### build

After installing the required packages, run the following command.
```
$ rake
```
see: [Rakefile](https://github.com/tkmfujise/ReDScribe/blob/main/Rakefile)


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
* [x] Document
  * [x] doc/*.adoc
  * [x] README
  * [x] Godot help
* [x] Demo
  * [x] Example0: Basic
  * [x] Example1: Live Coding
  * [x] Example2: Resource generator
  * [x] Example3: Concurrency
  * [x] Example4: Coroutine


### v0.2.0 or later
* [ ] Document
  * [ ] Wiki
* [ ] Editor
  * [ ] Support multiple files open
  * [ ] Support search text
  * [ ] Snippet
    * [ ] require
  * [ ] User definable theme
  * [ ] User definable syntax
* [ ] REPL
  * [ ] boot_file enabled
* [ ] mrblib
  * [ ] core_ext like ActiveSupport
    * [ ] Duration (e.g. `1.day.ago`)
* [ ] src/*.cpp
  * [ ] Regexp support (call Godot RegEx)
  * [ ] remove global variables
* [ ] fix bugs
  * [ ] `.rb` files cannot be displayed on the first launch.
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

