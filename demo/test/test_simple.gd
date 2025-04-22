extends GutTest


func test_method_missing():
	var res = SimpleDSL.new()
	res.perform('foo')
	assert_eq(res.exception, '')


func test_simple_calc():
	var res = SimpleDSL.new()
	res.perform('1 + 1')
	assert_eq(res.exception, '')


func test_raise():
	var res = SimpleDSL.new()
	res.perform('raise')
	assert_eq(res.exception, 'error')


func test_multiple_instances():
	var res1 = SimpleDSL.new()
	var res2 = SimpleDSL.new()
	res1.perform('foo')
	res2.perform('raise')
	assert_eq(res1.exception, '')
	assert_eq(res2.exception, 'error')
