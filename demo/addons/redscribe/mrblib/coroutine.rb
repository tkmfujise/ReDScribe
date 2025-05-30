class Coroutine
  class << self
    attr_accessor :all
  end

	attr_accessor :_fiber, :name, :_name_sym #

	def initialize(name = nil)
    self.name      = name || "Coroutine_#{object_id}"
    self._name_sym = name.to_sym
	end

  def create_fiber(block)
    self._fiber = Fiber.new do
      instance_exec(&block)
    end
  end

  def resume(value = nil)
    if _fiber&.alive?
      _fiber.resume(value)
    else
      false
    end
  end

  def emit!(key = _name_sym, payload = nil)
    Godot.emit_signal key, payload
  end

  def ___?
    Fiber.yield
  end
end


Coroutine.all = []


def resume(name = nil, value = nil)
  if name
    Coroutine.all.find{|c| c.name == name }&.resume(value)
  else
    Coroutine.all.map(&:resume)
  end
end


def coroutine(name = nil, &block)
  fiber = Coroutine.new(name)
  Coroutine.all << fiber
  fiber.create_fiber(block)
  fiber
end
