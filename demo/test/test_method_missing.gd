extends GutTest

var res : ReDScribe = null
var method_name
var args

func before_each():
	res = ReDScribe.new()
	res.method_missing.connect(method_missing)

func method_missing(_method_name, _args):
	method_name = _method_name
	args = _args


func test_no_args():
	res.perform("foo")
	assert_eq(method_name, 'foo')
	assert_eq(args, [])


func test_one_arg():
	res.perform("foo 1")
	assert_eq(method_name, 'foo')
	assert_eq(args, [1])


func test_multi_args():
	res.perform("foo 1, :bar")
	assert_eq(method_name, 'foo')
	assert_eq(args, [1, 'bar'])


func test_multi_call():
	res.perform("""
		bar
		foo
	""")
	assert_eq(method_name, 'foo')


func test_multi_if_defined_other():
	res.perform("""
		def foo; end
		bar
		foo
	""")
	assert_eq(method_name, 'bar')
