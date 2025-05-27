extends GutTest

var pod : ReDScribe = null
var result

func before_each():
	pod = ReDScribe.new()
	pod.perform('require "addons/redscribe/mrblib/actor"')
	pod.channel.connect(_observe)
	result = null


func _observe(actor_name, attributes):
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
