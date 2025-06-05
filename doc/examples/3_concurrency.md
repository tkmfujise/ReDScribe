# 3. Concurrency (like Agent-based model)

[![Concurrency](http://img.youtube.com/vi/zzF-uahzZ10/0.jpg)](https://www.youtube.com/watch?v=zzF-uahzZ10)

I have created a DSL( [demo/addons/redscribe/mrblib/actor.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/actor.rb) ).

`-->{ do_something }` is a unit of execution, and each actor's process runs sequentially within a loop.

Call `tick` from a GDScript, then each actor will execute its next step in the cycle and emit a signal containing all instance variables (e.g., `@speed`) as a Dictionary.


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
    pod.perform('tell "Turtle", :cheer')

func _on_goal_area_entered(area: Area2D) -> void:
    var actor = area.get_parent()
    match actor.name:
        'Rabbit', 'Turtle': game_over.emit(actor.name)

func _on_game_over(actor_name: String) -> void:
    %Timer.stop()
    %Message.text = "The winner is %s!" % actor_name
```

