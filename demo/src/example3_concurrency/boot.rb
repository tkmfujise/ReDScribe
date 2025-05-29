require 'addons/redscribe/mrblib/actor'


actor 'Weather' do
  @current = :sunny
  --> {
    @current = (rand < 0.3) ? :raining : :sunny
    notify @current
  }
  2.times{ -->{ keep } }
end


actor 'Rabbit' do
  @position = 0
  @speed    = 150
  --> { run unless @wait }
  :sunny   --> { @wait = false }
  :raining --> { @wait = true }
  
  def run
    @position += @speed * rand
  end
end


actor 'Turtle' do
  @position = 0
  @speed    = 1
  --> { run }
  :cheer --> { @speed += 1 }
  
  def run
    @position += @speed
  end
end
