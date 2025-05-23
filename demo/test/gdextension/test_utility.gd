extends GutTest

var res : ReDScribe


func before_each():
	res = ReDScribe.new()


func test_puts():
	res.perform("puts")
	assert_eq(res.exception, '')
	res.perform("puts 1")
	assert_eq(res.exception, '')
	res.perform("puts 1, 2")
	assert_eq(res.exception, '')
