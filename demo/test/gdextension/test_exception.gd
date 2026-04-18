extends GutTest

var res : ReDScribe = null

func before_each():
	res = ReDScribe.new()


func test_method_missing():
	res.perform('foo')
	assert_eq(res.exception, '')


func test_simple_calc():
	res.perform('1 + 1')
	assert_eq(res.exception, '')


func test_syntax_error():
	res.perform('1 +')
	assert_eq(res.exception, '#<SyntaxError: syntax error>')


func test_raise():
	res.perform('raise "テスト"')
	assert_eq(res.exception, '#<RuntimeError: テスト>')


func test_multiple_instances():
	var res2 = ReDScribe.new()
	res.perform('foo')
	res2.perform('raise')
	assert_eq(res.exception, '')
	assert_eq(res2.exception, 'RuntimeError')
