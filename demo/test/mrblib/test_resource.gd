extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/resource"')
	res.channel.connect(_subscribe)
	result = null


func _subscribe(resource_name, attributes):
	result = { 'name': resource_name, 'attributes': attributes }


func test_simple():
	res.perform("""
		resource :player
		player 'Alice' do
		  level 1
		  job   :magician
		end
	""")
	assert_eq(result['name'], 'player')
	assert_eq(result['attributes'], {
		&'name':  'Alice',
		&'level': 1,
		&'job':   &'magician',
	})
