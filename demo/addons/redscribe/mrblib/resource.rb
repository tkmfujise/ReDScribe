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

  def attributes
    hash = attribute_keys.map{|k| [k.to_sym, self[k]] }.to_h
    _children.group_by(&:_key).map do |k, arr|
      if _mapping[k]
        if _mapping[k] == k
          hash.merge!(k => arr[0].attributes)
        else
          hash.merge!(_mapping[k] => arr.map(&:attributes))
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

class DSL
  attr_accessor :mapping
  
  def initialize
    self.mapping = {}
  end

  def resource(key, top_level: false, &block)
    instance_exec(&block) if block_given?
    recv = top_level ? $main : self
    defined_mapping = mapping
    defined_mapping.merge!(key => key) unless top_level
    recv.define_singleton_method(key) do |name = nil, &blk|
      res = Resource.new(key, name)
      res._mapping.merge!(defined_mapping)
      res.instance_exec(&blk)
      res.tap(&:emit) if top_level
    end
  end
  
  def resources(mapping, &block)
    key, _ = mapping.to_a[0]
    self.mapping.merge!(mapping)
    instance_exec(&block) if block_given?
    define_singleton_method(key) do |name = nil, &blk|
      res = Resource.new(key, name)
      res.instance_exec(&blk)
    end
  end
end


# resource :chapter do
#   resource :image
#   resources :stage => :stages
# end
def resource(key, &block)
  dsl = DSL.new
  if block_given?
    dsl.resource(key, top_level: true){ instance_exec(&block) }
  else
    dsl.resource(key, top_level: true)
  end
end