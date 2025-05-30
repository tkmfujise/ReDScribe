extends GutTest

var res : ReDScribe = null
const FETCH_SIGNAL  = 'fetch_value'
var fetched_value


func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/math"')
	res.channel.connect(_subscribe)
	fetched_value = null


func fetch(code) -> Variant:
	fetched_value = null
	res.perform("Godot.emit_signal :%s, (\n%s\n)" % [FETCH_SIGNAL, code])
	return fetched_value


func _subscribe(key, attributes):
	match key:
		FETCH_SIGNAL:
			fetched_value = attributes
		_: return


func test_sin():
	assert_eq(fetch('sin(0)'), 0.0)


func test_sin_in_class():
	assert_eq(fetch("""
		class Foo
		  def bar
			sin(0)
		  end
		end
		Foo.new.bar
	"""), 0.0)


func test_π():
	assert_almost_eq(fetch('π'), 3.14159265358979, 0.0000001)


func test_sqrt():
	assert_almost_eq(fetch('√(2)'), 1.41421356237309, 0.0000001)


func test_sigmoid():
	assert_eq(fetch('sigmoid(0)'), 0.5)


func test_softmax():
	var result = fetch('softmax [1, 2, 3]')
	assert_eq(result.size(), 3)
	assert_almost_eq(result.reduce(func(a, i): return a + i), 1.0, 0.000001)


func test_cubic_bezier():
	var result = null
	assert_eq(fetch('cubic_bezier(0, 0, 0.5, 0.5, 1)'),   0.0)
	assert_eq(fetch('cubic_bezier(0.5, 0, 0.5, 0.5, 1)'), 0.5)
	assert_eq(fetch('cubic_bezier(1, 0, 0.5, 0.5, 1)'),   1.0)
