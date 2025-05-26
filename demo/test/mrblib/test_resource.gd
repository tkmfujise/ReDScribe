extends GutTest

var res : ReDScribe = null
var result

func before_each():
	res = ReDScribe.new()
	res.perform('require "addons/redscribe/mrblib/resource"')
	res.channel.connect(_subscribe)
	result = null


func _subscribe(key, attributes):
	result = { 'key': key, 'attributes': attributes }


func test_simple():
	res.perform("""
		resource :player
		player 'Alice' do
		  level 1
		  job   :wizard
		end
	""")
	assert_eq(result['key'], 'player')
	assert_eq(result['attributes'], {
		&'name':  'Alice',
		&'level': 1,
		&'job':   &'wizard',
	})


func test_without_args():
	res.perform("""
		resource :player
		player {}
	""")
	assert_eq(result['key'], 'player')
	var regex = RegEx.new()
	regex.compile('^player_\\d+$')
	assert_not_null(regex.search(result['attributes']['name']))


func test_undefined():
	res.perform("""
		player {}
	""")
	assert_eq(result, null)


func test_with_block():
	res.perform("""
		resource :player do
		  resource :image
		end
		player 'Alice' do
		  level 1
		  image 'avater' do
			path 'path/to/image.png'
		  end
		end
	""")
	assert_eq(result['key'], 'player')
	assert_eq(result['attributes'], {
		&'name':  'Alice',
		&'level': 1,
		&'image': {
			&'name': 'avater',
			&'path': 'path/to/image.png',
		},
	})


func test_with_block_no_args():
	res.perform("""
		resource :player do
		  resource :image
		end
		player do
		  level 1
		  image do
			path 'path/to/image.png'
		  end
		end
	""")
	assert_eq(result['key'], 'player')
	var regex = RegEx.new()
	regex.compile('^player_\\d+$')
	assert_not_null(regex.search(result['attributes']['name']))
	assert_eq(result['attributes']['level'], 1)
	regex.compile('^image_\\d+$')
	assert_not_null(regex.search(result['attributes']['image']['name']))
	assert_eq(result['attributes']['image']['path'], 'path/to/image.png')


func test_with_block_array():
	res.perform("""
		resource :player do
		  resources :image => :images
		end
		player 'Alice' do
		  level 1
		  image 'avater' do
			path 'path/to/avater.png'
		  end
		  image 'background' do
			path 'path/to/background.png'
		  end
		end
	""")
	assert_eq(result['key'], 'player')
	assert_eq(result['attributes'], {
		&'name':  'Alice',
		&'level': 1,
		&'images': [
			{
				&'name': 'avater',
				&'path': 'path/to/avater.png',
			},
			{
				&'name': 'background',
				&'path': 'path/to/background.png',
			},
		],
	})


func test_with_block_undefined():
	res.perform("""
		resource :player
		player 'Alice' do
		  image do
			'test'
		  end
		end
	""")
	assert_eq(result['key'], 'player')
	assert_eq(result['attributes'], {
		&'name':  'Alice',
	})


func test_with_full():
	res.perform("""
		resource :chapter do
		  resource :image
		  resources :stage => :stages
		end
		chapter 'Opening' do
		  level 1
		  image 'thumbnail' do
			path 'path/to/opening.png'
		  end
		  stage 'stage1' do
			level 1
		  end
		  stage 'stage2' do
			level 2
		  end
		end
	""")
	assert_eq(result['key'], 'chapter')
	assert_eq(result['attributes'], {
		&'name':  'Opening',
		&'level': 1,
		&'image': {
			&'name': 'thumbnail',
			&'path': 'path/to/opening.png',
		},
		&'stages': [
			{
				&'name':  'stage1',
				&'level': 1,
			},
			{
				&'name':  'stage2',
				&'level': 2,
			},
		],
	})
