extends GutTest

var res : ReDScribe = null
const EXT_PATH = 'addons/redscribe/mrblib/core_ext/string'
const FETCH_SIGNAL = 'fetch_value'
var fetched_value


func before_each():
	res = ReDScribe.new()
	res.channel.connect(_subscribe)
	fetched_value = null


func _subscribe(key, payload):
	match key:
		FETCH_SIGNAL: fetched_value = payload
		_: return


func require_ext():
	res.perform('require "%s"' % EXT_PATH)


func fetch(code) -> Variant:
	res.perform("Godot.emit_signal :%s, (%s)" % [FETCH_SIGNAL, code])
	return fetched_value



func test_chars():
	var arr = ['a', 'b', 'c', 'あ', 'い', 'う', '🍣', '🍺']
	require_ext()
	assert_eq(fetch("'abcあいう🍣🍺'.chars"), arr)
