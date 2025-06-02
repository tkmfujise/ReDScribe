extends GutTest

var res : ReDScribe = null
var result : Array


func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/coroutine"')
	res.channel.connect(_subscribe)
	result = []


func perform(code):
	result = []
	res.perform(code)


func _subscribe(key, payload):
	result.append({ 'key': key, 'payload': payload })


func test_start():
	perform("""
		coroutine do
		  emit! :foo, 'bar'
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_start_name():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  emit! :bar, 'piyo'
		end
	""")
	assert_eq(result, [])
	perform('start "Foo"')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_start_multiple():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  emit! :bar, 'piyo'
		end
	""")
	assert_eq(result, [])
	perform('start :all')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')
	assert_eq(result[1]['key'], &'bar')
	assert_eq(result[1]['payload'], 'piyo')


func test_start_multi_times():
	perform("""
		coroutine 'Foo' do
		  emit! :foo, 'bar'
		end
	""")
	assert_eq(result, [])
	perform('start "Foo"')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')
	perform('start "Foo"')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_resume():
	perform("""
		coroutine do
		  if ___?
		  	emit! :foo, 'bar'
		  end
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('resume')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_resume_name():
	perform("""
		coroutine 'Foo' do
		  ___?
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  ___?
		  emit! :bar, 'piyo'
		end
	""")
	assert_eq(result, [])
	perform('start :all')
	assert_eq(result, [])
	perform('resume "Foo"')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_resume_multiple():
	perform("""
		coroutine 'Foo' do
		  ___?
		  emit! :foo, 'bar'
		end
		coroutine 'Bar' do
		  ___?
		  emit! :bar, 'piyo'
		end
	""")
	assert_eq(result, [])
	perform('start :all')
	assert_eq(result, [])
	perform('resume')
	assert_eq(result.size(), 2)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')
	assert_eq(result[1]['key'], &'bar')
	assert_eq(result[1]['payload'], 'piyo')


func test_resume_multi_times():
	perform("""
		coroutine do
		  ___?
		  emit! :foo, 'bar'
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('resume')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')
	perform('resume')
	assert_eq(result, [])


func test_yield():
	perform("""
		coroutine do
		  val = ___?
		  emit! :foo, val
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('continue')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], true)


func test_yield_last_value():
	perform("""
		coroutine do
		  ___?
		  emit! :foo, ___
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('continue 123')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 123)


func test_yield_alias_1():
	perform("""
		coroutine do
		  _?
		  emit! :foo, _
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('continue 123')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 123)


func test_yield_alias_2():
	perform("""
		coroutine do
		  __?
		  emit! :foo, __
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('continue 123')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 123)


func test_yield_loop():
	perform("""
		coroutine do
		  loop do
			emit! :given, ___?
		  end
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result, [])
	perform('continue 1')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'given')
	assert_eq(result[0]['payload'], 1)
	perform('continue 2')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'given')
	assert_eq(result[0]['payload'], 2)
	perform('continue 3')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'given')
	assert_eq(result[0]['payload'], 3)


func test_module_include():
	perform("""
		module Helper
		  def foo!
			emit! :foo, 'bar'
		  end
		end
		Coroutine.include Helper

		coroutine do
		  foo!
		end
	""")
	assert_eq(result, [])
	perform('start')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'foo')
	assert_eq(result[0]['payload'], 'bar')


func test_control_flow():
	perform("""
		coroutine '1st' do
		  while ___?
			emit! :first, :progress
		  end
		  emit! :first, :finished
		end

		coroutine '2nd' do
		  while ___?
			emit! :second, :progress
		  end
		  emit! :second, :finished
		end
	""")
	assert_eq(result, [])
	perform('start :all')
	assert_eq(result, [])
	for i in 3:
		perform('resume "1st", true')
		assert_eq(result.size(), 1)
		assert_eq(result[0]['key'], &'first')
		assert_eq(result[0]['payload'], 'progress')
		perform('resume "2nd", true')
		assert_eq(result.size(), 1)
		assert_eq(result[0]['key'], &'second')
		assert_eq(result[0]['payload'], 'progress')
	perform('resume "1st", false')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'first')
	assert_eq(result[0]['payload'], 'finished')
	perform('resume "2nd", false')
	assert_eq(result.size(), 1)
	assert_eq(result[0]['key'], &'second')
	assert_eq(result[0]['payload'], 'finished')
