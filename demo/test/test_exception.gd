extends GutTest


func test_method_missing():
	var res = ReDScribe.new()
	res.perform('foo')
	assert_eq(res.exception, '')


func test_simple_calc():
	var res = ReDScribe.new()
	res.perform('1 + 1')
	assert_eq(res.exception, '')


func test_syntax_error():
	var res = ReDScribe.new()
	res.perform('1 +')
	assert_eq(res.exception, 'syntax error (SyntaxError)')


func test_raise():
	var res = ReDScribe.new()
	res.perform('raise "テスト"')
	assert_eq(res.exception, 'テスト (RuntimeError)')


func test_multiple_instances():
	var res1 = ReDScribe.new()
	var res2 = ReDScribe.new()
	res1.perform('foo')
	res2.perform('raise')
	assert_eq(res1.exception, '')
	assert_eq(res2.exception, 'RuntimeError')
