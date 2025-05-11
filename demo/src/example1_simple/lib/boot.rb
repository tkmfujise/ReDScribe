class Player
  ATTRIBUTES = %i[name level job]

  def initialize(name)
    @name = name
  end

  def attributes
    ATTRIBUTES.map{|a| [a, self[a]] }.to_h
  end

  def [](key)
    instance_variable_get(:"@#{key}")
  end

  def []=(key, value)
    instance_variable_set(:"@#{key}", value)
  end

  def emit
    Godot.emit_signal(:add_player, attributes)
  end

  def method_missing(name, *args)
    if ATTRIBUTES.include? name
      self[name] = args[0]
    else
      super
    end
  end
end

def player(name, &block)
  player = Player.new(name)
  player.instance_exec(&block)
  player.emit
end
