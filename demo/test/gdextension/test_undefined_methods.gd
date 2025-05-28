extends GutTest

var res : ReDScribe
var undefined_method : String


func before_each():
	res = ReDScribe.new()
	res.method_missing.connect(method_missing)
	undefined_method = ''


func method_missing(method_name: String, _args: Array):
	undefined_method = method_name


func test_abort():
	res.perform('abort')
	assert_eq(undefined_method, 'abort')


func test_autoload():
	res.perform('autoload :Foo, "path/to/foo"')
	assert_eq(undefined_method, 'autoload')


func test_display():
	res.perform('display')
	assert_eq(undefined_method, 'display')


func test_exec():
	res.perform('exec "ls"')
	assert_eq(undefined_method, 'exec')


func test_exit():
	res.perform('exit')
	assert_eq(undefined_method, 'exit')


func test_fork():
	res.perform('fork')
	assert_eq(undefined_method, 'fork')


func test_load():
	res.perform('load("path/to/file.rb")')
	assert_eq(undefined_method, 'load')


func test_putc():
	res.perform('putc "1"')
	assert_eq(undefined_method, 'putc')


func test_require_relative():
	res.perform('require_relative "path/to/file"')
	assert_eq(undefined_method, 'require_relative')


func test_sleep():
	res.perform('sleep 1')
	assert_eq(undefined_method, 'sleep')


func test_spawn():
	res.perform('spawn("ls")')
	assert_eq(undefined_method, 'spawn')


func test_system():
	res.perform('system("ls")')
	assert_eq(undefined_method, 'system')


func test_warn():
	res.perform('warn "Warning"')
	assert_eq(undefined_method, 'warn')
