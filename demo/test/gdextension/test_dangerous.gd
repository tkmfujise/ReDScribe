extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.method_missing.connect(method_missing)
	result = null


func method_missing(_method_name, args):
	if args: result = args[0]


func test_exit_fails():
	res.perform('exit')
	assert_eq(res.exception, '')
	res.perform('foo 1')
	assert_eq(result, 1)


func test_send_exit_fails():
	res.perform('send :exit')
	assert_eq(res.exception, '')
	res.perform('foo 1')
	assert_eq(result, 1)


func test_shell_command_fails():
	res.perform('foo `whoami`')
	assert_eq(result, null)
	res.perform('foo 1')
	assert_eq(result, 1)


func test_shell_command_via_send_works():
	res.perform('foo send(:`, "whoami")')
	assert_not_null(result)


func test_file_read_inside_project_works():
	res.perform("foo File.read('project.godot')")
	assert_not_null(result)


func test_file_read_outside_project_works():
	res.perform("foo File.read('../README.md')")
	assert_not_null(result)


func test_file_write_fail():
	res.perform("foo File.write('foo.txt', 'bar')")
	var f = FileAccess.open('foo.txt', FileAccess.READ)
	assert_null(f)


func test_dir_pwd_works():
	res.perform('foo Dir.pwd')
	assert_not_null(result)
