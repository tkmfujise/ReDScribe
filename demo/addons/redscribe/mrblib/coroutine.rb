class Coroutine
  class << self
    attr_accessor :all, :current
  end

	attr_accessor(
    :_fiber, :_proc, :_parent, :name, :_name_sym, :_last_input
  )

	def initialize(_name = nil)
    self.name      = _name || "Coroutine_#{object_id}"
    self._name_sym = name.to_sym
	end

  def create_fiber(block)
    self._proc  = block
    self._fiber = Fiber.new do
      instance_exec(&block)
    end
  end

  def recreate_fiber
    block = _proc
    self._fiber = Fiber.new do
      instance_exec(&block)
    end
  end

  def resume(value = nil)
    if _fiber&.alive?
      Coroutine.current = self
      _fiber.resume(value)
      if !_fiber.alive? && _parent
        Coroutine.current = _parent
        self._parent = nil
      end
    else
      false
    end
  end

  def invoke!(name, value = nil)
    target = Coroutine.all.find{|c| c.name == name }
    if target
      target._parent = self
      target.recreate_fiber
      target.resume(value)
      if target._fiber.alive?
        Fiber.yield
      end
    else
      false
    end
  end

  def emit!(key = _name_sym, payload = nil)
    Godot.emit_signal key, payload
  end

  def ___?
    self._last_input = Fiber.yield
  end

  def ___
    _last_input
  end
end


Coroutine.all = []

# Free 'name' coroutine
def free(name)
  target = Coroutine.all.find{|c| c.name == name }
  if target
    Coroutine.all.delete(target)
    if Coroutine.current == target
      Coroutine.current = nil
    end
  end
  true
end


# = Resume coroutines
#
#   resume # resume all coroutines
#
#   or
#
#   resume 'target'
#   resume 'target', value
#
def resume(name = nil, value = nil)
  if name
    Coroutine.all.find{|c| c.name == name }&.resume(value)
    false
  else
    Coroutine.all.map(&:resume)
  end
end


# = Resume the current coroutine
#
#   continue
#   continue value
#
def continue(value = nil)
  if Coroutine.current
    Coroutine.current.resume(value)
    true
  else
    false
  end
end


# = Define a coroutine
#
#   coroutine do
#     loop do
#       emit! :given, ___?
#     end
#   end
#
def coroutine(name = nil, &block)
  record = Coroutine.new(name)
  Coroutine.all << record
  Coroutine.current = record unless name
  record.create_fiber(block)
  record
end
