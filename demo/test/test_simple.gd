extends GutTest


func test_method_missing():
	var res = SimpleDSL.new()
	res.dsl = 'bar'
	res.execute_dsl()
	assert_eq(res.dsl_error, '')


func test_raise():
	var res = SimpleDSL.new()
	res.dsl = 'raise'
	res.execute_dsl()
	assert_eq(res.dsl_error, 'error')
