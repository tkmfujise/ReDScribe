# 4. Dialog controller (Coroutine)

[![Coroutine](http://img.youtube.com/vi/VKq8AaNgXIM/0.jpg)](https://www.youtube.com/watch?v=VKq8AaNgXIM)

I have created a DSL( [demo/addons/redscribe/mrblib/coroutine.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/coroutine.rb) ) using [Fiber](https://docs.ruby-lang.org/en/3.4/Fiber.html).

`___?` simply calls `Fiber.yield`.

Create a *helper.rb* file for utilities.
```ruby
require 'addons/redscribe/mrblib/coroutine'

module Helper
  def says(str)
    case str
    when Array
      str[0..-2].each{|s| asks(s, true => 'Continue'); ___? }
      says(str.last)
    else
      emit! :says, [name, str]
    end
  end

  def asks(str, choices = { true => 'Yes', false => 'No' })
    emit! :asks, [name, str, choices]
  end

  def battle!
    emit! :battle, [name]
  end

  def hide!
    emit! :hide, [name]
  end
end

Coroutine.include Helper
```

And, create a *controller.rb* file for coroutines.
```ruby
require 'path/to/helper'

$people_spoken = Set.new

coroutine 'Woman' do
  asks "Hi! Do you like Ruby?"
  if ___?
    says "Oh! Really? I love Ruby too!"
  else
    says ["I see. If you haven't used Ruby much,",
          "spend more time with it. I'm sure you'll love it!"]
  end
  $people_spoken.add(name)
end

coroutine 'Man' do
  asks "Which game do you like the most?", {
    mother2: "MOTHER2",
    zelda:   "The Legend of Zelda",
    pokemon: "Pokémon",
  }
  case ___?
  when :mother2
    says "I also love it. MOTHER2 is my origin."
  when :zelda
    says "I also love it. The Legend of Zelda is a huge part of my life."
  when :pokemon
    says "When our eyes meet, it's time for a Pokémon battle!"
    battle!
  end
  $people_spoken.add(name)
end

coroutine 'Ninja' do
  if $people_spoken.size < 2
    says ["...", "... #{$people_spoken.size}"]
  else
    says "See you later."
    hide!
  end
end
```

Then, create a GDScript file and set the `boot_file` property of the `controller` instance in the `ReDScribe` class to *controller.rb*.
```gdscript
extends Control

@export var controller : ReDScribe

func _ready() -> void:
    controller.channel.connect(_handle)
    setup_choices()

func start(_name: String) -> void:
    controller.perform('start "%s"' % _name)

func resume(value: Variant = true) -> void:
    controller.perform('continue %s' % value)

func show_messge(speaker_name: String, body: String) -> void:
    hide_choices()
    %Message.text = "( %s )\n%s" % [speaker_name, body]

func setup_choices(dict: Dictionary = {}) -> void:
    hide_choices()
    for key in dict: add_choice(dict[key], key)

func hide_choices() -> void:
    for child in %Reply.get_children(): child.queue_free()

func add_choice(label: String, value: Variant) -> void:
    var btn = %TemplateButton.duplicate()
    btn.show()
    btn.text = label
    btn.pressed.connect(resume.bind(_value_for_rb(value)))
    %Reply.add_child(btn)

func hide_speaker(speaker_name: String) -> void:
    get_node(speaker_name).hide()

func _value_for_rb(value: Variant) -> Variant:
    match typeof(value):
        TYPE_STRING_NAME: return ':%s' % value
        TYPE_STRING:      return '"%s"' % value
        TYPE_NIL:         return 'nil'
        _: return value

func _handle(key: StringName, value: Variant) -> void:
    match key:
        &'says': show_messge(value[0], value[1])
        &'asks':
             show_messge(value[0], value[1])
             setup_choices(value[2])
        &'hide': hide_speaker(value[0])
        &'battle':
             print_debug('TODO: battle!')
        _: print_debug('[%s] response: %s' % [key, value])

func _on_speaker_start(_name: String) -> void:
    start(_name)
```

