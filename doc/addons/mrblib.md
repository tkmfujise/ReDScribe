# addons/redscribe/mrblib

I have created some libraries.
If you'd like to use them, add `require 'addons/redscribe/mrblib/xxx'` at the top of your script.

## actor
```ruby
require 'addons/redscribe/mrblib/actor'

actor 'Counter' do
  @number = 0
  --> { @number += 1 }
  :reset --> { @number = 0 }
end

# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
# `tick` => [ Counter ] signal emitted: { &"number": 2, &"name": "Counter" }
#
# `notify :reset`
# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
#
# `tell 'Counter', :reset`
# `tick` => [ Counter ] signal emitted: { &"number": 1, &"name": "Counter" }
#
# `ask 'Counter', :number` # => 1
```
see more:
* [demo/addons/redscribe/mrblib/actor.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/actor.rb)
* [demo/test/mrblib/test_actor.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_actor.gd)


## coroutine
```ruby
require 'addons/redscribe/mrblib/coroutine'

coroutine do
  loop do
    emit! :given, ___?
  end
end

# `start`         # When `___?` called, it stops until the next continue.
# `continue`      => [ given ] signal emitted: true
# `continue 123`  => [ given ] signal emitted: 123
```
```ruby
require 'addons/redscribe/mrblib/coroutine'

coroutine 'Foo' do
  emit! :foo, :started
  while ___?
    emit! :foo, :progress
  end
  emit! :foo, :finished
end

coroutine 'Bar' do
  emit! :bar, :started
  while ___?
    emit! :bar, :progress
  end
  emit! :bar, :finished
end

# `start :all`          # all coroutine start
#                       => [ foo ] signal emitted: &"started"
#                       => [ bar ] signal emitted: &"started"
# `resume 'Foo'`        => [ foo ] signal emitted: &"progress"
# `resume 'Bar', true`  => [ bar ] signal emitted: &"progress"
# `resume 'Foo', false` => [ foo ] signal emitted: &"finished"
# `resume 'Bar', false` => [ bar ] signal emitted: &"finished"
```
see more:
* [demo/addons/redscribe/mrblib/coroutine.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/coroutine.rb)
* [demo/test/mrblib/test_coroutine.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_coroutine.gd)


## math
```ruby
require 'addons/redscribe/mrblib/math'

sin(π) # => 0.0
√(2)   # => 1.41421356237309
```
see more:
* [demo/addons/redscribe/mrblib/math.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/math.rb)
* [demo/test/mrblib/test_math.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_math.gd)


## resource
```ruby
require 'addons/redscribe/mrblib/resource'
resource :stage do
  resource :image
  resources :chapter => :chapters
end

stage 'First' do
  number 1
  music  'first_stage.mp3'

  image do
    path 'first_stage.png'
  end

  chapter do
    name  'Chapter1'
    image 'path/to/chapter1.png'
  end

  chapter do
    name  'Chapter2'
    image 'path/to/chapter2.png'
  end
end

# => [ stage ] signal emitted:
# {
#   &"number": 1,
#   &"music": "first_stage.mp3",
#   &"name":  "First",
#   &"image": {
#     &"path": "first_stage.png",
#     &"name": "image_6308476176"
#   },
#   &"chapters": [
#     {
#       &"image": "path/to/chapter1.png",
#       &"name":  "Chapter1"
#     },
#     {
#       &"image": "path/to/chapter2.png",
#       &"name":  "Chapter2"
#     }
#   ]
# }
```
see more:
* [demo/addons/redscribe/mrblib/resource.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/resource.rb)
* [demo/test/mrblib/test_resource.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_resource.gd)


## shell
```ruby
require 'addons/redscribe/mrblib/shell'

cd 'addons' do
  sh 'ls -lA'
end
# Execute the shell command `ls -lA` in the addons directory.
```
see more:
* [demo/addons/redscribe/mrblib/shell.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/shell.rb)
* [demo/test/mrblib/test_shell.gd](https://github.com/tkmfujise/ReDScribe/blob/main/demo/test/mrblib/test_shell.gd)

