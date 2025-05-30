extends GutTest

var res : ReDScribe = null
const FETCH_SIGNAL  = 'fetch_value'
var fetched_value


func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/shell"')
	res.channel.connect(_subscribe)
	fetched_value = null


func fetch(code) -> Variant:
	fetched_value = null
	res.perform("Godot.emit_signal :%s, (\n%s\n)" % [FETCH_SIGNAL, code])
	return fetched_value


func _subscribe(key, attributes):
	match key:
		FETCH_SIGNAL:
			fetched_value = attributes
		_: return


func test_sh():
	assert_not_null(fetch('sh "whoami"'))


func test_sh_with_args():
	assert_not_null(fetch('sh "ls", "-l", "-A"'))


func test_ls():
	assert_not_null(fetch('ls'))
	assert_not_null(fetch('ls "-l", "-A"'))
	var result = fetch('ls "foobar"')
	assert_null(result)
	assert_eq(res.exception,
		'ls: foobar: No such file or directory (RuntimeError)')


func test_cat():
	assert_not_null(fetch('cat "project.godot"'))
	assert_not_null(fetch('cat "../README.md"'))
	var result = fetch('cat "foobar"')
	assert_null(result)
	assert_eq(res.exception,
		'cat: foobar: No such file or directory (RuntimeError)')


func test_pwd():
	assert_not_null(fetch('pwd'))


func test_cd():
	assert_not_null(fetch('cd("/"){ pwd }'))


func test_windows():
	assert_eq(fetch('windows?'), OS.get_name() == 'Windows')


func test_mac():
	assert_eq(fetch('mac?'), OS.get_name() == 'macOS')


func test_linux():
	assert_eq(fetch('linux?'), OS.get_name() == 'Linux')


func test_ENV():
	assert_typeof(fetch('ENV'), TYPE_DICTIONARY)
