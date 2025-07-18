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
	assert_eq(result, &'bar')


func test_integer():
	res.perform("foo 1")
	assert_eq(result, 1)


func test_float():
	res.perform("foo 1.5")
	assert_eq(result, 1.5)


func test_imaginary_number():
	res.perform("foo 1i")
	assert_eq(result, '(0.0+1.0i)')


func test_time():
	res.perform("foo Time.utc(2025, 1, 2, 3, 4, 5)")
	assert_eq(result, {
		"year":   2025,
		"month":  1,
		"day":    2,
		"hour":   3,
		"minute": 4,
		"second": 5,
		"zone":	  'UTC',
		"wday":   4, # 0: sunday
	})


func test_time_str():
	res.perform("foo Time.utc(2025, 1, 2, 3, 4, 5).to_s")
	assert_eq(result, '2025-01-02 03:04:05 UTC')


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
	assert_eq(result, { &"bar": 1, &"piyo": 2 })


func test_dictionary_string_key():
	res.perform("foo('bar' => 1, 'piyo': 2)")
	assert_eq(result, { "bar": 1, "piyo": 2 })


func test_array():
	res.perform("foo [1, true, :bar]")
	assert_eq(result, [1, true, &"bar"])


func test_range():
	res.perform("foo (1..3)")
	assert_eq(result, [1, 2, 3])


func test_self():
	res.perform("foo self")
	assert_eq(result, 'main')


func test_class():
	res.perform("""
		class Bar; end
		foo Bar
	""")
	assert_eq(result, 'Bar')


func test_instance():
	res.perform("""
		class Bar; end
		bar = Bar.new
		foo bar
	""")
	var regex = RegEx.new()
	regex.compile('^#<Bar:.+>$')
	assert_not_null(regex.search(result))
