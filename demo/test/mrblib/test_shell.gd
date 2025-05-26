extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/shell"')
	res.method_missing.connect(_method_missing)
	result = null


func _method_missing(_name, args):
	result = args[0]


func test_sh():
	res.perform('foo sh "whoami"')
	assert_not_null(result)


func test_sh_with_args():
	res.perform('foo sh "ls", "-l", "-A"')
	assert_not_null(result)


func test_ls():
	res.perform('foo ls')
	assert_not_null(result)
	result = null
	res.perform('foo ls "-l", "-A"')
	assert_not_null(result)
	result = null
	res.perform('foo ls "foobar"')
	assert_null(result)
	assert_eq(res.exception,
		'ls: foobar: No such file or directory (RuntimeError)')


func test_cat():
	res.perform('foo cat "project.godot"')
	assert_not_null(result)
	result = null
	res.perform('foo cat "../README.md"')
	assert_not_null(result)
	result = null
	res.perform('foo cat "foobar"')
	assert_null(result)
	assert_eq(res.exception,
		'cat: foobar: No such file or directory (RuntimeError)')


func test_pwd():
	res.perform('foo pwd')
	assert_not_null(result)


func test_cd():
	res.perform('foo cd("/"){ pwd }')
	assert_not_null(result)


func test_windows():
	res.perform('foo windows?')
	assert_eq(result, OS.get_name() == 'Windows')


func test_mac():
	res.perform('foo mac?')
	assert_eq(result, OS.get_name() == 'macOS')


func test_linux():
	res.perform('foo linux?')
	assert_eq(result, OS.get_name() == 'Linux')


func test_ENV():
	res.perform('foo ENV')
	assert_typeof(result, TYPE_DICTIONARY)
