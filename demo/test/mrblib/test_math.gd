extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/math"')
	res.method_missing.connect(_method_missing)
	result = null


func _method_missing(_name, args):
	result = args[0]


func test_sin():
	res.perform('foo sin(0)')
	assert_eq(result, 0.0)


func test_sin_in_class():
	res.perform("""
		class Foo
		  def bar
			foo sin(0)
		  end
		end
		Foo.new.bar
	""")
	assert_eq(result, 0.0)


func test_sigmoid():
	res.perform('foo sigmoid(0)')
	assert_eq(result, 0.5)


func test_softmax():
	res.perform('foo softmax [1, 2, 3]')
	assert_eq(result.size(), 3)
	assert_almost_eq(result.reduce(func(a, i): return a + i), 1.0, 0.000001)


func test_cubic_bezier():
	res.perform('foo cubic_bezier(0, 0, 0.5, 0.5, 1)')
	assert_eq(result, 0.0)
	res.perform('foo cubic_bezier(0.5, 0, 0.5, 0.5, 1)')
	assert_eq(result, 0.5)
	res.perform('foo cubic_bezier(1, 0, 0.5, 0.5, 1)')
	assert_eq(result, 1.0)
