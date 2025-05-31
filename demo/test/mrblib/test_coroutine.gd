extends GutTest

var res : ReDScribe = null
var result


func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/coroutine"')
	res.channel.connect(_subscribe)
	result = null


func _subscribe(key, payload):
	result = { 'key': key, 'payload': payload }


func test_simple():
	res.perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_null(result)
	res.perform('resume')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_yield():
	res.perform("""
		coroutine 'Foo' do
		  val = ___?
		  emit! :foo, val
		end
	""")
	assert_null(result)
	res.perform('resume')
	assert_null(result)
	res.perform('resume "Foo", true')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], true)


func test_yield_loop():
	res.perform("""
		coroutine do
		  loop do
			emit! :given, ___?
		  end
		end
	""")
	assert_null(result)
	res.perform('continue')
	assert_null(result)
	res.perform('continue 1')
	assert_not_null(result)
	assert_eq(result['key'], &'given')
	assert_eq(result['payload'], 1)
	res.perform('continue 2')
	assert_not_null(result)
	assert_eq(result['key'], &'given')
	assert_eq(result['payload'], 2)


func test_invoke():
	res.perform("""
		coroutine do
		  until ___?
			emit! :main, ___
		  end
		  invoke! 'sub'
		end

		coroutine 'sub' do
		  emit! :sub, 'called'
		end
	""")
	assert_null(result)
	res.perform('continue')
	assert_null(result)
	res.perform('continue')
	assert_not_null(result)
	assert_eq(result['key'], &'main')
	assert_eq(result['payload'], null)
	res.perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')


func test_invoke_and_loop():
	res.perform("""
		coroutine do
		  loop do
			if ___?
			  invoke! 'sub'
			end
		  end
		end

		coroutine 'sub' do
		  emit! :sub, 'called'
		end
	""")
	assert_null(result)
	res.perform('continue')
	assert_null(result)
	res.perform('continue')
	assert_null(result)
	res.perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')
	res.perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')



func test_yield_in_invoked_one():
	res.perform("""
		coroutine do
		  invoke! 'sub'
		  emit! :main, 'called'
		end

		coroutine 'sub' do
		  emit! :sub, ___?
		end
	""")
	assert_null(result)
	res.perform('continue')
	assert_null(result)
	res.perform('continue 1')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 1)
	res.perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'main')
	assert_eq(result['payload'], 'called')
