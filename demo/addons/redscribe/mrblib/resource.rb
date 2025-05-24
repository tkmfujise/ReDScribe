class Resource
  attr_accessor :_key, :_children, :name 

  def initialize(key, name = nil, &block)
    self._key      = key
    self.name      = name || key.to_s
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
      hash.merge!(k => arr.map(&:attributes))
    end
    hash
  end

  def emit
    Godot.emit_signal _key, attributes
  end

  def method_missing(method_name, *args, &block)
    if block_given?
      child = Resource.new(method_name)
      child.instance_exec(&block)
      _children << child
    elsif args.count == 1
      instance_variable_set(:"@#{method_name}", args[0])
    else
      super
    end
  end
end


# TODO
# resource :chapter do
#   resource :image
#   resources :stage => :stages
# end
def resource(key, &block)
  define_method(key) do |name = nil, &blk|
    res = Resource.new(key, name)
    res.instance_exec(&blk)
    res.tap(&:emit)
  end
end