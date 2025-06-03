class Resource
  attr_accessor :_key, :_children, :_mapping, :name

  def initialize(key, name = nil, &block)
    self._key      = key
    self.name      = name || "#{key}_#{object_id}"
    self._mapping  = {}
    self._children = []
    instance_exec(&block) if block_given?
  end

  def attribute_keys
    instance_variables.map{|k| k.to_s[1..-1] }.reject{|k| k.start_with? '_' }
  end

  def [](key)
    instance_variable_get(:"@#{key}")
  end

  def name(val)
    self.name = val
  end

  def attributes
    hash = attribute_keys.map{|k| [k.to_sym, self[k]] }.to_h
    _children.group_by(&:_key).map do |k, arr|
      if _mapping[k]
        if _mapping[k][:mapping] == k
          hash.merge!(k => arr[0].attributes)
        else
          hash.merge!(_mapping[k][:mapping] => arr.map(&:attributes))
        end
      end
    end
    hash
  end

  def emit
    Godot.emit_signal _key, attributes
  end

  def method_missing(method_name, *args, &block)
    if block_given?
      super unless _mapping[method_name]
      name  = args[0]
      child = Resource.new(method_name, name)
      child._mapping.merge!(_mapping[method_name][:children])
      child.instance_exec(&block)
      _children << child
    elsif args.count == 1
      instance_variable_set(:"@#{method_name}", args[0])
    else
      super
    end
  end
end

$main = self

class ResourceDSL
  attr_accessor :key, :parent, :mapping, :children

  def initialize(key, parent = nil)
    self.key      = key
    self.parent   = parent
    self.mapping  = key
    self.children = []
  end

  def resource(_key, &block)
    raise "resource arg `#{_key}` is not Symbol" unless _key.kind_of?(Symbol)
    introduce(_key, _key, block)
    generate_resource(_key) unless parent
  end

  def resources(hash, &block)
    raise "resource arg `#{hash}` is not Hash" unless hash.kind_of?(Hash)
    _key, _mapping = hash.to_a[0]
    introduce(_key, _mapping, block)
  end

  def all_mapping
    if parent
      { key => {
          mapping:  mapping,
          children: children.map(&:all_mapping).reduce(&:merge) || {}
      } }
    else
      children.map(&:all_mapping).reduce(&:merge) || {}
    end
  end

  private
    def introduce(key, mapping, block)
      dsl = ResourceDSL.new(key, self)
      dsl.mapping = mapping
      self.children << dsl
      dsl.instance_exec(&block) if block
    end

    def generate_resource(key)
      defined_mapping = all_mapping
      $main.define_singleton_method(key) do |name = nil, &blk|
        res = Resource.new(key, name)
        if defined_mapping[key]
          res._mapping.merge!(defined_mapping[key][:children])
        end
        res.instance_exec(&blk)
        res.tap(&:emit)
      end
    end
end


# resource :chapter do
#   resource :image
#   resources :stage => :stages
# end
def resource(key, &block)
  dsl = ResourceDSL.new(key)
  if block_given?
    dsl.resource(key){ instance_exec(&block) }
  else
    dsl.resource(key)
  end
end
