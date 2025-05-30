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
