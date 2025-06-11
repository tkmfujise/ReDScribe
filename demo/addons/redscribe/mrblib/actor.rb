class Actor
  class << self
    attr_accessor :all, :binding_receiver, :listeners
  end

  attr_accessor :name, :_procs

  def initialize(name)
    self.name   = name
    self._procs = []
  end

  def create_cycle
    _procs << proc{} if _procs.none?
    @_cycle = _procs.cycle
  end

  def tick
    @_cycle.next.call
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


Actor.all = []
Actor.binding_receiver = nil
Actor.listeners = {}


class Proc
  # for: -->{ do_something }
  def -@
    Actor.binding_receiver._procs << self
  end
end

class Symbol
  # for: :key -->{ do_something }
  def -(prc)
    Actor.listeners[self] ||= {}
    Actor.listeners[self].merge!(Actor.binding_receiver => prc)
  end
end



def tick
  Actor.all.each(&:tick)
  Actor.all.each(&:emit)
  true
end


def notify(key)
  Actor.listeners[key].to_a.each do |recv, prc|
    recv.instance_exec(&prc)
  end
  true
end


def tell(name, key)
  recv, prc = Actor.listeners[key].find{|k, _| k.name == name }
  recv.instance_exec(&prc) if recv
end


def ask(name, key)
  actor = Actor.all.find{|a| a[:name] == name }
  actor ? actor[key] : nil
end


def free(name)
  Actor.listeners.each{|_, arr| arr.delete_if{|a| a.name == name } }
  Actor.all.delete_if{|a| a.name == name }
end


def actor(name, &block)
  record = Actor.new(name)
  Actor.binding_receiver = record
  record.instance_exec(&block)
  record.create_cycle
  Actor.all << record
  record
end
