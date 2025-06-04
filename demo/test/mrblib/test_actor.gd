extends GutTest

var pod : ReDScribe = null
var result
var fetched_value
const FETCH_SIGNAL = 'fetch_value'

func before_each():
	pod = ReDScribe.new()
	pod.perform('require "addons/redscribe/mrblib/actor"')
	pod.channel.connect(_observe)
	result = []
	fetched_value = null


func perform(code) -> void:
	result = []
	pod.perform(code)


func fetch(code) -> Variant:
	fetched_value = null
	pod.perform("Godot.emit_signal :%s, (%s)" % [FETCH_SIGNAL, code])
	return fetched_value


func _observe(actor_name, attributes):
	match actor_name:
		FETCH_SIGNAL:
			fetched_value = attributes
		_:
			result.push_back({ 'actor_name': actor_name, 'attributes': attributes })


func test_plain():
	perform("""
		actor 'Foo' do
		  @number = 0
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 0)
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 0)


func test_simple():
	perform("""
		actor 'Foo' do
		  @number = 0
		  -->{ @number += 1 }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 1)
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 2)
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 3)


func test_define_method():
	perform("""
		actor 'Foo' do
		  @number = 0
		  -->{ succ }
		  def succ
			@number += 1
		  end
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 1)
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 2)


func test_notify_from_outside():
	perform("""
		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 0)
	perform('notify :succ')
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 1)


func test_notify_from_another_actor():
	perform("""
		actor 'Bar' do
		  --> { keep }
		  --> { notify :succ }
		end

		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['actor_name'], 'Bar')
	assert_eq(result[0]['attributes'], { &'name': 'Bar' })
	assert_eq(result[1]['actor_name'], 'Foo')
	assert_eq(result[1]['attributes']['number'], 0)
	perform('tick')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['actor_name'], 'Bar')
	assert_eq(result[0]['attributes'], { &'name': 'Bar' })
	assert_eq(result[1]['actor_name'], 'Foo')
	assert_eq(result[1]['attributes']['number'], 1)


func test_notify_if_nothing():
	perform('notify :foo')
	assert_eq(pod.exception, '')



func test_tell_from_outside():
	perform("""
		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 0)
	assert_eq(result.size(), 1)
	perform('tell "Foo", :succ')
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 1)


func test_tell_from_another_actor():
	perform("""
		actor 'Bar' do
		  --> { keep }
		  --> { tell 'Foo', :succ }
		end

		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['actor_name'], 'Bar')
	assert_eq(result[0]['attributes'], { &'name': 'Bar' })
	assert_eq(result[1]['actor_name'], 'Foo')
	assert_eq(result[1]['attributes']['number'], 0)
	perform('tick')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['actor_name'], 'Bar')
	assert_eq(result[0]['attributes'], { &'name': 'Bar' })
	assert_eq(result[1]['actor_name'], 'Foo')
	assert_eq(result[1]['attributes']['number'], 1)


func test_tell_if_nothing():
	perform('tell "Foo", :bar')
	assert_eq(pod.exception, '')



func test_ask_from_outside():
	perform("""
		actor 'Foo' do
		  @number = 0
		end
	""")
	assert_eq(result, [])
	assert_eq(fetch('ask "Foo", :number'), 0)


func test_ask_from_another_actor():
	perform("""
		actor 'Foo' do
		  @number = 1
		end

		actor 'Bar' do
		  --> { @value = ask 'Foo', :number }
		end
	""")
	assert_eq(result, [])
	perform('tick')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['actor_name'], 'Foo')
	assert_eq(result[0]['attributes']['number'], 1)
	assert_eq(result[1]['actor_name'], 'Bar')
	assert_eq(result[1]['attributes']['value'], 1)


func test_ask_if_nothing():
	perform('ask "Foo", :bar')
	assert_eq(pod.exception, '')



func test_free():
	perform("""
		actor 'Foo' do
		  :bar --> {}
		end

		actor 'Bar' do
		  :bar --> {}
		end

		actor 'Buz' do
		  :foo --> {}
		end
	""")
	assert_eq(fetch('Actor.all.size'), 3)
	assert_eq(fetch('Actor.listeners[:bar].size'), 2)
	assert_eq(fetch('Actor.listeners[:foo].size'), 1)
	perform('free "Foo"')
	assert_eq(fetch('Actor.all.size'), 2)
	assert_eq(fetch('Actor.listeners[:bar].size'), 1)
	assert_eq(fetch('Actor.listeners[:foo].size'), 1)
	perform('free "Bar"')
	assert_eq(fetch('Actor.all.size'), 1)
	assert_eq(fetch('Actor.listeners[:bar].size'), 0)
	assert_eq(fetch('Actor.listeners[:foo].size'), 1)
	perform('free "Buz"')
	assert_eq(fetch('Actor.all.size'), 0)
	assert_eq(fetch('Actor.listeners[:bar].size'), 0)
	assert_eq(fetch('Actor.listeners[:foo].size'), 0)
	perform('free "Test"')
	assert_eq(pod.exception, '')


func test_free_if_nothing():
	perform('free "Test"')
	assert_eq(pod.exception, '')
