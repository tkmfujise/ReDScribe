class Actor
  attr_accessor :name, :_fiber, :_procs

  def initialize(name)
    self.name   = name
    self._procs = []
  end

  def create_fiber
    _procs << proc{} if _procs.none?
    @_cycle = _procs.cycle
    self._fiber = begin
      Fiber.new do
        loop do
          @_cycle.next.call
          Fiber.yield emit
        end
      end
    end
  end

  def tick
    _fiber.resume if _fiber&.alive?
  end

  def keep
    # dummy method
  end

  def attribute_keys
    instance_variables.map{|k| k.to_s[1..-1] }.reject{|k| k.start_with? '_' }
  end

  def [](key)
    instance_variable_get(:"@#{key}")
  end

  def attributes
    attribute_keys.map{|k| [k.to_sym, self[k]] }.to_h
  end
  
  def emit(key = name.to_sym, payload = attributes)
    Godot.emit_signal key, payload
  end
end


class Proc
  # for: -->{ do_something }
  def -@
    $binding_receiver._procs << self
  end
end

class Symbol
  # for: :key -->{ do_something }
  def -(prc)
    $listeners[self] ||= {}
    $listeners[self].merge!($binding_receiver => prc)
  end
end


$binding_receiver = nil
$actors    = []
$listeners = {}


def tick
  $actors.each(&:tick); true
end


def notify(key)
  $listeners[key].to_a.each do |recv, prc|
    recv.instance_exec(&prc)
  end
  true
end


def ask(name, key)
  actor = $actors.find{|a| a[:name] == name }
  actor ? actor[key] : nil
end


def actor(name, &block)
  record = Actor.new(name)
  $binding_receiver = record
  record.instance_exec(&block)
  record.create_fiber
  $actors << record
  record
end

