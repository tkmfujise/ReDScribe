extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.method_missing.connect(method_missing)

func method_missing(method_name, args):
	result = args[0]


func test_string():
	res.perform("foo 'test'")
	assert_eq(result, 'test')


func test_symbol():
	res.perform("foo :bar")
	assert_eq(result, 'bar')


func test_integer():
	res.perform("foo 1")
	assert_eq(result, 1)


func test_float():
	res.perform("foo 1.5")
	assert_eq(result, 1.5)


func test_true():
	res.perform("foo true")
	assert_eq(result, true)


func test_false():
	res.perform("foo false")
	assert_eq(result, false)


func test_null():
	res.perform("foo nil")
	assert_eq(result, null)


func test_dictionary_symbol_key():
	res.perform("foo(bar: 1, :piyo => 2)")
	assert_eq(result, { "bar": 1, "piyo": 2 })


func test_dictionary_string_key():
	res.perform("foo('bar' => 1, 'piyo': 2)")
	assert_eq(result, { "bar": 1, "piyo": 2 })


func test_array():
	res.perform("foo [1, true, :bar]")
	assert_eq(result, [1, true, "bar"])


func test_unknown_class():
	res.perform("""
		class Foo; end
		foo = Foo.new
		bar foo
	""")
	assert_eq(result, null)
