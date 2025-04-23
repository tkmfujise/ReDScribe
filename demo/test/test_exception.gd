extends GutTest


func test_method_missing():
	var res = ReDScribe.new()
	res.perform('foo')
	assert_eq(res.exception, '')


func test_simple_calc():
	var res = ReDScribe.new()
	res.perform('1 + 1')
	assert_eq(res.exception, '')


func test_raise():
	var res = ReDScribe.new()
	res.perform('raise')
	assert_eq(res.exception, 'error')


func test_multiple_instances():
	var res1 = ReDScribe.new()
	var res2 = ReDScribe.new()
	res1.perform('foo')
	res2.perform('raise')
	assert_eq(res1.exception, '')
	assert_eq(res2.exception, 'error')
