class Coroutine
  class << self
    attr_accessor :all, :current, :main
  end

  attr_accessor(
    :_fiber, :_proc, :name, :suspended, :_last_input
  )

  def initialize(_name = nil)
    self.name = _name || "Coroutine_#{object_id}"
  end

  def set_proc(block)
    self._proc = block
  end

  def recreate_fiber
    self.suspended = false
    block = _proc
    self._fiber = Fiber.new do
      instance_exec(&block)
    end
  end

  def resume(value = nil)
    if _fiber&.alive?
      self.suspended    = false
      Coroutine.current = self
      _fiber.resume(value)
    else
      false
    end
  end

  def emit!(key, payload)
    Godot.emit_signal key, payload
  end

  def ___?
    self.suspended   = true
    self._last_input = Fiber.yield
  end
  alias_method :_?,  :___?
  alias_method :__?, :___?

  def ___
    _last_input
  end
  alias_method :_,  :___
  alias_method :__, :___ #
end


Coroutine.all = []


# = Start coroutines
#
#   start           # start Coroutine.main
#   start :all      # start all
#   start 'target'  # start 'target' coroutine
#
def start(name = nil)
  case name
  when :all
    Coroutine.all.map{|c| c.recreate_fiber; c.resume }
  else
    target = \
      if name
        Coroutine.all.find{|c| c.name == name }
      else
        Coroutine.main
      end

    if target
      target.recreate_fiber
      target.resume || true
    else
      false
    end
  end
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
def resume(name = nil, value = true)
  if name
    Coroutine.all.find{|c| c.name == name }&.resume(value) || false
  else
    Coroutine.all.map{|c| c.resume(value) }
  end
end


# = Resume the current coroutine
#
#   continue
#   continue value
#
def continue(value = true)
  if Coroutine.current
    Coroutine.current.resume(value)
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
  Coroutine.main = record unless name
  record.set_proc(block)
  record
end
