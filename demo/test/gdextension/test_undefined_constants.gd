extends GutTest

var res : ReDScribe
var undefined_method : String


func before_each():
	res = ReDScribe.new()


func assert_execption(constant: String):
	assert_eq(res.exception, "uninitialized constant %s (NameError)" % constant)


func test_ARGV():
	res.perform('ARGV')
	assert_execption('ARGV')


func test_Date():
	res.perform('Date')
	assert_execption('Date')


func test_Encoding():
	res.perform('Encoding')
	assert_execption('Encoding')


func test_ENV():
	res.perform('ENV')
	assert_execption('ENV')


func test_OpenStruct():
	res.perform('OpenStruct')
	assert_execption('OpenStruct')


func test_Process():
	res.perform('Process')
	assert_execption('Process')


func test_Ractor():
	res.perform('Ractor')
	assert_execption('Ractor')


func test_Regexp():
	res.perform('Regexp')
	assert_execption('Regexp')


func test_Thread():
	res.perform('Thread')
	assert_execption('Thread')
