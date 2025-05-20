class Actor
  attr_accessor :name, :fiber, :proc

  def initialize(name)
    self.name  = name
    self.proc = []
  end

  def create_fiber
    @cycle = proc.cycle
    self.fiber = begin
      Fiber.new do
        loop do
          Fiber.yield @cycle.next.call
        end
      end
    end
  end

  def tick
    fiber.resume if fiber.alive?
  end
  
  def speak(str)
  end

  def run
  end
end

class Proc
  # for: -->{ do_something }
  def -@
    $binding_receiver.proc << self
  end
end

class Symbol
  # for: :key -->{ do_something }
  def -(other)
    # TODO add condition
    other.call
  end
end


$actors = []
$binding_receiver = nil


actor 'Rabbit' do
  -->{ run }
  :foo -->{  }
  
  def bar
  end
end
def actor(name, **attributes, &block)
  record = Actor.new(name, **attributes)
  $binding_receiver = record
  record.instance_exec(&block)
  record.create_fiber
  $actors << record
  record
end



