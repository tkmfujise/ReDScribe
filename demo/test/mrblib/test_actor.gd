extends GutTest

var pod : ReDScribe = null
var result
var fetched_value
const FETCH_SIGNAL = 'fetch_value'

func before_each():
	pod = ReDScribe.new()
	pod.perform('require "addons/redscribe/mrblib/actor"')
	pod.channel.connect(_observe)
	result = null
	fetched_value = null


func fetch(code) -> Variant:
	fetched_value = null
	pod.perform("Godot.emit_signal :%s, (%s)" % [FETCH_SIGNAL, code])
	return fetched_value


func _observe(actor_name, attributes):
	match actor_name:
		FETCH_SIGNAL:
			fetched_value = attributes
		_:
			result = { 'actor_name': actor_name, 'attributes': attributes }


func test_plain():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)


func test_simple():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		  -->{ @number += 1 }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 2)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 3)


func test_define_method():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		  -->{ succ }
		  def succ
			@number += 1
		  end
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 2)


func test_notify_from_outside():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('notify :succ')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)


func test_notify_from_another_actor():
	pod.perform("""
		actor 'Bar' do
		  --> { keep }
		  --> { notify :succ }
		end

		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)


func test_notify_if_nothing():
	pod.perform('notify :foo')
	assert_eq(pod.exception, '')



func test_tell_from_outside():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tell "Foo", :succ')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)


func test_tell_from_another_actor():
	pod.perform("""
		actor 'Bar' do
		  --> { keep }
		  --> { tell 'Foo', :succ }
		end

		actor 'Foo' do
		  @number = 0
		  :succ -->{ @number += 1 }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 0)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Foo')
	assert_eq(result['attributes']['number'], 1)


func test_tell_if_nothing():
	pod.perform('tell "Foo", :bar')
	assert_eq(pod.exception, '')



func test_ask_from_outside():
	pod.perform("""
		actor 'Foo' do
		  @number = 0
		end
	""")
	assert_eq(result, null)
	assert_eq(fetch('ask "Foo", :number'), 0)


func test_ask_from_another_actor():
	pod.perform("""
		actor 'Foo' do
		  @number = 1
		end

		actor 'Bar' do
		  --> { @value = ask 'Foo', :number }
		end
	""")
	assert_eq(result, null)
	pod.perform('tick')
	assert_eq(result['actor_name'], 'Bar')
	assert_eq(result['attributes']['value'], 1)


func test_ask_if_nothing():
	pod.perform('ask "Foo", :bar')
	assert_eq(pod.exception, '')



func test_free():
	pod.perform("""
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
	pod.perform('free "Foo"')
	assert_eq(fetch('Actor.all.size'), 2)
	assert_eq(fetch('Actor.listeners[:bar].size'), 1)
	assert_eq(fetch('Actor.listeners[:foo].size'), 1)
	pod.perform('free "Bar"')
	assert_eq(fetch('Actor.all.size'), 1)
	assert_eq(fetch('Actor.listeners[:bar].size'), 0)
	assert_eq(fetch('Actor.listeners[:foo].size'), 1)
	pod.perform('free "Buz"')
	assert_eq(fetch('Actor.all.size'), 0)
	assert_eq(fetch('Actor.listeners[:bar].size'), 0)
	assert_eq(fetch('Actor.listeners[:foo].size'), 0)
	pod.perform('free "Test"')
	assert_eq(pod.exception, '')


func test_free_if_nothing():
	pod.perform('free "Test"')
	assert_eq(pod.exception, '')
