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


func _on_area_2d_area_entered(area: Area2D) -> void:
	var actor = area.get_parent()
	match actor.name:
		'Rabbit', 'Turtle': game_over.emit(actor.name)


func _on_game_over(actor_name: String) -> void:
	%Timer.stop()
	%Message.text = "The winner is %s!" % actor_name
