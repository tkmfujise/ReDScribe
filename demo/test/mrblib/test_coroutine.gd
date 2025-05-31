extends GutTest

var res : ReDScribe = null
var result


func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/coroutine"')
	res.channel.connect(_subscribe)
	result = null


func perform(code):
	result = null
	res.perform(code)


func _subscribe(key, payload):
	result = { 'key': key, 'payload': payload }


func test_start():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_null(result)
	perform('start')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_start_name():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  emit! :bar, 'piyo'
		end
	""")
	assert_null(result)
	perform('start "Foo"')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_start_mutiple():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_null(result)
	perform('start "Foo"')
	assert_not_null(result)
	perform('start "Foo"')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_resume():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_null(result)
	perform('resume')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_resume_name():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  emit! :bar, 'piyo'
		end
	""")
	assert_null(result)
	perform('resume "Foo"')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], 'bar')


func test_resume_mutiple():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_null(result)
	perform('resume "Foo"')
	assert_not_null(result)
	perform('resume "Foo"')
	assert_null(result)


func test_yield():
	perform("""
		coroutine 'Foo' do
		  val = ___?
		  emit! :foo, val
		end
	""")
	assert_null(result)
	perform('resume')
	assert_null(result)
	perform('resume "Foo", true')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], true)


func test_yield_alias_1():
	perform("""
		coroutine 'Foo' do
		  _?
		  emit! :foo, _
		end
	""")
	assert_null(result)
	perform('resume')
	assert_null(result)
	perform('resume "Foo", true')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], true)


func test_yield_alias_2():
	perform("""
		coroutine 'Foo' do
		  __?
		  emit! :foo, __
		end
	""")
	assert_null(result)
	perform('resume')
	assert_null(result)
	perform('resume "Foo", true')
	assert_not_null(result)
	assert_eq(result['key'], &'foo')
	assert_eq(result['payload'], true)


func test_yield_loop():
	perform("""
		coroutine do
		  loop do
			emit! :given, ___?
		  end
		end
	""")
	assert_null(result)
	perform('continue')
	assert_null(result)
	perform('continue 1')
	assert_not_null(result)
	assert_eq(result['key'], &'given')
	assert_eq(result['payload'], 1)
	perform('continue 2')
	assert_not_null(result)
	assert_eq(result['key'], &'given')
	assert_eq(result['payload'], 2)


func test_invoke():
	perform("""
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
	perform('continue')
	assert_null(result)
	perform('continue')
	assert_not_null(result)
	assert_eq(result['key'], &'main')
	assert_eq(result['payload'], null)
	perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')


func test_invoke_and_loop():
	perform("""
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
	perform('continue')
	assert_null(result)
	perform('continue')
	assert_null(result)
	perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')
	perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 'called')



func test_yield_in_invoked_one():
	perform("""
		coroutine do
		  invoke! 'sub'
		  emit! :main, 'called'
		end

		coroutine 'sub' do
		  emit! :sub, ___?
		end
	""")
	assert_null(result)
	perform('continue')
	assert_null(result)
	perform('continue 1')
	assert_not_null(result)
	assert_eq(result['key'], &'sub')
	assert_eq(result['payload'], 1)
	perform('continue true')
	assert_not_null(result)
	assert_eq(result['key'], &'main')
	assert_eq(result['payload'], 'called')
