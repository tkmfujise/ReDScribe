# 2. Resource generator

[![Resource generator](http://img.youtube.com/vi/NS4m7VBYJNk/0.jpg)](https://www.youtube.com/watch?v=NS4m7VBYJNk)

I have created a DSL( [demo/addons/redscribe/mrblib/resource.rb](https://github.com/tkmfujise/ReDScribe/blob/main/demo/addons/redscribe/mrblib/resource.rb) ).


## 1. Firstly, define your resources.

*base_resource.gd*
```gdscript
extends Resource
class_name BaseResource

static func build(klass, attributes: Dictionary) -> Resource:
    var res = klass.new()
    res.update(attributes)
    return res

func assign(key: StringName, value: Variant) -> void:
    set(key, value)

func update(attributes: Dictionary) -> Resource:
    for prop in get_property_list():
        match prop.class_name:
            &'Image':
                if attributes[prop.name].has('path'):
                    var image = Image.new()
                    image.load(attributes[prop.name].path)
                    set(prop.name, image)
            _: if attributes.has(prop.name):
                assign(prop.name, attributes[prop.name])
    return self
```
*chapter.gd*
```gdscript
extends BaseResource
class_name Chapter

@export var name : String
@export var number : int
@export var music : String
@export var image : Image
@export var stages : Array[Stage]

func assign(key: StringName, value: Variant) -> void:
    match key:
        'stages':
            for v in value:
                stages.push_back(build(Stage, v))
        _: super(key, value)
```
*stage.gd*
```gdscript
extends BaseResource
class_name Stage

@export var name : String
@export var image : Image
```

## 2. Then, create Ruby files.

*schema.rb*
```ruby
require 'addons/redscribe/mrblib/resource'

resource :chapter do
  resource :image
  resources :stage => :stages do
    resource :image
  end
end
```

*resource.rb*
```ruby
require 'path/to/schema'

chapter 'First' do
  number 1
  music  'first_chapter.mp3'

  image do
    path 'assets/images/icon.svg'
  end

  (1..3).each do |i|
    stage do
      name  "Stage#{i}"
      image do
        path "assets/images/stage_#{i}.svg"
      end
    end
  end
end
```

## 3. Finally, create a GDScript file for generating.

*generator.gd*
```gdscript
extends ReDScribe
class_name Generator

const DSL  = "res://path/to/resource.rb"
const DIST = "res://path/to/dist/chapter.tres"

func _init() -> void:
    channel.connect(_handle)

func run() -> void:
    perform(FileAccess.open(DSL, FileAccess.READ).get_as_text())

func build(klass, attributes: Dictionary) -> Resource:
    var res = klass.new()
    res.update(attributes)
    return res

func _handle(key: StringName, payload: Variant) -> void:
    match key:
        &'chapter':
            var chapter = build(Chapter, payload)
            ResourceSaver.save(chapter, DIST)
        _: print_debug('[ %s ] signal emitted: %s' % [key, payload])
```

Calling `run` will generate a resource to `path/to/dist/chapter.tres`.
```gdscript
var generator = Generator.new()
generator.run()
```

